require 'pry'

class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id:nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
            SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs;
            SQL

        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        #binding.pry 
        
        id = row[0]
        name = row[1]
        breed = row[2]

        new_dog = self.new(id:id, name:name, breed:breed)
        new_dog
        
    end

    def self.create(hash)
        dog = self.new(hash)
        dog.save
        dog
        
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?);
        SQL

        DB[:conn].execute(sql, self.name, self.breed)

        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        #binding.pry
        self
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?;
        SQL

        DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
        end.first

    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?;
        SQL

        DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
        end.first

    end

    def self.find_by_name_and_breed(name, breed)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed =?;
        SQL

        DB[:conn].execute(sql, name, breed).map do |row|
        self.new_from_db(row)
        end.first

    end

    def update
        #binding.pry
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
        SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_or_create_by(hash)
        if !self.find_by_name_and_breed(hash[:name], hash[:breed])
            
            self.create(hash)
        
        else
            return self.find_by_name_and_breed(hash[:name], hash[:breed])
        end

    end

end

#Pry.start