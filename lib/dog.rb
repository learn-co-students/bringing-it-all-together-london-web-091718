require 'sqlite3'
require 'pry'

class Dog
  # DB = {:conn => SQLite3::Database.new("db/dogs.db")}
  attr_accessor :name, :breed, :id

  def initialize(name: name, breed: breed, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = (?)
    SQL
    DB[:conn].execute(sql, name).map do |row|
      new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = (?), breed = (?) WHERE id = (?)
    SQL

    DB[:conn].execute(sql, name, breed, id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    end
    self
  end

  def self.create(hash)
    new_name = hash[:name]
    new_breed = hash[:breed]
    dog = Dog.new(name: new_name, breed: new_breed)
    # binding.pry
    dog.save
    dog
  end

  def self.find_by_id(id)
    row = []
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = (?)
    SQL
    DB[:conn].execute(sql, id).map do |attributes|
      attributes.map do |attribute|
        # binding.pry
        row << attribute
      end
    end
    new_from_db(row)
  end

  def self.find_by_breed(breed)
    sql = <<-SQL
      SELECT * FROM dogs WHERE breed = (?)
    SQL
    DB[:conn].execute(sql, breed)
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = (?) AND breed = (?)
    SQL
    dog = DB[:conn].execute(sql, hash[:name], hash[:breed])

    dog = if !dog.empty?
            self.new_from_db(dog[0])
          else
            create(name: hash[:name], breed: hash[:breed])
          end
    dog
  end
end
