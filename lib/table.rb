require 'column.rb'

class Table
   attr_accessor :name, :model_class, :columns, :records
  
  def initialize(model: model)
    @name = model.to_s.downcase
    @model_class = model
    @columns = []
    @records = []
  end

  def add_column(type, name)
    puts "add column"
    puts name
    @columns << Column.new(type: type, name: name.to_s)
  end

  def add_record(record)
    @records << @model_class.new(*record) # add validation
  end

  def string(name)
    add_column String, name
  end  

  def integer(name)
    add_column Integer, name
  end

end
