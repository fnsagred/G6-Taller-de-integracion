require './Spreadsheet.rb'
require './Pricing.rb'
require './Gestorbodegatest.rb'
require './GestorDW.rb'
require './sftp_manager.rb'
require './v_tiger_controller.rb'
require './rabbit_manager.rb'
require './twitter_manager.rb'
require './OtrasBodegasController.rb'
require "bunny"
require 'json'

puts "Comenzando middleware..."
	
	puts "Iniciando Pricing... "
	sistemaPricing = Pricing.new()
	puts "Iniciando Pricing... OK"
	puts "Iniciando Sistema reservas (Spreadsheet)... "
	sistemaReservas= Spreadsheet.new()
	puts "Iniciando Sistema reservas (Spreadsheet)... OK"
	puts "Iniciando Sistema Gestion Bodega... "
	sistemaBodega= GestorStockController.new
	puts "Iniciando Sistema Gestion Bodega... OK"
	puts "Iniciando Sistema Gestion Otras Bodegas... "
	sistemaOtrasBodegas= OtrasBodegasController.new
	puts "Iniciando Sistema Gestion Otras Bodegas... OK"
	puts "Iniciando Sistema Data Warehousing... "
	sistemaDW= GestorDW.new
	puts "Iniciando Sistema Data Warehousing... OK"
    puts "Iniciando SFTPManager... "	
	sftpm= SFTPManager.new
	puts "Iniciando SFTPManager... OK"
    puts "Iniciando RabbitMQManager... "	
	rm= RabbitManager.new
	puts "Iniciando RabbitMQManager... OK"
    puts "Iniciando TwitterManager... "	
	tm= TwitterManager.new
	puts "Iniciando TwitterManager... OK"
  
    

while(1)

	puts "Iniciando Sistema Vtiger... "
	sistemaVtiger= VTigerController.new
	puts "Iniciando Sistema Vtiger... OK"


	puts "Liberando bodea de recepcion..."
	begin
	sistemaBodega.liberarBodegaRecepcion()
	puts "Liberando bodea de recepcion...OK"
	rescue
		puts"Liberando bodea de recepcion...ERROR"
	end
	begin
	puts "SFTP actualizado..."
	sftpm.Actualizar()
	puts "SFTP actualizado... OK"
	rescue
		puts "Error SFTP"
	end
	begin
	sistemaPricing.Actualizar()
	sistemaReservas.Actualizar()	
	rescue
		puts "Error Pricing o Reservas"
	end
	

  puts "RabbitMQManager actualizado..."
  rm.Actualizar #ACA EMPIEZA RABBIT
  puts "RabbitMQManager actualizado...OK"
  puts "TwitterManager actualizado..."
  tm.Actualizar
  puts "TwitterManager actualizado...OK"
  msg=rm.PopOferta
  listaAux=[]
  num=0

  while(msg!="")
    listaAux.push(msg)
    num=num+1
    puts "IN: "+msg
    msg=rm.PopOferta
  end

 # rm.Actualizar
  num2=num
=begin
  while(num>0)   #BORRAR LUNES ESTO ES PARA PROBAR NOMAS
  num=num-1
  rm.Send(listaAux[num])
  end
=end
  rm.Desconectar

  while(num2>0)
    num2=num2-1
    twit= JSON.parse(listaAux[num2])
    #tm.Tweet("OF: "+twit["sku"])
    sistemaPricing.setOferta(twit["sku"],twit["precio"],twit["inicio"],twit["fin"]);
  end

puts "Eliminando Ofertas Obsoletas..."
sistemaPricing.eliminarObsoletas() 
puts "Eliminando Ofertas Obsoletas...OK"
ofertas = sistemaPricing.getLista()
for i in 0.. ofertas.size-1

 if(Time.at(ofertas[i][2].to_i/1000)<=Time.now)
    tm.Tweet("Of: "+ofertas[i][0].to_s+" a precio "+ofertas[i][1].to_s+" "+ Time.at(ofertas[i][2].to_i/1000).to_s + " y termina "+Time.at(ofertas[i][3].to_i/1000).to_s+" #ofertagrupo6")
 end


