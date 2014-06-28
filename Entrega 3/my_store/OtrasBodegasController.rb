require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'
require 'json'
require 'rest_client'
require 'RestClient'

require 'cgi'
require 'openssl'


class OtrasBodegasController
	def init()
		
	end
	def solicitarProducto(sku, cantidad)
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
				temp = temp - r.to_i
				puts temp
				if temp ==0
					puts 'Se logro solicitar el la cantidad necesaria a otras bodegas'
					return true
				end 
			rescue
				puts 'Error inesperado solicitando producto en '+ i.to_s
			end
		end
		puts 'No se logro solicitar el la cantidad necesaria a otras bodegas'
		return false
	
	end  	


	def sol1(sku, cantidad)
		

		## No existe


		puts "solicitando podicto a bodega 1..."
		response= RestClient.post "http://integra1.ing.puc.cl/api/pedirProducto",{'usuario' => "grupo6", 'password' => "ebdf1bdb858ced98b4adef024c3ec86fbdc141c9",'SKU' => sku,'cantidad' => cantidad,'almacen_id' => "53571d98682f95b80b774860"}, {}
		data=JSON.parse(response)		
		puts data
		puts "solicitando podicto a bodega 1... OK"
		
	end

	def sol2(sku, cantidad)
		## falta inscripcion de usuario y contraseña

		puts "solicitando podicto a bodega 2..."
		response= RestClient.post "http://integra2.ing.puc.cl/api/pedirProducto",{'usuario' => "grupo6", 'password' => "ebdf1bdb858ced98b4adef024c3ec86fbdc141c9",'SKU' => sku,'cantidad' => cantidad,'almacen_id' => "53571d98682f95b80b774860"}, {}
		data=JSON.parse(response)		
		puts data
		puts "solicitando podicto a bodega 2...OK"
		return data["cantidad"]
	

	end

	def sol3(sku, cantidad)
		## Error no existe grupo, falta inscripcion de usuario y contraseña
		puts "solicitando podicto a bodega 3..."
		response= RestClient.post "http://integra3.ing.puc.cl/api/pedirProducto",{'usuario' => "grupo6", 'password' => "ebdf1bdb858ced98b4adef024c3ec86fbdc141c9",'SKU' => sku,'cantidad' => cantidad,'almacen_id' => "53571d98682f95b80b774860"}, {}
		data=JSON.parse(response)		
		puts data
		puts "solicitando podicto a bodega 3...OK"
		return data["cantidad"]
			

	end

	def sol4(sku, cantidad)
	
		puts "solicitando podicto a bodega 4..."
=begin
		response= RestClient.post "http://integra4.ing.puc.cl/api/pedirProducto",{'usuario' => "grupo6", 'password' => "ebdf1bdb858ced98b4adef024c3ec86fbdc141c9",'SKU' => sku,'cantidad' => cantidad,'almacen_id' => "53571d98682f95b80b774860"}, {}
		data=JSON.parse(response)	
		puts data
		puts "solicitando podicto a bodega 4...OK"
	#	return data["cantidad"]

=end		
		return 0
	end
	
	def sol5(sku, cantidad)
	  ## 
		puts "solicitando podicto a bodega 5..."
		response= RestClient.post "http://integra5.ing.puc.cl:8080/api/v1/pedirProducto",{'usuario' => "grupo6", 'password' => "ebdf1bdb858ced98b4adef024c3ec86fbdc141c9",'sku' => sku,'cantidad' => cantidad,'almacen_id' => "53571d98682f95b80b774860"}, {}
		data = JSON.parse(response)	
		
		puts data
	 	puts "solicitando podicto a bodega 5...OK"
		return data["cantidad"]
		
	end
	
	def sol7(sku, cantidad)
		## No existe	
		puts "solicitando podicto a bodega 7..."
		puts "solicitando podicto a bodega 7...OK"
	
	end
	
	def sol8(sku, cantidad)
		## Error no existe grupo, falta inscripcion de usuario y contraseña

		puts "solicitando podicto a bodega 8..."
		response= RestClient.post "http://integra8.ing.puc.cl/api/pedirProducto",{'usuario' => "grupo6", 'password' => "ebdf1bdb858ced98b4adef024c3ec86fbdc141c9",'SKU' => sku,'cantidad' => cantidad,'almacen_id' => "53571d98682f95b80b774860"}, {}
		data=JSON.parse(response)	
		puts data
		puts "solicitando podicto a bodega 8...OK"

		return data["cantidad"]
			
	
	end
	
	def sol9(sku, cantidad)
	## No existe
		puts "solicitando podicto a bodega 9..."
		puts "solicitando podicto a bodega 9...OK"

	end
	



end
gestor = OtrasBodegasController.new
#puts gestor.sol5("3812776", "1")
puts gestor.solicitarProducto("3548644", 1)