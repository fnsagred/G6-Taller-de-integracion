require 'mongo'
require 'pp'   ## solo para queries que se trabaja con pointers
include Mongo

current_valuation = 0
current_karma = 0

#Modificaciones
host = 'localhost'
port =  MongoClient::DEFAULT_PORT
        
database = MongoClient.new(host, port).db('ruby-mongo')
ventas = database.collection('Ventas')
quiebres = database.collection('Quiebres')
pedidos = database.collection('Pedidos')

cursorVentas = ventas.find.to_a
cursorQuiebres = quiebres.find.to_a


montoVentasDelDia = 0
cursorVentas.each {|i| montoVentasDelDia += ((i["Productos"].to_a)[2])[1].to_i}
send_event('valuation', { current: montoVentasDelDia, last: 0 })
send_event('synergy',   { value: ((ventas.count*100)/(ventas.count+quiebres.count)).to_i })


#Repetidor cada hora
SCHEDULER.every '3600s' do
	last_karma = current_karma
	current_karma = rand(200000)

  ventas = database.collection('Ventas')
  quiebres = database.collection('Quiebres')
  cursorVentas = ventas.find.to_a
  cursorQuiebres = quiebres.find.to_a

  cantidadVentas = ventas.count
  cantidadQuiebres = quiebres.count
  cantidadPedidos = cantidadQuiebres + cantidadVentas

  lastMontoVentasDelDia = montoVentasDelDia 
  montoVentasDelDia = 0
  cursorVentas.each {|i| montoVentasDelDia += ((i["Productos"].to_a)[2])[1].to_i}

	send_event('valuation', { current: montoVentasDelDia, last: lastMontoVentasDelDia })
	end_event('karma', { current: current_karma, last: last_karma })
	send_event('synergy',   { value: ((cantidadVentas*100)/cantidadPedidos).to_i })
end

##SCHEDULER.every '2s' do
  ##last_valuation = current_valuation
  ##last_karma     = current_karma
  ##current_valuation = rand(100)
  ##current_karma     = rand(200000)

  ##send_event('valuation', { current: current_valuation, last: last_valuation })
  ##send_event('karma', { current: current_karma, last: last_karma })
  ##send_event('synergy',   { value: rand(100) })


