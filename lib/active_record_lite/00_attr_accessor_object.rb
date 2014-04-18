class AttrAccessorObject
  # def self.my_attr_accessor(*names)
  #   names.each do |name|
  #     define_method(name)
  #     self.instance_variable_get(name)
  #     self.instance_variable_set(name)  
  #   end
  # end
  # 
  # def define_method
  # end
  # 
  # def instance_variable_get
  # end
  # 
  # def instance_variable_set
  # end
  
  def self.my_attr_accessor(*names)
    names.each do |name|
      
      
      define_method(name) do 
         self.instance_variable_get("@#{name}") 
       end
       
       
      define_method("#{name}=") do |value|
        self.instance_variable_set("@#{name}", "#{value}")
      end
        
    end
  end
  
  
  def perform_get(name)
    instance_variable_get(name)
  end
  
end
