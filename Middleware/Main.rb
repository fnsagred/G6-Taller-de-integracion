require './Spreadsheet.rb'
require './Pricing.rb'
require './Gestorbodegatest.rb'
require './GestorDW.rb'
require './sftp_manager.rb'
require './v_tiger_controller.rb'


puts "Comenzando middleware..."
	puts "Iniciando SFTPManager... "	
	sftpm= SFTPManager.new
	puts "Iniciando SFTPManager... OK"
	puts "Iniciando Pricing... "
	sistemaPricing = Pricing.new()
	puts "Iniciando Pricing... OK"
	puts "Iniciando Sistema reservas (Spreadsheet)... "
	sistemaReservas= Spreadsheet.new()
	puts "Iniciando Sistema reservas (Spreadsheet)... OK"
	puts "Iniciando Sistema Vtiger... "
	sistemaVtiger= VTigerController.new
	puts "Iniciando Sistema Vtiger... OK"
	puts "Iniciando Sistema Gestion Bodega... "
	sistemaBodega= GestorStockController.new
	puts "Iniciando Sistema Gestion Bodega... OK"
	puts "Iniciando Sistema Data Warehousing... "
	sistemaDW= GestorDW.new
	puts "Iniciando Sistema Data Warehousing... OK"




while(1)
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
	begin
	pedido= sftpm.getNext()
	rescue
		puts "Error obteniendo el siguente pedido en el SFTP"
	end
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
					
					cantidadAEnviar=SeLePuedeDar
					sistemaDW.insertQuiebre(pedidoId, Array({:SKU => skuTemp, :Cantidad =>cantNecesitada - cantidadAEnviar, :PerdidaTotal=>((cantNecesitada.to_i - cantidadAEnviar.to_i)*precioskutemp.to_i).to_s}), idCliente )
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
		begin
			pedido= sftpm.getNext()
		rescue
			puts "Error obteniendo el siguente pedido en el SFTP"
		end
	end

end