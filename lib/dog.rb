require 'pry'
class Dog
  attr_accessor :name, :breed, :id
  def initialize(name:,breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs
    (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed) 
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:,breed:)
    new_dog =Dog.new(name: name,breed: breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(array_of_info)
    new_dog = Dog.new(name: array_of_info[1], breed: array_of_info[2],id:array_of_info[0])
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE dogs.id = ?
    LIMIT 1
    SQL
    result = DB[:conn].execute(sql,id)[0]
    self.new_from_db(result)
  end

  def self.find_or_create_by(name:,breed:)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ? AND breed = ?
    LIMIT 1
    SQL
    result =DB[:conn].execute(sql, name,breed)
    if result.empty?
      self.create(name:name,breed:breed)
    else
      dog_info = result[0]
      final = self.find_by_id(dog_info[0])
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE dogs.name = ?
    LIMIT 1
    SQL
    DB[:conn].execute(sql,name).map do |results|
      found_dog = self.new_from_db(results)
    end.first
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name,self.breed,self.id)
  end
end