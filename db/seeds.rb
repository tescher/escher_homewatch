# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

SensorType.create([{ name:"xbee temp", offset: 0.0, scale: 1.0 }, { name: "ds18s20 temp", offset: 0.0, scale: 1.0 }, { name: "generic", offset: 0.0, scale: 1.0 }, { name: "TED5000", offset: 0.0, scale: 1.0 } ])

