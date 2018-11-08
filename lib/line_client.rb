require 'line/bot'
require 'net/https'
require 'uri'

class Akira
  class << self
    def obserbTemp
      uri = URI.parse('http://1899a3ca.ngrok.io/get')
      json = Net::HTTP.get(uri)
      result = JSON.parse(json)
      puts result
      puts "id: " + result['humi'].to_s
      puts "name: " + result['press'].to_s
      puts "name: " + result['temp'].to_s
    end
  end
end