class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql=<<-SQL
     CREATE TABLE IF NOT EXISTS dogs (
       id INTEGER PRIMARY KEY,
       name TEXT,
       breed TEXT
     )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql="DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end

  def self.find_by_name(name)
    sql=<<-SQL
     SELECT *
     FROM dogs
     WHERE name = ?
     LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.create(hash)
    new_dog = Dog.new(name: hash[:name], breed: hash[:breed])
    new_dog.save
    new_dog
  end

  def self.find_or_create_by(name:, breed:)
    new_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !new_dog.empty?
      new_dog_data = new_dog[0]
      new_dog = Dog.new(id: new_dog_data[0], name: new_dog_data[1], breed: new_dog_data[2])
    else
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end

  def self.find_by_id(id)
    sql="SELECT * FROM dogs WHERE id =?"
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(id: result[0], name: result[1], breed: result[2])
  end

  def save
    sql=<<-SQL
     INSERT INTO dogs(name, breed)
     VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
