require 'mongo'
require 'pp'   ## solo para queries que se trabaja con pointers
include Mongo


#Modificaciones
host = 'localhost'
port =  MongoClient::DEFAULT_PORT        
database = MongoClient.new(host, port).db('ruby-mongo')
ventas = database.collection('Ventas')
quiebres = database.collection('Quiebre')
pedidos = database.collection('Pedidos')


cursorVentas = ventas.find.to_a
points = []

(1..10).each do |i|
	ventaActual = cursorVentas[i]
	points << { x: i, y: ((ventaActual["Productos"].to_a)[2])[1].to_i }
end
last_x = points.last[:x]

SCHEDULER.every '2s' do
	ventas = database.collection('Ventas')
	cursorVentas = ventas.find.to_a
	if ventas.count > last_x
		points.shift
		last_x += 1
		last_y = cursorVentas[last_x]
		points << { x: last_x, y: ((last_y["Productos"].to_a)[2])[1].to_i }
	end
	send_event('convergence', points: points)
end
