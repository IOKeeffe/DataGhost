# DataGhost
## Introduction
DataGhost is an Object Relational Mapping framework written in Ruby. It is designed to make it easier to retrieve and manipulate Database entries in Ruby. By converting Databases entries to Ruby objects and handling much of the functionality of primary and foreign key mapping, database processing is made simple.

##Setup
To set up the instance of DataGhost, first open a SQLite3 database file by calling `DBConnection.open(FILE_NAME)`. To get acclimated, just load demo.rb in any IRB. This will setup a sample database of Aliens, Spaceships, and Planets. You can play around with different queries using DataGhost's intuitive interface.

## SQL Object
The `SQLObject` is the basic unit of DataGhost. It represents a row of sql data, with each column being a property of the `SQLObject`.

- Properties can be passed in during object initialization as parameters (e.g. `spaceship = Spaceship.new(name: "The Tin Hummingbird", owner_id: 4)`
- Properties can be changed on live objects (`spaceship.name = "The Light Fantastic"`)

### Instance Methods

- `#save` persists object to the database  It will either insert a new row or update the old row based on the object's `id` or primary key's existence.
### Class Methods
- `::all` returns an array of each object from the corresponding table.
- `::finalize!` used to create attribute accessors. Call at the end of a custom class declaration.
- `::find(id)` returns the object corresponding to the passed Id.
- `::find_by(key: value)` returns the first object in the database where the value in column "key" is equivalent to the passed value. Multiple key/value pairs can be passed.
-`::find_by_param(value)` is equivalent to `::find_by`, with the "param" being changed for whichever key you are searching by. Multiple params can be passed by following the syntax `spaceship.find_by_name_and_owner_id("The Health Star", 4)`


##Searchable
Searchable is a module that contains a single function, `#where(params)`. It returns an array of objects based on the passed key/value pairs similar to `SQLObject#find_by`.

##Associatable
Associatable is a module used to connect two tables via foreign and primary keys.

### Instance Methods
- `#belongs_to(name, options)` should be called on objects which contain foreign keys. The name should be a symbol of the name of the table whose primary key is this table's foreign key. The options hash allows you to dynamically name the association or explicitly name the primary and foreign keys, e.g. `belongs_to(:owner, {primary_key: id, foreign_key: user_id})`

- `#has_many(name, options)` used as the corresponding method on objects who have foreign keys on other tables. Functionally used the same as `#belongs_to`:
`has_many(:spaceships, {primary_key: id, foreign_key: user_id})`

- Both `#has_many` and `#belongs_to` can be invoked without explicit options. They will default to using `id` as the primary key, `#{table_name}_id` as the foreign key, and assume there is a table with the passed name.
