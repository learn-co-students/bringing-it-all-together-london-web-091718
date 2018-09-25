require "pry"


class Dog

  attr_accessor :id, :name, :breed

  def initialize(id=nil, new_dog_hash)
    @id = new_dog_hash[:id]
    @name = new_dog_hash[:name]
    @breed = new_dog_hash[:breed]

  end

  def attributes
      self.name
      self.breed
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

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
        VALUES(?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(id=nil, new_dog_hash)
    Dog.new(new_dog_hash).save
  end

  def self.find_by_id(dog_id)
    @id = dog_id
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, dog_id)[0])
  end

  def self.find_by_name(dog_name)
    @name = dog_name
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
      SQL
    self.new_from_db(DB[:conn].execute(sql, dog_name)[0])
  end

  def self.new_from_db(row)
    # @id = row[0]
    # @name = row[1]
    # @breed = row[2]
    dog_hash = {:id => row[0], :name => row[1], :breed => row[2]}
    Dog.new(dog_hash)
  end




  def self.find_or_create_by(dog_hash)

    #dog_hash.name
    sql =<<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    name_and_breed_match = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])[0]

    if name_and_breed_match
      return self.new_from_db(name_and_breed_match)
    else
      self.create(dog_hash)
    end
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end


# binding.pry
