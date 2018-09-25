require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize (name:, breed:, id:nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT
        breed TEXT
      )
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs
        (name, breed)
        values (?,?)
      SQL

      DB[:conn].execute(sql,self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
    new_dog
  end

  def self.find_by_id(dog_id)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        LIMIT 1
    SQL

    x =  DB[:conn].execute(sql, dog_id).map do |row|
     new_from_db(row)
   end.first
  end

  def self.find_or_create_by(dog_hash)
    new_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{dog_hash[:name]}' AND breed = '#{dog_hash[:breed]}';")
    if !new_dog.empty?
      # binding.pry
      # self.find_by_name(dog_hash[:name])
      new_dog = self.new_from_db(new_dog[0])
    elsif

      new_dog = self.create(dog_hash)
    end
    new_dog
  end

  def self.new_from_db(row)
    dog = Dog.new(id:row[0], name:row[1], breed:row[2])  # self.new is the same as running Song.new
    dog  # return the newly created instance
  end

  def self.find_by_name(dog_name)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1
    SQL

    DB[:conn].execute(sql, dog_name).map do |row|
     self.new_from_db(row)
   end.first

  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name=? WHERE id=?;
    SQL

    DB[:conn].execute(sql, @name, @id)
  end

end
