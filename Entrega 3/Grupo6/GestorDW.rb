## Para dejar el servidor de mongodb corriendo...
##http://docs.mongodb.org/manual/tutorial/install-mongodb-on-windows/         ojo: acordarse de crear las carpetas en donde van las bases de datos

##Para cargarlo en ruby:   https://github.com/mongodb/mongo-ruby-driver/wiki/Tutorial
## luego de instaladas las gemas    bundle install    bundle update



require 'mongo'
require 'pp'   ## solo para queries que se trabaja con pointers
include Mongo

class GestorDW
	
	def initialize()
		@host = 'localhost'
		@port =  MongoClient::DEFAULT_PORT
        
		@db = MongoClient.new(@host, @port).db('ruby-mongo')
		puts "Connected to #{@host}:#{@port}"
		@idventa = findAll('Ventas').size()+1
		@idquiebre = findAll('Quiebres').size()+1
		


	end
	def getIdVenta()
		return @idventa
	end
	def getIdQuiebre()
		return @idquiebre
	end
	def getHost()
		puts "Host: #{@host}"
		
		return @host
	end
	def getPort()
		puts "Port: #{@port}"
		
		return @port
	end
	def findAll(coll)

		coll= @db.collection(coll)
		cursor = coll.find.to_a
		##pp cursor
		return cursor 
        
      ##puts cursor[0] ##el elementoi
	end
	def insertVenta(idpedido, productos, dir, cliente,org)
		puts "Insertando Venta..."
		puts "Pedido: #{idpedido},  idCliente: #{cliente},  Direccion: #{dir} , \nProductos: #{productos}"
		@db.collection('Ventas').insert('Id' => @idventa,'Idpedido' => idpedido, 'Fecha-hora'=> Time.now,'Productos'=> productos, 'Direccion'=>dir,'Organizacion'=>org ,'Cliente'=> cliente)
		@idventa= @idventa+1
		return @idventa-1
##		
	end
	#identificacion del grupo numero de grupo
#nombre archivo
#producto(sku)
#cantidad
#idbodegadestino(bedega de recepcion del otro grupo)

	def insertTraspasosBodegas(idgrupo, nombrearchivo, idbodegadestino, cantidad, productos, dir)
		puts "Insertando TraspasosBodegas..."
		@db.collection('TraspasosBodegas').insert('Idgrupo' => idgrupo,'NombreArchivo' => nombrearchivo, 'IdBodegaDestino' => idbodegadestino, 'Fecha-hora'=> Time.now,'Productos'=> productos, 'Cantidad'=> cantidad)
		@db.collection('Ventas').insert('Id' => @idventa,'Idpedido' => idbodegadestino, 'Fecha-hora'=> Time.now,'Productos'=> productos, 'Direccion'=>dir,'Organizacion'=> ("Grupo " + idgrupo.to_s) ,'Cliente'=> idgrupo)
		@idventa= @idventa+1
		return @idventa-1
##		
	end
	def insertQuiebre(idpedido, productos, cliente)
		puts "Insertando quiebre..."
		puts "Pedido: #{idpedido},  idCliente: #{cliente} \nProductos: #{productos}"
		@db.collection('Quiebres').insert('Id' => @idquiebre,'Idpedido' => idpedido, 'Fecha-hora'=> Time.now,'Productos'=> productos, 'Cliente'=> cliente)
		@idquiebre= @idquiebre+1
		return @idquiebre-1
##		
	end
	def insertPedido(id,fecha, productos, cliente, dirpedido )
		puts "Insertando pedido..."
		puts "Pedido: #{id} , Fecha-despacho: #{fecha}, Cliente: #{cliente},  Direccion: #{dirpedido} \nProductos: #{productos}"
		@db.collection('Pedidos').insert('IdPedido' => id, 'Fecha-ingresodespacho'=>fecha,'Cliente'=>cliente, 'DireccionId'=> dirpedido.to_s, 'Productos'=> productos)
		return id

##		##productos es un arreglo de :{SKU:int , Cantidad: int}		
	end
	def clearCollection(collection)
		@db.collection(collection).remove
	end
	def getCollections()
		p @db.collection_names
		return @db.collection_names
	end
	def getCollection(nombre)
		
		return @db.collection(nombre)
	end
	def insertIntoFile(data, file)
		grid = Grid.new(@db)
		# Write a new file. data can be a string or an io object responding to #read.
		id = grid.put(data, :filename => file)
		# Read it and print out the contents
		file = grid.get(id)
		puts file.read
	end
	def crearCollecion()

		@db.collection('Pedidos')
		@db.collection('Ventas')
		@db.collection('Quiebres')
		@db.collection('TraspasosBodegas')
	end
	def clearAllCollecion()

		@db.collection('Pedidos').remove
		@db.collection('Ventas').remove
		@db.collection('Quiebres').remove
		@db.collection('TraspasosBodegas').remove

	end

end
gestordw = GestorDW.new()
gestordw.clearCollection('Quiebre')
pp gestordw.getCollections()
pp gestordw.findAll('Quiebres')
pp gestordw.findAll('Ventas')
pp gestordw.findAll('Pedidos')

#gestordw.clearAllCollecion()
#gestordw.crearCollecion()

##gestordw.clearCollection('Quiebre')
##gestordw.insertIntoFile("hello, world", 'hello.txt')
##gestordw.getCollections()
##gestordw.findAll('fs.files')  ## obtiene todos los archivos guardados en el dw
##gestordw.findAll('system.indexes')  ##Obtiene bases de datos del dw
##gestordw.findAll('fs.chunks')



##Prueba de agregar pedido
##gestordw.insertPedido(Time.now, Array({:SKU => '1234', :Cantidad =>'7'}),"a")
##pp gestordw.findAll("Pedidos")



##Prueba de agregar quiebre
##gestordw.insertQuiebre(5, Array({:SKU => '456', :Cantidad =>'3', :PerdidaTotal=>'9000'}),"Tu" )

##pp gestordw.findAll('Quiebre')




## mantener loop infinito
=begin
while(1)
	puts "asd"
	sleep(1)
end
=end


##gestordw.getCollections()
##puts Time.now
