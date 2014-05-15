require 'net/sftp'
require 'net/ssh'
require 'active_support/all'


#Fernando Suarez
class SFTPManager

  attr_accessor :daily, :incluidos #ES LA STACK CON LOS PEDIDOS DEL DIA, EN EL CONTROLLER DEBIESE SER RENOVADO A DIARIO

  def initialize
    self.daily = Array.new
    self.incluidos=Array.new

  end


  def Iniciar

    while true do  #cada 5 minutos
      Net::SFTP.start('integra.ing.puc.cl', 'grupo6',:password => 'ijhgf13') do |sftp| #CONECTO A SFTP

      sftp.dir.foreach("/home/grupo6/Pedidos") do |entry| #ITERO SOBRE TODOS LOS ARCHIVOS EN PEDIDOS

        nombre=entry.name


        if nombre!="."&&nombre!=".."

          pid=(nombre.split('_')[1]).split('.')[0]       #GUARDO ID DEL PEDIDO
          data = sftp.download!("/home/grupo6/Pedidos/"+entry.name)
          object_hash = Hash.from_xml(data)

          if object_hash['xml']['Pedidos']['fecha'][1].to_s==Time.now.strftime("%Y-%m-%d")&&!incluidos.include?(pid) #SI ES DE HOY, LO GUARDO

            incluidos.push(pid)
            pedido = [pid, object_hash['xml']['Pedidos']]
            daily.push(pedido)

          end


        end


      end

      end

      sleep(300) #Cada 5 minutos me vuelvo a conectar al sftp

  end


  end


  def  getNext


    aux=daily.pop
    #Aca debiese BORRAR el archivo del SFPT, dle stack daily y de la lista incluidos
    return aux

  end



end