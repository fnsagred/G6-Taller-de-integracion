require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'
require 'json'
require 'rest_client'
require 'RestClient'

require 'cgi'
require 'openssl'



class GestorStockController
	def init()
		
	end
	def getAlmacenes()
		puts "getAlmacenes..."
		header='UCgrupo6:'+encriptar("GET") ##(Base64.encode64("#{hmac.digest}"))
		response =RestClient.get 'http://bodega-integracion-2014.herokuapp.com/almacenes',{'Authorization' => header,:accept => :json} #((burl+url) ,("Authorization:"+header))
		data=JSON.parse(response)
		return data
=begin
		##revisar respuesta
		for i in 0.. (data.size()-1)
			puts data[i]
			puts "\n"
		end

	puts data.size()
=end
		##data es un arreglo de bodegas, una bodega puede ser:
		##grupo": 6,
	    ##_id": "53571d98682f95b80b774861",
	    ##pulmon": false,
	    ##"despacho": true,
	    ##"recepcion": false,
	    ##"totalSpace": 291,
	    ##"usedSpace": 0,
	    ##"__v": 0
		
		
	end

	def getSkusWithStock (almacenId)
		puts "getSkusWithStock..."
		header='UCgrupo6:'+encriptar('GET'+almacenId)
		response =RestClient.get 'http://bodega-integracion-2014.herokuapp.com/skusWithStock',{'Authorization' => header,:accept => :json, :params=>{:almacenId=>almacenId}} 
		data=JSON.parse(response)
		return data
=begin
		##revisar respuesta
		
		for i in 0.. (data.size()-1)
			puts data[i]
			puts "\n"
		end
		puts data.size()
=end


		##data es un arreglo de productos, un producto esta compuesto por
		##Arreglo de objetos: 
		##{ 
		##_id : sku, // sku 
		##total : int // total de stock disponible para el stock 
		##}
		

	end

	def getStock (almacenId, sku, limit)
		puts "getStock..."
		header='UCgrupo6:'+encriptar('GET'+almacenId+sku) 
		response =RestClient.get 'http://bodega-integracion-2014.herokuapp.com/stock',{'Authorization' => header,:accept => :json, :params=>{:almacenId=>almacenId, :sku=>sku, :limit=>limit}} 
		data=JSON.parse(response)
		return data
=begin
		##revisar respuesta
		for i in 0.. (data.size()-1)
			puts data[i]
		end
		puts data.size()
=end	
		##data es un arreglo de productos.
		##cada producto viene compuesto por
			##Producto: 
			##o Id (id de la instancia del producto en la bodega) 
			##o Sku: string 
			##o AlmacenId (almacen)
			##o Costos: double, costos asociados al producto (fabricación más costos de bodega que se 
			##vayan acumulando) 


		
	end

	def moverStock (productoId, almacenId)
		puts "moverStock..."
		key = 'X1xUvwA5'	
		url="http://bodega-integracion-2014.herokuapp.com/moveStock"
		signature = 'POST'+productoId+almacenId
		hmac = HMAC::SHA1.new(key)
		hmac.update(signature)
		header='UCgrupo6:'+encriptar(signature)##(Base64.encode64("#{hmac.digest}"))
		response= RestClient.post "http://bodega-integracion-2014.herokuapp.com/moveStock",{'productoId' => productoId, 'almacenId' => almacenId}, {:Authorization => header}
		data=JSON.parse(response)
		return data
=begin
		puts 'Response code:'
		puts response.code
		puts 'Response code:'
		puts 'Size response:'
		puts data.size()
=end
		##Parámetros 
		## productoId 
		## almacenId: Almacén de destino 

	end

	def moverStockBodega (producotId, almacenId)
		puts "moverStockBodega..." 
		url="http://bodega-integracion-2014.herokuapp.com/moveStockBodega"
		key = 'X1xUvwA5'
		signature = 'POST'+producotId+almacenId
		hmac = HMAC::SHA1.new(key)
		hmac.update(signature)
		header='UCgrupo6:'+encriptar(signature)##(Base64.encode64("#{hmac.digest}"))
		response= RestClient.post "http://bodega-integracion-2014.herokuapp.com/moveStockBodega",{'productoId' => producotId, 'almacenId' => almacenId}, {:Authorization => header}
		data=JSON.parse(response)
		return data
