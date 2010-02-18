module ActiveRecord
  class StrongboxSentryCallback
    attr_reader :attr_name, :crypted_attr_name
    def initialize(attr_name, crypted_attr_name = nil)
      @attr_name = attr_name
      @crypted_attr_name = crypted_attr_name || "crypted_#{@attr_name}"
    end
  
    # Performs encryption on before_validation Active Record callback
    def before_save(model)
      return if model.send(@attr_name).blank?
      model.send("#{@crypted_attr_name}=", model.send(@attr_name))
    end
    
    def after_save(model)
      model.send("#{@attr_name}=", nil)
    end
  end
end