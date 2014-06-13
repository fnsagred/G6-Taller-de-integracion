require 'mongo'
require 'pp'   ## solo para queries que se trabaja con pointers
include Mongo


#Modificaciones
host = 'localhost'
port =  MongoClient::DEFAULT_PORT        
database = MongoClient.new(host, port).db('ruby-mongo')
ventas = database.collection('Ventas')
cursorVentas = ventas.find.to_a

idPedido = 0
listaClientes = []
cursorVentas.each do |venta|
	if idPedido != venta["Idpedido"].to_i 
		listaClientes << venta["Organizacion"]
		idPedido = venta["Idpedido"].to_i 
	end	
end

buzzword_counts = Hash.new({ value: 0 })
listaClientes.each do |i|
	buzzword_counts[i] = { label: i, value: (buzzword_counts[i][:value] + 1) }
end	
buzzword_counts.sort {|a,b| b[1][1].to_i}
send_event('buzzwords', { items: buzzword_counts.values })

SCHEDULER.every '3600s' do

  
  send_event('buzzwords', { items: buzzword_counts.values })
end
