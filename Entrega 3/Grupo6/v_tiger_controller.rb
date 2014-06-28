require 'net/http'
require 'rubygems'
require 'json'
require 'pp'
require 'digest'
require "uri"
require 'open-uri'

##Fernando Suárez
class VTigerController

  attr_accessor :username,:AccessKey, :endpoint, :SessionName, :UserId, :ChallengeToken

  def initialize   #Inicializa un objeto VTigerController, de la manera VTigerController.new



    self.username="grupo6"
    self.AccessKey="YeIzEm4ergJEdgx"
    self.endpoint ="http://integra.ing.puc.cl/vtigerCRM/webservice.php?"

    @getChallenge= self.endpoint+"operation=getchallenge"+"&"+"username="+self.username
    resp0 = Net::HTTP.get_response(URI.parse(@getChallenge))  # get_response takes an URI object
    data0 = resp0.body
    obj0 = JSON.parse(data0)
    self.ChallengeToken=obj0["result"]["token"]  #Saco la challenge token



    @AccessKeyAux=Digest::MD5.hexdigest(self.ChallengeToken+self.AccessKey)
    getLogin=self.endpoint+"operation=login"+"&"+"username="+self.username+"&"+"accessKey="+@AccessKeyAux
    uri = URI.parse(self.endpoint+"operation=login")
    resp1 = Net::HTTP.post_form(uri, {"username" => self.username, "accessKey" => @AccessKeyAux})
    data1=resp1.body
    obj1=JSON.parse(data1)
    self.SessionName=obj1["result"]["sessionName"]  #Saco el session name
    self.UserId=obj1["result"]["userId"]            #Saco el user ID
    puts "Sesion iniciada"
    puts "Challenge Token: "+ self.ChallengeToken
    puts "AccessKey: "+self.AccessKey
    puts "AccessKeyAux: "+@AccessKeyAux
    puts "Session Name: "+self.SessionName
    puts "User Id: "+self.UserId

  end



  def getTypes


    @getTypes= self.endpoint+"operation=listtypes"+"&"+"sessionName="+self.SessionName
    resp3 = Net::HTTP.get_response(URI.parse(@getTypes))  # get_response takes an URI object
    data3 = resp3 .body
    puts data3


  end



  def getOrganizacion(rut) #Retorna el nombre de la organizacion. El parametro es el rut


    query1=URI::encode("select * from Accounts where cf_705='"+rut+"';")  #where rut='"+rut+"';"
    getQuery1= endpoint+"operation=query"+"&"+"sessionName="+self.SessionName+"&"+"query="+query1
    resp4=Net::HTTP.get_response(URI.parse(getQuery1))
    data4=resp4.body
    obj4=JSON.parse(data4)
    organizacion=obj4["result"][0]["accountname"]
    puts "Nombre de Organizacion extraido"
    puts organizacion
    return organizacion

  end



  def getDireccion(direccionId) #Retorna la direccion, ciudad y region del pedido. Separados por comas. El parametro es la id de direccion

    #query=URI::encode("select * from Contacts ;")
    query=URI::encode("select * from Contacts where cf_707='"+direccionId+"';")  #where rut='"+rut+"';"
    getQuery= endpoint+"operation=query"+"&"+"sessionName="+self.SessionName+"&"+"query="+query
    resp2=Net::HTTP.get_response(URI.parse(getQuery))
    data2=resp2.body
    obj2=JSON.parse(data2)
    direccion=obj2["result"][0]["otherstreet"]
    region=obj2["result"][0]["otherstate"]
    ciudad=obj2["result"][0]["othercity"]
    puts "Direccion extraida"
    return direccion + ", " + ciudad + ", " + region

  end




end