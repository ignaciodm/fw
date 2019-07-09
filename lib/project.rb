class Project
  attr_accessor :project, :shot, :version, :status, :finish_date, :internal_bid, :created_date
  
  def initialize(*args)
    args.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

end
