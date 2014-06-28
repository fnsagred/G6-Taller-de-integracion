require 'csv'
require 'time'    


class Pricing

	def initialize()
		@ID=[]
		@SKU=[]
		@Precio=[]
		@FechaActual=[]
		@FechaVigencia=[]
		@CostoProducto=[]
		@CostoTraspaso=[]
		@CostoAlmacenajeExt=[]	
		@path="C:/Users/Administrator/Dropbox/Grupo6/Pricing.csv"
		@ofertas=[]
		#@sm= Products.new
		Actualizar()
		a=Thread.new {eliminarObsoletas()}
		a.run
	end


	def setOferta(sku, precio, fechaInicio, fechaTermino)
		for i in 0.. @ofertas.size-1
			if @ofertas[i]==nil
				@ofertas[i]=[sku.to_i, precio, fechaInicio, fechaTermino]
				return true
			end
		end
		@ofertas[@ofertas.size]=[sku, precio, fechaInicio, fechaTermino]
	end

	def eliminarObsoletas()

			tempTime=Time.now - Time.parse('1970-01-01 00:00:00')
			for	i in 0.. @ofertas.size-1
				if @ofertas[i][3].to_i<tempTime
					 @ofertas.delete(@ofertas[i])
					 #ACA HAY QUE SETEAR EL PRECIO DEL SPREE EN EL PRECIO NORMAL DEL PRICING PORQUE LA OFERTA YA VENCIO !!!!
					 #@sm.setInitPrice(@ofertas[i][0])
				end
			end
			
		
	end
	def getLista()
		return @ofertas
	end
	def Actualizar()
		data = []
		CSV.foreach(File.path(@path)) do |col|
	    	data << [col[0] + " " + col[1] + " " + col[2] + " " + col[3] + " " + col[4] + " " + col[5] + " " + col[6]+ " " + col[7]]
		end
		i=0
		temp=[8]
		data.each do |ttp|
			temp = ttp.to_s.tr('[','').tr('"','').tr(']','').split(" ")
			@ID[i]=temp[0]
			@SKU[i]=temp[1].to_i
			@Precio[i]=temp[2]
			@FechaActual[i]=temp[3]
			@FechaVigencia[i]=temp[4]
			@CostoProducto[i]=temp[5]
			@CostoTraspaso[i]=temp[6]
			@CostoAlmacenajeExt[i]=temp[7]
			i = i + 1
		end		
	end

	def getPrecio(temp_SKU)#String
		tempTime=Time.now - Time.parse('1970-01-01 00:00:00')
		for i in 0.. @ofertas.size-1
			if @ofertas[i][0]==temp_SKU.to_i
				if @ofertas[i][2]<=tempTime and @ofertas[i][3]>tempTime
					return  @ofertas[i][1]
				end
			end
		end

		if @SKU.include? temp_SKU.to_i
			return @Precio[@SKU.index(temp_SKU.to_i).to_i]
		else
			return 0
		end
	end

	def getFechaActual(temp_SKU)#String
		if @SKU.include? temp_SKU.to_i
			return @FechaActual[@SKU.index(temp_SKU.to_i).to_i]
		else
			return 'false'
		end
	end

	def getFechaVigencia(temp_SKU)#String
		if @SKU.include? temp_SKU.to_i
			return @FechaVigencia[@SKU.index(temp_SKU.to_i).to_i]
		else
			return 0
		end
	end

	def getCostoProducto(temp_SKU)#String
		if @SKU.include? temp_SKU.to_i
			return @CostoProducto[@SKU.index(temp_SKU.to_i).to_i]
		else
			return 0
		end
	end

	def getCostoTraspaso(temp_SKU)#String
		if @SKU.include? temp_SKU.to_i
			return @CostoTraspaso[@SKU.index(temp_SKU.to_i).to_i]
		else
			return 0
		end
	end

	def getCostoAlmacenExt(temp_SKU)#String
		if @SKU.include? temp_SKU.to_i
			return @CostoAlmacenajeExt[@SKU.index(temp_SKU.to_i).to_i]
		else
			return 0
		end
	end
end
#Retorna false si el SKU indicado no existe
#Se puede ingresar SKU de la forma "3661672" o tambien "000003661672" ya que los traspasa a int antes de buscarlo

#Se debe actualizar el PATH para abrir el CSV
#Se debe instalar access2csv, java y correr sucecivamente el comando java -jar access2csv.jar DBPrecios.accdb
