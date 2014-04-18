class House
  def initialize(name)
    @name = name
  end
  
  def riot
    "I am queen!"
  end
  
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) do   
        instance_variable_get(name)
         
      end
      define_method(name){ instance_variable_set(name) }
    end
  end
end

tully = House.new(tully)
p tully.my_attr_accessor(riot)