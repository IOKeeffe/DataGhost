require_relative '../lib/sql_object'
require_relative '../lib/db_connection'
class Spaceship < SQLObject
  belongs_to :alien
  self.finalize!
end

class Planet < SQLObject
  has_many :aliens
  self.finalize!
end

class Alien < SQLObject
  belongs_to :planet,
    class_name: "Planet",
    foreign_key: :planet_id,
    primary_key: :id

  self.finalize!
end

p "Creating sample database"
p DBConnection.create_sample_db
p "Executing alien fetch (Alien.all)"
p Alien.all
p "Finding planet of first alien (Alien.first.planet)"
p Alien.first.planet
p "Creating new Planet named 'Bimble' (Planet.new(name: 'Bimble').save)"
p Planet.new(name: "Bimble").save
