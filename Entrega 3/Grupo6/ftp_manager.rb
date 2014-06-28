require 'net/ftp'
class FTPManager

  attr_accessor :daily, :incluidos


  def initialize
    self.daily = Array.new
    self.incluidos=Array.new

  end




  def Actualizar

    Net::FTP.open('200.6.99.5','grupo6','$pass*2013') do |ftp|
     # files = ftp.list


      for i in 1..9

        if i!=6
          puts "conectado a FTP"
          files = ftp.nlst('\Grupo'+i.to_s)
a=0
puts "PASO"
          files.each do |file|

            pid=(file.to_s.split('_')[1]).split('.')[0]
            s='\Grupo'+i.to_s+'\\'+file


           object_hash = Hash.from_xml(ftp.getbinaryfile(s,nil, 1024))

            if object_hash['xml']['Pedidos']['fecha']<=Time.now.strftime("%Y-%m-%d")&&!incluidos.include?(pid)

              self.incluidos.push(pid)
              pedido = [pid, object_hash['xml']['Pedidos']]
              self.daily.push(pedido)

            end




            # some operations with doc
          end
        end

      end
      ftp.close
    end

  end


  def  getNext


    aux=self.daily.pop
    #Aca debiese BORRAR el archivo del FPT, dle stack daily y de la lista incluidos
    return aux

  end




end