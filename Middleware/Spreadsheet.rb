require "rubygems"
require "google_drive"

class Spreadsheet
	
	def initialize()
	
		@SKU = []
		@Cliente = []
		@Cantidad = []
		@Utilizado = []

		
		@session = GoogleDrive.login("integra6.ing@gmail.com", "Integra6")
		@ws = @session.spreadsheet_by_key("0As9H3pQDLg79dEQxRE9MODBBb212b0Nxdk1yTTREY0E").worksheets[0]
		@Fecha = @ws[2,2] 

		i=0
		@productos=0
		cont = 5

		while true do
			if @ws[cont,1]==""
				break
			end
			@SKU[i] = @ws[cont,1].to_i
			@Cliente[i] = @ws[cont,2]
			@Cantidad[i] = @ws[cont,3]
			@Utilizado[i] = @ws[cont,4]
			i=i+1
			@productos=@productos+1
			cont = cont +1
		end

	end

	def Actualizar()
		@session = GoogleDrive.login("integra6.ing@gmail.com", "Integra6")
		@ws = @session.spreadsheet_by_key("0As9H3pQDLg79dEQxRE9MODBBb212b0Nxdk1yTTREY0E").worksheets[0]
		@Fecha = @ws[2,2] 

		i=0
		@productos=0
		cont = 5
		while true do
			if @ws[cont,1]==""
				break
			end
			@SKU[i] = @ws[cont,1].to_i
			@Cliente[i] = @ws[cont,2]
			@Cantidad[i] = @ws[cont,3]
			@Utilizado[i] = @ws[cont,4]
			i=i+1
			@productos=@productos+1
			cont = cont +1
		end
	end
	def PedirReserva(temp_SKU, temp_Cliente, cantidad)#String, String, int
		@session = GoogleDrive.login("integra6.ing@gmail.com", "Integra6")
		@ws = @session.spreadsheet_by_key("0As9H3pQDLg79dEQxRE9MODBBb212b0Nxdk1yTTREY0E").worksheets[0]
		i=0
		while @productos>i
			if (temp_SKU==@SKU[i].to_s and temp_Cliente==@Cliente[i].to_s)
				if (@Cantidad[i].to_i<(@Utilizado[i].to_i+cantidad))
					t = @Utilizado[i].to_i
					@Utilizado[i]=@Cantidad[i]
					@ws[i+5,4]=@Cantidad[i]
					@ws.save()
					return @Cantidad[i].to_i-t
				else
					@ws[i+5,4]=(@Utilizado[i].to_i+cantidad.to_i).to_s
					@ws.save()
					return cantidad
				end
			end
			i=i+1
		end

	end

	def getCliente(temp_SKU)
		if @SKU.include? temp_SKU.to_i
			return @Cliente[@SKU.index(temp_SKU.to_i).to_i]
		else
			return "false"
		end
	end

	def getCantidad(temp_SKU)
		if @SKU.include? temp_SKU.to_i
			return @Cantidad[@SKU.index(temp_SKU.to_i).to_i]
		else
			return "false"
		end
	end

	def getUtilizado(temp_SKU)
		if @SKU.include? temp_SKU.to_i
			return @Utilizado[@SKU.index(temp_SKU.to_i).to_i]
		else
			return "false"
		end
	end
	def getFecha()
		return @Fecha
	end
end



#Retorna false si el SKU indicado no existe
#Se puede ingresar SKU de la forma "3661672" o tambien "000003661672" ya que los traspasa a int antes de buscarlo

#Se debe instalar la gema de google_drive 'gem install google_drive'