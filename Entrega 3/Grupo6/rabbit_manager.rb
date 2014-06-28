require "bunny"
class RabbitManager


  attr_accessor :ofertas
  attr_accessor :reposicion
  attr_accessor :conexion

  def initialize

  end


  def Actualizar
    self.conexion = Bunny.new('amqp://eipzmgtf:z2eMua1JZtMgkOBw9qbP8EpKRHB8-8ik@hyena.rmq.cloudamqp.com/eipzmgtf')
    self.conexion.start

    self.ofertas = conexion.queue("ofertas", :auto_delete => true)
    self.reposicion =conexion.queue("reposicion", :auto_delete => true)

  end



  def Send(mensaje)

    ch   = self.conexion.create_channel
    q    = ch.queue("ofertas", :auto_delete => true)
    ch.default_exchange.publish(mensaje, :routing_key => q.name)
    puts " Enviado: "+mensaje

if mensaje==""
    self.conexion.close
end


  end



  def PopOferta

    msg = self.ofertas.pop


=begin if msg[2].to_s==""
    self.conexion.stop
    end
=end

    return msg[2].to_s


  end

  def PopReposicion

    msg = self.reposicion.pop


    if msg[2].to_s==""
      self.conexion.stop
    end


    return msg[2].to_s


  end




  def Desconectar
    self.conexion.stop
  end

end