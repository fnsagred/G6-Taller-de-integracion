
require 'twitter'
class TwitterManager

  attr_accessor :cliente


  def initialize

  end


  def Actualizar

    self.cliente = Twitter::REST::Client.new do |config|
      config.consumer_key        = "NN7gpSboVsh2QKcXie2w8Vl35"
      config.consumer_secret     = "UXIhk5bnopbbkGaqwxJFVaOFVA1RNeEAMtgSAiYISpMugDJxK0"
      config.access_token        = "2581077127-DyfphA4CRqDlZJclZQWBIY6D92CJtZi20lwI2So"
      config.access_token_secret = "xJkmDCRzfmy9FSnKkysUvXvuV15x0J0GTg1ghWRKkvMKm"
      
      
    end

  end





  def Tweet(mensaje)

  self.cliente.update(mensaje)

  end


end