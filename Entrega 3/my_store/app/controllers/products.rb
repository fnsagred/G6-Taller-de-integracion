require 'active_record'
require './GestorDW.rb'
require './Pricing.rb'
require './Gestorbodegatest.rb'
class Products < ActiveRecord::Base


sistemaPricing = Pricing.new()
sistemaBodega= GestorStockController.new
sistemaDW= GestorDW.new

##1	
	def self.loadSpree(file)
		archivo=File.read(file)
		JSON.parse(archivo).each do |item|
			producto=Spree::Product.create(:name=>item['modelo'],:price=>item['precio']['internet'],:sku=>item['sku'],:description=>item['descripcion'],:shipping_category_id=>1)
			producto.available_on=Time.now
			producto.save
			Spree::Image.create({:attachment => open(URI.parse(item['imagen'])),:viewable => producto.master})
		end
	end	

##2
	def self.setBackorderable(file)
		archivo=File.read(file)
		JSON.parse(archivo).each do |item|
			if(Spree::Variant.find_by_sku(item['sku']))
				item.backorderable = false
				item.save
			end
		end
	end
=begin
	def self.setBackorderable()
		Spree::StockItem.each do |item|
			item.backorderable = false
			item.save
		end
	end
=end

	def self.setStock(sku, cantidad)
		tem = Spree::Variant.find_by_sku(sku)
		producto = Spree::Product.find(tem.product_id)
		stock_item = Spree::StockItem.find_by_variant_id(tem.id)
		stock_item.set_count_on_hand(cantidad)
		stock_item.save
		producto.description = producto.description[0, producto.description.length - 2]
		producto.description = producto.description + cantidad.to_s
		producto.save
	end

	def self.setPrice(sku, precio)
		tem = Spree::Variant.find_by_sku(sku)
		prod = Spree::Product.find(tem.product_id)
		prod.price = precio
		prod.save
	end


##3
	def self.startStockProducts(file)
		archivo=File.read(file)
		JSON.parse(archivo).each do |item|
			if(Spree::Variant.find_by_sku(item['sku']))
				variant = Spree::Variant.find_by_sku(item['sku'])
				producto = Spree::Product.find(variant.product_id)
				stock_item = Spree::StockItem.find_by_variant_id(variant.id)
				stock = sistemaBodega.contarSkuBodega(variant.sku)
				stock_item.set_count_on_hand(stock)
				stock_item.save
				producto.description = producto.description + " " + "Stock: "+ stock.to_s
				producto.save
			end
		end
	end
=begin
	def self.startStockProducts()
		Spree::Variant.each do |item|	
			producto = Spree::Product.find(item.product_id)
			stock_item = Spree::StockItem.find_by_variant_id(item.id)
			stock = sistemaBodega.contarSkuBodega(item.sku)
			stock_item.set_count_on_hand(stock)
			stock_item.save
			producto.description = producto.description + " " + "Stock: "+ stock.to_s
			producto.save
		end
	end
=end

=begin
	def self.startProducts(file)
		archivo=File.read(file)
		sistemaBodega = GestorStockController.new
		JSON.parse(archivo).each do |item|
			sku = item['sku']
			stock = sistemaBodega.contarSkuBodega(sku)
			tem = Spree::Variant.find_by_sku(sku)
			producto = Spree::Product.find(tem.product_id)
			stock_item = Spree::StockItem.find_by_variant_id(tem.id)
			stock_item.set_count_on_hand(stock)
			stock_item.save
			producto.description = producto.description + " " + "Stock: "+ stock.to_s
			producto.save
		end
	end
=end

	def self.setInitPrice(sku)
		archivo=File.read('productos.json')
		precio = 0
		JSON.parse(archivo).each do |item|
			if item['sku'] == sku
				precio = item['precio']['internet']
				tem = Spree::Variant.find_by_sku(sku)
				producto = Spree::Product.find(tem.product_id)
				producto.price = precio
				producto.save
				break
			end
		end
	end



	##Batches
	def self.batchSpreeStock(file)
		archivo=File.read(file)
		JSON.parse(archivo).each do |item|
			if(Spree::Variant.find_by_sku(item['sku']))	
				variant = Spree::Variant.find_by_sku(item['sku'])
				producto = Spree::Product.find(variant.product_id)
				stock_item = Spree::StockItem.find_by_variant_id(variant.id)
				stock = sistemaBodega.contarSkuBodega(variant.sku)
				stock_item.set_count_on_hand(stock)
				producto.description = producto.description[0, producto.description.length - 2]
				producto.description = producto.description + cantidad.to_s
				stock_item.save
				producto.save
			end	
		end
	end
=begin	
	def self.batchSpreeStock()
		Spree::Variant.each do |item|	
			producto = Spree::Product.find(item.product_id)
			stock_item = Spree::StockItem.find_by_variant_id(item.id)
			stock = sistemaBodega.contarSkuBodega(item.sku)
			stock_item.set_count_on_hand(stock)
			producto.description = producto.description[0, producto.description.length - 2]
			producto.description = producto.description + cantidad.to_s
			stock_item.save
			producto.save
		end
	end
=end

	def self.batchGestionStock(file)
		archivo=File.read(file)
		JSON.parse(archivo).each do |item|
			if(Spree::Variant.find_by_sku(item['sku']))	
				variant = Spree::Variant.find_by_sku(item['sku'])
				producto = Spree::Product.find(variant.product_id)
				stock_item = Spree::StockItem.find_by_variant_id(variant.id)
				stock1 = stock_item.count_on_hand
				stock2 = sistemaBodega.contarSkuBodega(variant.sku)
				if ((stock2 - stock1) > 0)
					despachocorrecto=sistemaBodega.despacharProductosCliente(item.sku, stock, "Spree Commerce", producto.price, pedidoId)
					puts "Despacho " + despachocorrecto.to_s + " para sku: " + item.sku.to_s
				end
			end
		end
	end
=begin
	def self.batchGestionStock()
		Spree::Variant.each do |item|	
			producto = Spree::Product.find(item.product_id)
			stock_item = Spree::StockItem.find_by_variant_id(item.id)
			stock1 = stock_item.count_on_hand
			stock2 = sistemaBodega.contarSkuBodega(item.sku)
			if ((stock2 - stock1) > 0)
				despachocorrecto=sistemaBodega.despacharProductosCliente(item.sku, stock, "Spree Commerce", producto.price, pedidoId)
				puts "Despacho " + despachocorrecto.to_s + " para sku: " + item.sku.to_s
			end
		end
	end
=end
	def self.batchPrice()
	end


	def self.getOrders()
		Spree::Order.each do |item|
			idpedido = item.id
			direccion = (Spree::Address.find(item.ship_address_id)).to_s
			cliente = item.email
			organizacion = "ecommerce"
			item.line_items.all.each do |subitem|
				sku = subitem.variant.sku
				cantidad = subitem.quantity
				precio = Spree::Product.find(subitem.variant.product_id).price
				productos = Array({:SKU => sku, :Cantidad => cantidad, :VentaTotal=>((cantidad.to_i)*precio.to_i).to_s})			
				sistemaDW.insertVenta(idpedido, productos, direccion, cliente,organizacion)
			end	
		end
	end


end