end




	pedido= sftpm.getNext()
	
	temp=0
	while( pedido != nil)
		puts 
		puts pedido
		pedidoId=(pedido[0].to_i).to_s
		idCliente= pedido[1]['rut'].to_s
		idDireccion= pedido[1]['direccionId'].to_s
		direccionCliente=sistemaVtiger.getDireccion(idDireccion)
		despachopedidocorrecto= true
		for i in 0.. pedido[1]['Pedido'].size()-1
			begin
				skuTemp= ((pedido[1]['Pedido'][i]['sku']).to_i).to_s
				precioskutemp=sistemaPricing.getPrecio(skuTemp)
				cantNecesitada= (pedido[1]['Pedido'][i]['cantidad']).to_i
				prodskuenbodega= sistemaBodega.contarSkuBodega(skuTemp)
				totalReservas = sistemaReservas.totalReservado(skuTemp)
				reservasDiponibles=sistemaReservas.getDisponible(skuTemp, idCliente).to_i
				cantidadAEnviar=0
				puts prodskuenbodega
				
				if prodskuenbodega<reservasDiponibles
					SeLePuedeDar = prodskuenbodega
				else 
					SeLePuedeDar = (reservasDiponibles + [0, prodskuenbodega - totalReservas].max).to_i
				end

				if SeLePuedeDar<cantNecesitada
					sistemaOtrasBodegas.solicitarProducto(skuTemp,cantNecesitada-SeLePuedeDar)
					puts "Liberando bodega de recepcion..."
					begin
					sistemaBodega.liberarBodegaRecepcion()
					puts "Liberando bodega de recepcion...OK"
					rescue
						puts"Liberando bodega de recepcion...ERROR"
					end

					prodskuenbodega= sistemaBodega.contarSkuBodega(skuTemp)
					if prodskuenbodega<reservasDiponibles
					SeLePuedeDar = prodskuenbodega
					else 
					SeLePuedeDar = (reservasDiponibles + [0, prodskuenbodega - totalReservas].max).to_i
					end
					if SeLePuedeDar<cantNecesitada
						cantidadAEnviar=SeLePuedeDar
						sistemaDW.insertQuiebre(pedidoId, Array({:SKU => skuTemp, :Cantidad =>cantNecesitada - cantidadAEnviar, :PerdidaTotal=>((cantNecesitada.to_i - cantidadAEnviar.to_i)*precioskutemp.to_i).to_s}), idCliente )
					else 
						cantidadAEnviar=cantNecesitada
					end
				else
					cantidadAEnviar=cantNecesitada
				end
				PrecioSku=sistemaPricing.getPrecio(skuTemp)
				puts PrecioSku
				puts direccionCliente
				sistemaReservas.PedirReserva(skuTemp, idCliente, cantidadAEnviar)
				despachocorrecto=sistemaBodega.despacharProductosCliente(skuTemp, cantidadAEnviar, direccionCliente, PrecioSku, pedidoId)
				puts "Despacho correcto misma sku :"
				puts despachocorrecto.to_s
				despachopedidocorrecto= (despachopedidocorrecto and despachocorrecto)
				if(cantidadAEnviar>0)
					##Registrar venta
					sistemaDW.insertVenta(pedidoId, Array({:SKU => skuTemp, :Cantidad => cantidadAEnviar, :VentaTotal=>((cantidadAEnviar.to_i)*precioskutemp.to_i).to_s}), direccionCliente, idCliente,sistemaVtiger.getOrganizacion(idCliente))
				end
			rescue
				puts "Se ha producido un error"
				despachopedidocorrecto= false	
			end
		end
		puts "Despacho correcto general :"
		puts despachopedidocorrecto
		
			pedido= sftpm.getNext()
		
	end
puts "Esperando por 60 segundos para ver si hay nuevos pedidos..."
sleep(60)
puts "Esperando por 60 segundos para ver si hay nuevos pedidos...OK"
end