=begin
		##revisar respuesta
		puts 'Response code:'
		puts response.code
		puts 'Size response:'
		puts data.size()
=end
	
	end

	def despacharStock (productId, direccion, precio, pedidoId)
		puts "despacharStock..."
		key = 'X1xUvwA5'	
		signature = 'DELETE'+productId+direccion+precio+pedidoId
		hmac = HMAC::SHA1.new(key)
		hmac.update(signature)
		header='UCgrupo6:'+(Base64.encode64("#{hmac.digest}"))
		param={productoId: productId,direccion: direccion,precio: precio,pedidoId: pedidoId}
		response=RestClient::Request.execute(:method => 'delete', :url => "http://bodega-integracion-2014.herokuapp.com/stock",:headers =>{:Authorization => header}, :payload =>param)
		data=JSON.parse(response)
		return data

	end

=begin
				attr_reader :method, :url, :headers, :cookies,
                :payload, :user, :password, :timeout, :max_redirects,
                :open_timeout, :raw_response, :processed_headers, :args,
                :ssl_opts	
=end

	def despacharProductosCliente(sku, cantidad, direccion, precio, pedidoId)
		puts "Despachando productos de un mismo SKU..."
		almacenes=getAlmacenes()		
		contador =0
		for i in 0.. (almacenes.size()-1)
			if almacenes[i]["recepcion"] == false and almacenes[i]["despacho"]==false 
				puts "Buscando stock en almacenes"
				stocksalmacen= getSkusWithStock(almacenes[i]["_id"])
				##puts stocksalmacen
				for j in 0.. (stocksalmacen.size()-1)
				 	if stocksalmacen[j]["_id"]== sku
				 		temp=cantidad.to_i-contador
				 		puts "Temp"
				 		puts temp
				 		productoadespachar= getStock(almacenes[i]["_id"],stocksalmacen[j]["_id"],temp.to_s)
				 		puts ("cantidad restante" +productoadespachar.size().to_s)
				 		

				 		puts "buscando productos deseados en almacen"
				 		for k in 0 .. productoadespachar.size()-1
					 		if(getSpaceBodega("despacho")>0  )
						 		moverStock(productoadespachar[k]["_id"], getIdBodega("despacho"))
						 		despacharStock(productoadespachar[k]["_id"], direccion, precio, pedidoId )
						 		contador= contador+1
						 		puts contador. to_i
						 		puts cantidad.to_i
						 		if(contador.to_i == cantidad.to_i)
						 			puts ("despacho completo SKU: #{sku}")	
						 			return true
						 		end
							else 
								puts "Se sobre colapso la bodega de despacho......posible error en el pedido" ## Nota esto ocurrira solo si al momento de despachar los productos estos no liberan instantaneamente el espacio en la bodega de despacho
								return false
							end
				 		end
				 	end
				end

			end
		end
		return false

	end

	def encriptar(signature)
		key = 'X1xUvwA5'
		hmac = HMAC::SHA1.new(key)
		hmac.update(signature)
		puts "Encriptando..."
		respuesta = (Base64.encode64("#{hmac.digest}"))

		return respuesta
		
	end
	def moverProductoBodega(sku, cant, idbodegadestino)
		cont=0
		almacenes=getAlmacenes()		
		for i in 0.. (almacenes.size()-1)
			if almacenes[i]["recepcion"] == false and almacenes[i]["despacho"]==false 
				stocksalmacen= getSkusWithStock(almacenes[i]["_id"])
				
				for j in 0.. (stocksalmacen.size()-1)
				 	if stocksalmacen[j]["_id"]== sku
				 		productoadespachar= getStock(almacenes[i]["_id"],stocksalmacen[j]["_id"], 100)
				 		if(getSpaceBodega("despacho")>0  )
				 			begin
					 		moverStock(productoadespachar[0]["_id"], getIdBodega("despacho"))
					 		moverStockBodega(productoadespachar[0]["_id"],idbodegadestino)
							cont=cont+1
							rescue
							end
							if(cont== cant)
								return true
							end
						end				
				 	end
				end

			end
		end
		return false
	end
	def getIdBodega(tipo) ##tpulon, despacho
		temp =0
		almacenes=getAlmacenes()		
		for i in 0.. (almacenes.size()-1)
			if almacenes[i][tipo]==true 
				temp=almacenes[i]["_id"]
			end
		end
		return temp
	end
	def getSpaceBodega(tipo) ##tpulon, despacho
		temp = 0
		almacenes=getAlmacenes()
		for i in 0.. (almacenes.size()-1)
			if almacenes[i][tipo]==true 
				temp=almacenes[i]["totalSpace"]-almacenes[i]["usedSpace"]
			end
		end
		return temp
	end
	def getSpaceIdBodega(id) ##tpulon, despacho
		temp = 0
		almacenes=getAlmacenes()
		for i in 0.. (almacenes.size()-1)
			if almacenes[i]['_id']==id 
				temp=almacenes[i]["totalSpace"]-almacenes[i]["usedSpace"]
			end
		end
		return temp
	end
	def getUsedSpaceIdBodega(id) ##tpulon, despacho
		temp = 0
		almacenes=getAlmacenes()
		for i in 0.. (almacenes.size()-1)
			if almacenes[i]['_id']==id 
				return almacenes[i]["usedSpace"]
			end
		end
	end



	def containsEnoughSku(sku, cant)
		counter=0
		
		almacenes=getAlmacenes()		
		for i in 0.. (almacenes.size()-1)
			if (not almacenes[i]['despacho'] and not almacenes[i]['recepcion']) 
				
				productos=getSkusWithStock(almacenes[i]['_id'])
				for j in 0 ..(productos.size()-1)
					if(productos[j]['_id']==sku)
					##	puts 'existen'
					##	puts productos[j]['total'].to_i
						counter= counter+productos[j]['total'].to_i
					end

				end
			end
		end
		if counter>=cant.to_i
			return true
		end
		return false

	end

	def containsEnoughSkus(skus, cants)
		
		if(skus.size()== cants.size())
			for i in 0.. (skus.size()-1)
				if(not containsEnoughSku(skus[i], cants[i]) )
					return false
				end
			end
			return true
		end
	end
	def contarSkuBodega(sku)
		counter =0
		almacenes=getAlmacenes()		
		for i in 0.. (almacenes.size()-1)
			if (not almacenes[i]['despacho'] and not almacenes[i]['recepcion']) 
				
				productos=getSkusWithStock(almacenes[i]['_id'])
				for j in 0 ..(productos.size()-1)
					if(productos[j]['_id']==sku)
					##	puts 'existen'
					##	puts productos[j]['total'].to_i
						counter= counter+productos[j]['total'].to_i
					end

				end
			end
		end
		puts "Counter"
		puts counter 
		return counter
	end

	def liberarBodegaRecepcion()
		puts "Liberando bodega de recepcion ..."
		identrada= getIdBodega("recepcion")
		almacenes=getAlmacenes()
		indicebodega=0
		valido = false
		while (not valido and indicebodega< almacenes.size() )			
			begin
				if ((getSpaceIdBodega(almacenes[indicebodega]['_id'])>0) and (not almacenes[indicebodega]['despacho']) and (not (almacenes[indicebodega]['_id'] ==identrada)))
					valido = true 
					
					break
					
				end
			rescue
			end
			indicebodega=indicebodega+1
		end
		puts indicebodega

		if valido
			entrada=getSkusWithStock(identrada)
			puts entrada
			for i in 0.. (entrada.size()-1)
				productos=  getStock(identrada, entrada[i]['_id'], entrada[i]['total'])
			##	puts productos
				for j in 0 .. (productos.size()-1)
					if(getSpaceIdBodega(almacenes[indicebodega]["_id"])>0)
						##mover producto
						puts "Moviendo producto"
						puts ("producto: "+productos[j]["_id"])
						puts ("AlmacenId destino: "+almacenes[indicebodega]['_id'])
						begin
							moverStock(productos[j]["_id"],almacenes[indicebodega]['_id'] )				
						rescue
							puts("No fue posible realizar el movimiento de producto entre bodegas")
						end
					else
						j=j-1
						valido = false
						while (not valido and indicebodega< almacenes.size() )			
							begin
								if ((getSpaceIdBodega(almacenes[indicebodega]['_id'])>0) and (not almacenes[indicebodega]['despacho']) and (not (almacenes[indicebodega]['_id'] ==identrada)))
									valido = true 
									indicebodega=indicebodega-1
								end
							rescue
							end
							indicebodega=indicebodega+1
						end
					##	puts indicebodega
					end
				end

			end	
		end


	end

