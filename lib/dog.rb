class Dog
    ##  Instance Attrs definition secion
    attr_accessor :id, :name, :breed

    ##  Class attributes declaration secion
    @@all = []

    ##  Class constructor definition secion
    def initialize(id: nil, name:, breed:)
        self.id = id
        self.name = name
        self.breed = breed

        self.class.all << self
    end

    ##  Custom getters/setters definition secion

    ##  Instance methoods definition secion
    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ? , breed = ?
            WHERE id = ? 
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    ##  Class methods definition secion
    def self.all
        @@all
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def self.create(name:, breed:)
        new_dog = self.new(name: name, breed: breed)
        new_dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end
    
    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE id = ?
        SQL
        dog_from_db = DB[:conn].execute(sql, id)[0]
        self.new_from_db(dog_from_db)
    end

    def self.find_by_attributes(name, breed)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            AND breed = ?
        SQL
        dog_from_db = DB[:conn].execute(sql, name, breed)[0]
        #binding.pry
        if dog_from_db
            return self.new_from_db(dog_from_db)
        else
            return nil
        end

    end
    def self.find_or_create_by(name:, breed:)
        found = self.find_by_attributes(name, breed)
        if !found
            self.create(name: name, breed: breed)
        else
            found
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        dog_from_db = DB[:conn].execute(sql, name)[0]
        self.new_from_db(dog_from_db)
    end
    ##  Private methods definition secion
end