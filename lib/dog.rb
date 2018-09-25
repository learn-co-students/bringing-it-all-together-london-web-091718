require 'sqlite3'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id:nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def self.create(hash)
    dog = Dog.new(name: hash[:name], breed: hash[:breed])
    dog.save
  end

  def self.new_from_db(hash_raw)
    hash = hash_raw.flatten
    dog = Dog.new(name: hash[1], breed: hash[2], id: hash[0])
    dog
  end

  def self.find_by_id(id)
    hash = DB[:conn].execute("SELECT * FROM dogs WHERE id = (?);", id)
    new_from_db(hash)
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    check = DB[:conn].execute(sql, hash[:name], hash[:breed])[0]

    if check == nil
      create(hash)
    else
      find_by_name(hash[:name])
    end
  end

  def self.find_by_name(name)
    hash = DB[:conn].execute("SELECT * FROM dogs WHERE name = (?);", name)
    new_from_db(hash)
  end

  def find_last
    DB[:conn].execute("SELECT MAX(id) FROM dogs;").flatten.first
  end


  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?, ?);
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    id = find_last
    Dog.new(name: self.name, breed: self.breed, id: id)
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ? WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.id)
  end


end
