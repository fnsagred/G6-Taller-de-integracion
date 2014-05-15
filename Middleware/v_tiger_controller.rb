require 'net/http'
require 'rubygems'
require 'json'
require 'pp'
require 'digest'
require "net/http"
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


  def getDireccion(rut) #Retorna la direccion, ciudad y region de la empresa. Separados por comas. El parametro es el rut


    query=URI::encode("select * from Accounts where cf_705='"+rut+"';")  #where rut='"+rut+"';"
    getQuery= endpoint+"operation=query"+"&"+"sessionName="+self.SessionName+"&"+"query="+query
    resp2=Net::HTTP.get_response(URI.parse(getQuery))
    data2=resp2.body
    obj2=JSON.parse(data2)
    direccion=obj2["result"][0]["bill_street"]
    region=obj2["result"][0]["bill_state"]
    ciudad=obj2["result"][0]["bill_city"]
    puts "Direccion extraída"
    return direccion + ", " + ciudad + ", " + region

  end






end