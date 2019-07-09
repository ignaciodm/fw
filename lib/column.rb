
class Column
   attr_accessor :name, :type
  
  def initialize(name: name, type: type)
    @name = name
    @type = type
  end

end