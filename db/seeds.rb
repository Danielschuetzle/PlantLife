require 'open-uri'
require 'nokogiri'
require 'rest-client'
require 'faker'
require 'net/http'
require 'openssl'

User.destroy_all
puts "All Users destroyed"
Garden.destroy_all
puts "All Gardens destroyed"
MyPlant.destroy_all
puts "All MyPlants destroyed"
Action.destroy_all
puts "All Actions destroyed"
Plant.destroy_all
puts "All Plants destroyed"

garden_names = [
  "Outside",
  "Inside",
  "Office",
  "Terrace",
  "Bedroom",
  "Livingroom",
  "Bathroom"
]

# plant_names = [
#   "monstera deliciosa",
#   "ficus lyrata",
#   "yucca recurvifolia",
#   "cylindropuntia leptocaulis",
#   "abutilon palmeri",
#   "acacia farnesiana",
#   "ficus lyrata",
#   "angelonia angustifolia",
#   "prunus triloba",
#   "laurentia axillaris",
#   "dryopteris bushiana",
#   "stenotaphrum helferi",
#   "ferocactus histrix",
#   "acer campestre",
#   "acer spicatum",
#   "celosia plumosa",
#   "dianthus plumarius",
#   "prunus mume",
#   "fern",
#   "monstera friedrichsthalii"
# ]

User.create(email: "plant@life.com", password: "secret", first_name: "Bob", last_name: "Lovesplants")

# def create_plant(url)
#   plant_api_key = ENV['plant_api']
#   plant_hash = RestClient.get(url, {:Authorization => "Bearer #{plant_api_key}"})
#   common_name = JSON.parse(plant_hash)["alias"]
#   temperature = JSON.parse(plant_hash)["max_temp"].to_s
#   light = JSON.parse(plant_hash)["max_light_lux"].to_s
#   water = JSON.parse(plant_hash)["max_soil_moist"].to_s
#   soil = JSON.parse(plant_hash)["max_soil_ec"].to_s
#   scientific_name = JSON.parse(plant_hash)["display_pid"]
#   img = JSON.parse(plant_hash)["image_url"]
#   file = URI.open(img)
#   p (common_name: common_name, scientific_name: scientific_name, temperature: temperature, sun: light, water: water, soil: soil)
#   plant.photo.attach(io: file, filename: "img", content_type: 'image/jpg')
#   p plant.save
# end
# plant_names.each do |p|
#   url = "https://open.plantbook.io/api/v1/plant/detail/#{p}/".gsub(' ', '%20')
#   create_plant(url)
# end

url = URI("https://house-plants.p.rapidapi.com/all")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
request = Net::HTTP::Get.new(url)
request["X-RapidAPI-Host"] = 'house-plants.p.rapidapi.com'
request["X-RapidAPI-Key"] = ENV['PLANT_API']

response = http.request(request)
plants_array = JSON.parse(response.read_body)
p plants_array
plants_array.each do |plants_hash|
  plants_hash["tempmin"] = plants_hash["tempmin"]["celsius"].to_s + "C"
  plants_hash["tempmax"] = plants_hash["tempmax"]["celsius"].to_s + "C"
  plants_hash["common"] = plants_hash["common"].first || plants_hash["latin"]
  plants_hash.select! do |key, _value|
    Plant.column_names.include?(key) && key != "id"
  end

  Plant.create!(plants_hash)
end

3.times do
  Garden.create(name: garden_names.sample, user: User.last)
  5.times do
    file = URI.open("https://cdn.shopify.com/s/files/1/0591/2746/4141/products/857MonsteraRiesemitSTab-min.jpg")
    plant = MyPlant.create(garden: Garden.last,
      plant: Plant.all.sample,
      nickname: Faker::Name.first_name,
      last_watered: rand((DateTime.now - 2.weeks)..DateTime.now)
    )
    plant.photo.attach(
      io: file,
      filename: "#{plant[:nickname]}",
      content_type: 'image/png'

    )
    plant.save!
  end
end

# API STUFF WE NEED
# "latin":"Aeschynanthus lobianus" scientific
# "family":"Gesneriaceae" species
# "origin":"Java"
# "climate":"Tropical"
# "ideallight":"Bright light" sun
# "watering":"Keep moist between watering. Can be a bit dry between watering" watering
# "common" is an array use the first one
# "tempmax":{2 items temperature
# "celsius":32
# "tempmin":{2 items
# "celsius":14
