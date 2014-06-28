require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'
require 'json'
require 'rest_client'
require 'RestClient'

require 'cgi'
require 'openssl'

## Listas : 1,2,4,5,8,9
	# 5: error cuando debiera de retornar los productos
##Falta : 1:error inesperado solicitando productos
##No nos han agregado: 3,7,8


class OtrasBodegasController
	def init()
		
	end
	def solicitarProducto(sku, cantidad)
		puts "Solicitando productos a otras bodegas..."
		temp = cantidad
		for i in 1 .. 9
			begin 
				case i
				when 1
					r= sol1(sku, cantidad)
				when 2
					r= sol2(sku, cantidad)
				when 3
					r= sol3(sku, cantidad)
				when 4
					r= sol4(sku, cantidad)
				when 5
					r= sol5(sku, cantidad)
				when 7
					r= sol7(sku, cantidad)
				when 8
					r= sol8(sku, cantidad)
				when 9
					r= sol9(sku, cantidad)
				end
				if i != 6 and r != nil
					puts r
					temp = temp - r.to_i
					puts temp
					if temp ==0
						puts 'Se logro solicitar el la cantidad necesaria a otras bodegas'
						return temp
					end
				end
			rescue
				puts 'Error inesperado solicitando producto en bodega'+ i.to_s
			end
		end
		puts 'No se logro solicitar el la cantidad necesaria a otras bodegas'
		return temp
	
	end  	

##Lista
	def sol1(sku, cantidad)
		
		puts "solicitando poducto a bodega 1..."
		response= RestClient.post "http://integra1.ing.puc.cl/ecommerce/api/v1/pedirProducto",{'usuario' => "grupo6", 'password' => "ebdf1bdb858ced98b4adef024c3ec86fbdc141c9",'SKU' => sku,'cantidad' => cantidad,'almacen_id' => "53571d98682f95b80b774860"}, {}
		data=JSON.parse(response)		
		puts data
		puts "solicitando poducto a bodega 1... OK"
		return data["amountSent"]
	end
##Lista
	def sol2(sku, cantidad)
		## falta inscripcion de usuario y contraseña
		puts "solicitando poducto a bodega 2..."
		response= RestClient.post "http://integra2.ing.puc.cl/api/pedirProducto",{'usuario' => "grupo6", 'password' => "ebdf1bdb858ced98b4adef024c3ec86fbdc141c9",'SKU' => sku,'cantidad' => cantidad,'almacen_id' => "53571d98682f95b80b774860"}, {}
		data=JSON.parse(response)		
		puts data
		puts data["cantidad"]
		puts "solicitando poducto a bodega 2...OK"
		return data["cantidad"]
	

	end

	def sol3(sku, cantidad)
		## Error no existe grupo, falta inscripcion de usuario y contraseña
		puts "solicitando poducto a bodega 3..."
		response= RestClient.post "http://integra3.ing.puc.cl/api/pedirProducto",{'usuario' => "grupo6", 'password' => "grupo6",'SKU' => sku,'cantidad' => cantidad,'almacen_id' => "53571d98682f95b80b774860"}, {}
		data=JSON.parse(response)		
		puts data
		puts "solicitando poducto a bodega 3...OK"
		return data["cantidad"]
			

	end
##Listo
	def sol4(sku, cantidad)
		puts "solicitando poducto a bodega 4..."
		response= RestClient.post "http://integra4.ing.puc.cl/api/pedirProducto",{'usuario' => "grupo6", 'password' => "ebdf1bdb858ced98b4adef024c3ec86fbdc141c9",'SKU' => sku,'cantidad' => cantidad,'almacen_id' => "53571d98682f95b80b774860"}, {}
		data=JSON.parse(response)	
		puts data
		puts "solicitando poducto a bodega 4...OK"
		return data["cantidad"]

		return 0
	end
## Listo, aunque el grupo tiene un error al despachar los productos	
	def sol5(sku, cantidad)
		puts "solicitando poducto a bodega 5..."
		response= RestClient.post "http://integra5.ing.puc.cl:8080/api/v1/pedirProducto",{'usuario' => "grupo6", 'password' => "ebdf1bdb858ced98b4adef024c3ec86fbdc141c9",'sku' => sku,'cantidad' => cantidad,'almacen_id' => "53571d98682f95b80b774860"}, {}
		data = JSON.parse(response)	
		
		puts data
	 	puts "solicitando poducto a bodega 5...OK"
		return data["cantidad"]
	
		return 0
		
	end
	
	def sol7(sku, cantidad)
		## No existe	
		puts "solicitando poducto a bodega 7..."
		response= RestClient.post "integra7.ing.puc.cl:8080/api/api_request",{'usuario' => "grupo6", 'password' => "ebdf1bdb858ced98b4adef024c3ec86fbdc141c9",'SKU' => sku,'cantidad' => cantidad,'almacen_id' => "53571d98682f95b80b774860"}, {}
		data=JSON.parse(response)	
		puts data
		puts "solicitando poducto a bodega 7...OK"
	
	end
	
	def sol8(sku, cantidad)
		## Error no existe grupo, falta inscripcion de usuario y contraseña
		##ver con Charad
		puts "solicitando poducto a bodega 8..."
		response= RestClient.post "http://integra8.ing.puc.cl/api/pedirProducto",{'usuario' => "grupo6", 'password' => "grupo6",'SKU' => sku,'cantidad' => cantidad,'almacen_id' => "53571d98682f95b80b774860"}, {}
		data=JSON.parse(response)	
		puts data
		puts "solicitando poducto a bodega 8...OK"

		return data[0]["cantidad"]
			
	
	end
	## Listo
	def sol9(sku, cantidad)
		puts "solicitando poducto a bodega 9..."
		response= RestClient.post "http://integra9.ing.puc.cl/api/pedirProducto/grupo6/grupo6/"+sku,{'cantidad' => cantidad,'almacen_id' => "53571d98682f95b80b774860"}, {}
		##1er grupo6 es usuario, 2do grupo6 es password
		data=JSON.parse(response)	
		puts data
		puts "solicitando poducto a bodega 9...OK"
		return data["response"]["cantidad"]
	end
	



end
#gestor = OtrasBodegasController.new
#puts gestor.solicitarProducto("3548644", 1)
#puts gestor.sol1("3548644", 1)
#puts gestor.sol2("3548644", 1)
#puts gestor.sol3("3548644", 1)
#puts gestor.sol4("3548644", 1)
#puts gestor.sol5("3548644", 1)
#puts gestor.sol7("3548644", 1)
#puts gestor.sol8("3548644", 1)
#puts gestor.sol9("3548644", 1)