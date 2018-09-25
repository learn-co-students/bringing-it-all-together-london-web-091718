require"pry"
class Dog

attr_accessor :id, :breed, :name
attr_reader

def initialize(id:nil, name:name, breed:breed)
  @name = name
  @breed = breed
  @id=id
end

def self.create_table
  sql = "CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
  DB[:conn].execute(sql)
end

def self.drop_table
  sql = " DROP TABLE dogs;"
  DB[:conn].execute(sql)
end

def save
  # doggo=Dog.new
  # doggo.name=@name
  # doggo.breed=@breed
  # DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?)",doggo.name,doggo.breed)
  # doggo.id=parse[0][0]
  # doggo
  if !self.id.nil?
    update
  else
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?)",self.name,self.breed)
    id=parse[0][0]
    @id = id
  end
    return self
end

def parse
  DB[:conn].execute("SELECT * FROM dogs WHERE name=?;", self.name)
end

def self.create(hash)
  self.new(hash).save
end

def self.find_by_id(given_id)
  sql="SELECT * FROM dogs WHERE id=?;"
  retrieved=DB[:conn].execute(sql,given_id)[0]
  new_from_db(retrieved)
end

def self.new_from_db(array)
  bobo=self.new
  bobo.id=array[0]
  bobo.name=array[1]
  bobo.breed=array[2]
  bobo
end


def self.find_or_create_by(name:name,breed:breed)
sql="SELECT * FROM dogs WHERE name=? AND breed=?;"
check=DB[:conn].execute(sql,name,breed)[0]
#binding.pry
if check != nil
  self.find_by_name(name)
else
  create(name:name,breed:breed)
end
end



def self.find_by_name(name)
  row=DB[:conn].execute("SELECT * FROM  dogs WHERE name=?" ,name)[0]
  new_from_db(row)
end

def update
  a=DB[:conn].execute("UPDATE dogs SET name=?,breed=? WHERE id=?", self.name, self.breed ,self.id)
  #binding.pry
end




end