end	



##gestor = GestorStockController.new
## gestor.getSpaceIdBodega(gestor.getIdBodega('recepcion'))
## gestor.getUsedSpaceIdBodega(gestor.getIdBodega('recepcion'))


##gestor.despacharProductosCliente("2637414", "8", "casa felipe", "380", "78")
=begin
x=[]
for i in 0..x.size()
	x.push(i)
end

for i in 0..x.size()
	puts i
end
=end
##gestor.liberarBodegaRecepcion()



##Test encriptacion
##puts gestor.encriptar('GET')

##acceder a un parametro de la resuesta:
##puts almacenes[0]["_id"]





=begin   prueba containsEnoughSkus
i=(gestor.getSkusWithStock(gestor.getAlmacenes()[2]["_id"])).take(3)
puts i
ix=[]
iy=[]
for y in 0.. i.size()-1
	ix.push(i[y]["_id"])
	iy.push(i[y]["total"])
end

##c=(gestor.getSkusWithStock(gestor.getAlmacenes()[2]["_id"]))[0]['total'].to_i()
##puts c
puts  gestor.containsEnoughSkus(ix,iy)
=end




## Ejemplo comprobar existencia de stocks
##puts gestor.containsEnoughSku((gestor.getSkusWithStock(gestor.getAlmacenes()[2]["_id"]))[0]['_id'],9)

