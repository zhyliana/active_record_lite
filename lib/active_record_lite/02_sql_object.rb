require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map { | cat | self.new(cat) }   
  end
end

class SQLObject < MassObject
  def self.columns
    table = DBConnection.execute2("SELECT * FROM #{table_name}")
    
    table.first.each do | column_name |
      define_method("#{column_name}=") do |value|
        attributes[column_name.to_sym] = value
      end
      
      define_method("#{column_name}") do
        attributes[column_name.to_sym]
      end
    end
    
    @columns = table.first.map { |column| column.to_sym }
  end


  def self.table_name=(table_name)
    @table = table_name
  end

  def self.table_name
    @table ||= self.to_s.downcase.pluralize
  end

  def self.all
    attrbutes_hash = DBConnection.execute(<<-SQL)
    SELECT 
      * 
    FROM 
      #{self.table_name}     
    SQL
    
    attrbutes_hash.map{ | attr_values | self.new(attr_values)}
    
  end

  def self.find(id)
    found_obj = DBConnection.execute(<<-SQL)
    SELECT 
      * 
    FROM 
      #{self.table_name} 
    WHERE
      id = #{id}
    SQL
    
    found_obj.map{ | attr_values | self.new(attr_values)}.first
  end

  def attributes
    @attributes ||= Hash.new 
  end

  def insert
    col_names = attributes.keys.join(", ")
    col_values = self.attribute_values
    question_marks = "(" + (["?"] * col_values.count ).join(", ") + ")"
     
    DBConnection.execute(<<-SQL, *col_values)
    INSERT INTO
     #{self.class.table_name} (#{col_names})
     VALUES
     #{question_marks}
    SQL
    
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {} )
    params.each do | attr_name, value |
      if self.class.columns.include?(attr_name.to_sym)
        attributes[attr_name.to_sym] = value
      else
        raise "unknown attribute #{attr_name}"
      end 
    end
  end

  def save
    return self.insert if self.id.nil?
    self.update
  end

  def update
    set_line = attributes.keys[1..-1].map{ |col| "#{col} = ?"}.join(", ")
    col_values = self.attribute_values[1..-1]
    
    DBConnection.execute(<<-SQL, *col_values, id)
     UPDATE
      #{self.class.table_name}
     SET
      #{set_line}
     WHERE
      id = ?
     SQL
  end

  def attribute_values
    attributes.values
  end
end
