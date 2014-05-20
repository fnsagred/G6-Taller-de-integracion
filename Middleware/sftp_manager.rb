require 'net/sftp'
require 'net/ssh'
require 'active_support/all'
require './GestorDW.rb'

#Fernando Suarez
class SFTPManager

  attr_accessor :daily, :incluidos, :ingresados #ES LA STACK CON LOS PEDIDOS DEL DIA, EN EL CONTROLLER DEBIESE SER RENOVADO A DIARIO

  def initialize
    self.daily = Array.new
    self.incluidos=Array.new
    self.ingresados=Array.new

  end


  def Actualizar


    Net::SFTP.start('integra.ing.puc.cl', 'grupo6',:password => 'ijhgf13') do |sftp| #CONECTO A SFTP
      sftp.dir.foreach("/home/grupo6/Pedidos") do |entry| #ITERO SOBRE TODOS LOS ARCHIVOS EN PEDIDOS

        nombre=entry.name


        if nombre!="."&&nombre!=".."

          pid=(nombre.split('_')[1]).split('.')[0]       #GUARDO ID DEL PEDIDO
          data = sftp.download!("/home/grupo6/Pedidos/"+entry.name)
          object_hash = Hash.from_xml(data)

          if object_hash['xml']['Pedidos']['fecha'][0]<=Time.now.strftime("%Y-%m-%d")&&!ingresados.include?(pid) #SI ES DE HOY, LO GUARDO

            self.ingresados.push(pid)
            pedido = [pid, object_hash['xml']['Pedidos']] #HASH CON EL PEDIDO

            ##PABLO ACA PUEDES INGRESAR EL OBJETO pedido al DATA WAREHOUSE
            #self.daily.push(pedido)

           begin
             sistemaDW= GestorDW.new
             for i in 0.. pedido[1]['Pedido'].size()-1
               skuTemp=((pedido[1]['Pedido'][i]['sku']).to_i).to_s
               cant=(pedido[1]['Pedido'][i]['cantidad']).to_s
               idcliente=pedido[1]['rut'].to_s
               dirpedido= pedido[1]['direccionId'].to_s
               fecha= pedido[1]['fecha'].to_s
                sistemaDW.insertPedido((pedido[0].to_i).to_s, fecha ,Array({:SKU => skuTemp, :Cantidad => cant}),idcliente, dirpedido)
             end
            rescue
             puts "Error al registrar pedido"
           end
          end



          if object_hash['xml']['Pedidos']['fecha'][1]<=Time.now.strftime("%Y-%m-%d")&&!incluidos.include?(pid) #SI ES DE HOY, LO GUARDO

            self.incluidos.push(pid)
            pedido = [pid, object_hash['xml']['Pedidos']]
            self.daily.push(pedido)

          end


        end


      end

    end




  end


  def  getNext


    aux=daily.pop


    Net::SFTP.start('integra.ing.puc.cl', 'grupo6',:password => 'ijhgf13') do |sftp| #CONECTO A SFTP
   
        sftp.remove("/home/grupo6/Pedidos/pedido_"+aux[0].to_s+".xml")

    end

    self.incluidos.delete(aux[0])
    self.ingresados.delete(aux[0])
    
    return aux

  end



end