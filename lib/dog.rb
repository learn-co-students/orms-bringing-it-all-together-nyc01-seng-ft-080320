class Dog
    attr_accessor :name, :breed
    attr_reader :id

    
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end
    
    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        );
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
        INSERT INTO dogs(name,breed) VALUES (?,?)
        SQL
        DB[:conn].execute(sql,self.name,self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(name:, breed:)
        created_instance = Dog.new(name: name, breed: breed)
        created_instance.save
        
    end

    def self.new_from_db(row)
        id, name, breed = row
        Dog.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE id= ?", id)[0][0]
        Dog.new_from_db(row)
    end
    
    def self.find_by_name(name)
        # binding.pry
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name= ?", name)[0]
        Dog.new_from_db(row)
    end

    def self.find_or_create_by(name:,breed:)
        search_result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).first
        if search_result.nil?
            dog = Dog.create(name: name, breed: breed)
        else
            dog = Dog.new_from_db(search_result)
        end
        dog
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
