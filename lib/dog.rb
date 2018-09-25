require "pry"
require "sqlite3"


DB = {:conn => SQLite3::Database.new("db/dogs.db")}


class Dog

  attr_accessor :id, :name, :breed

   def initialize(id: nil, name:, breed:)
     @id = id
     @name = name
     @breed = breed
   end


     def self.create_table
       sql = <<-SQL
          CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
          );
       SQL
       DB[:conn].execute(sql)
     end


     def self.drop_table
       sql = <<-SQL
        DROP TABLE dogs;
        SQL
        DB[:conn].execute(sql)
     end

     def save
       sql = <<-SQL
       INSERT INTO dogs (breed, name) VALUES (?, ?);
       SQL
       DB[:conn].execute(sql, @breed, @name)

       @id = DB[:conn].execute("select last_insert_rowid() from dogs")[0][0]
       # binding.pry
       self
     end


     def self.create(name:, breed:)
       new_dog = Dog.new(name: name, breed: breed)
       # binding.pry
       new_dog.save
       new_dog
     end

     def self.find_by_id(id)
       sql = <<-SQL
        SELECT * FROM dogs WHERE id = (?);
       SQL
       value = DB[:conn].execute(sql, id)
       new_dog = Dog.new(id: value[0][0], name: value[0][1], breed: value[0][2])
       new_dog
     end

     def self.find_by_name(name)
       sql = <<-SQL
        SELECT * FROM dogs WHERE name = (?);
       SQL
       value = DB[:conn].execute(sql, name)


       new_dog = Dog.new(id: value[0][0], name: value[0][1], breed: value[0][2])
       new_dog
     end

     def self.new_from_db(row)
       dog = Dog.new(id: row[0], name: row[1], breed: row[2])
       dog
     end

     def self.find_or_create_by(name:, breed:)
       sql = <<-SQL
        SELECT * FROM dogs WHERE name = (?) AND breed = (?);
       SQL

       value = DB[:conn].execute(sql, name, breed)[0]
       # binding.pry
       if value != nil
         self.find_by_name(name)
       else
         self.create(name: name, breed: breed)
       end
     end

     def update
     sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
     DB[:conn].execute(sql, self.name, self.breed, self.id)
   end





end
