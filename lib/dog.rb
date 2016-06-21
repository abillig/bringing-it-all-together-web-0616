class Dog 
attr_accessor :name, :breed, :id


  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = nil
  end

  def self.create_table
    sql = <<-SQL 
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY, 
      name TEXT, 
      breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table 
    DB[:conn].execute("DROP TABLE dogs")
  end 

  def save
    sql = "INSERT INTO dogs(name, breed)
    VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM 
        dogs")[0][0]
    self
  end

  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    row = DB[:conn].execute(sql, id)[0]
    row_hash = {id: row[0], name: row[1], breed: row[2]}
    new_dog = self.new(row_hash)
    new_dog.id = id 
    new_dog
  end

  def self.find_or_create_by(hash)
    sql = "SELECT * FROM dogs WHERE name = ? and breed = ?"
    row = DB[:conn].execute(sql, hash[:name], hash[:breed]) 
    if row.empty? 
      self.create(hash)
    else 
      self.find_by_id(row[0][0])
    end
  end

  def self.new_from_db(row)
    row_hash = {id: row[0], name: row[1], breed: row[2]}
    new_instance = self.new(row_hash)
    new_instance.id = row[0]
    new_instance
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    named = DB[:conn].execute(sql, name)
    instance = self.new_from_db(named[0])
    instance
  end

  def update
    sql1="SELECT * FROM dogs WHERE id = ?"
    self_row = DB[:conn].execute(sql1, self.id)

    sql = <<-SQL 
    UPDATE dogs SET id = ?, name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.id, self.name, self.breed, self.id)

  end


end 




