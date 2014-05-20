class PedidosExternosController

  attr_accessor :daily, :incluidos

  def initialize
    self.daily = Array.new
    self.incluidos=Array.new

  end


  def Actualizar  #ACTUALIZA LOS PEDIDOS DE OTRAS BODEGAS


    for i in 1..9

     if i!=6
        Dir.foreach('C:\pedidos_bodegas_ftp\Grupo'+i.to_s) do |item|
          next if item == '.' or item == '..' or item=='.DS_Store'
      # do work on real items

      pid=(item.to_s.split('_')[1]).split('.')[0]

      object_hash = Hash.from_xml(File.read('C:\pedidos_bodegas_ftp\Grupo'+i.to_s+'/'+item))


          if object_hash['xml']['Pedidos']['fecha'].to_s==Time.now.strftime("%Y-%m-%d")&&!incluidos.include?(pid) #SI ES DE HOY, LO GUARDO

        self.incluidos.push(pid)
        pedido = [pid, object_hash['xml']['Pedidos']]
        self.daily.push(pedido)

          end


         end

      end

    end

  end


  def  getNext #ENTREGA UN ARREGLO DE 2 DIMENSIONES [0] ES LA ID DEL PROXIMO PEDIDO [1] ES UN HASH CON EL PROXIMO PEDIDO


    aux=self.daily.pop
    #Aca debiese BORRAR el archivo del SFPT, deL stack daily y de la lista incluidos
    return aux

  end



end