# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron


#Spree batch methods
every 1.minute do
  runner "Product.setStockSpree()"
  runner "Product.setGestorBodegaStock()"
end