##obtener id de bodega usada (cualquiera)
=begin 

idcual="0"
for i in 0.. (almacenes.size()-1)
	if almacenes[i]["usedSpace"] !=0 and almacenes[i]["despacho"]==false 
		idcual=almacenes[i]["_id"]
	end
end
puts idcual
=end
##arr= gestor.getSkusWithStock(idcual)
##puts arr
##prod= gestor.getStock(idcual,arr[0]["_id"],100) 
##puts prod
##gestor.moverStock(prod[0]["_id"],iddesp)

##puts prod[0]["_id"]





##arrd= gestor.getSkusWithStock(iddesp)
=begin
##proddesp=gestor.getStock(iddesp,arrd[0]["_id"],100) 
puts "Pdesoacho"
puts proddesp
puts "moviendo:"
puts proddesp[0]["_id"]
puts "Bodega: 53571ddc682f95b80b77ae69"
=end
##gestor.moverStockBodega(proddesp[0]["_id"],"53571ddc682f95b80b77ae69")









## Ejemplo comprobar existencia de stock
##puts gestor.containsEnoughSku((gestor.getSkusWithStock(gestor.getAlmacenes()[2]["_id"]))[0]['_id'],9)


##Ejemplo mover un producto de una bodega a otra:
##respuesta=gestor.moverProductoBodega(gestor.getSkusWithStock("53571d98682f95b80b774862")[0]["_id"],"53571ddc682f95b80b77ae69")   



=begin
## ejemplo despacho de un porducto.
respuesta=gestor.despacharStock(proddesp[0]["_id"],"UC","990","1")
puts "despachado"
gestor.getSkusWithStock(iddesp)
=end 










































##gestor.getAlmacenes()
##gestor.getAlmacenes()
##gestor.test()
##gestor.getSkusWithStock("53571d98682f95b80b774862")
##gestor.getStock("53571d98682f95b80b774862","3198295","100")

##a despacho
##gestor.moverStock("53571d9e682f95b80b80b7794b4","53571d98682f95b80b774860")

##53571d9e682f95b80b7794b9
##gestor.moverStock("53571d9e682f95b80b7794b9","53571da0682f95b80b77ae68")

##                                                                         53571da0682f95b80b77ae62
#gestor.moverStockBodega("53571d9e682f95b80b7794b9","53571ddc682f95b80b77ae69")

##gestor.despacharStock("53571d9e682f95b80b7794b4","UC","990","1")

=begin
gestor.getSkusWithStock()
gestor.getStock()
gestor.moverStock()
gestor.moverStockBodega()
gestor.despacharStock()
=end