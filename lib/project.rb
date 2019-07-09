class Project
   attr_accessor :project, :shot, :version, :status, :finish_date, :internal_bid, :created_date,
  
  def initialize(path: path, separator: separator)
    @path = path
    @separator = separator
  end

  def map_each_line
    File.open(@path, "r") do |f|
      f.each_line do |line|
        yield(line.split(@separator))
      end
    end
  end
end
