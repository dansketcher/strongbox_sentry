module ActiveRecord # :nodoc:
  module StrongboxSentry
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end
  
    module ClassMethods
      def strongbox_encrypts(attr_name, crypted_attr_name = nil)
        temp_sentry = ::ActiveRecord::StrongboxSentryCallback.new(attr_name, crypted_attr_name)
        before_save temp_sentry
        after_save temp_sentry
      
        define_method(temp_sentry.attr_name) do |*optional|
          send("#{temp_sentry.attr_name}!", *optional) rescue nil
        end
      
        define_method("#{temp_sentry.attr_name}!") do |*optional|
          return decrypted_values[temp_sentry.attr_name] unless decrypted_values[temp_sentry.attr_name].nil?
          return nil if send("#{temp_sentry.crypted_attr_name}").nil?
          key = optional.shift
          out = send("#{temp_sentry.crypted_attr_name}").decrypt(key)
          # Strongbox returns the string "*encrypted*" if the field is still
          # locked - make this more Sentry-like by returning nil instead
          out = nil if out == "*encrypted*"
          set_decrypted_value(temp_sentry.attr_name, out)
          out
        end
        
        define_method("set_#{temp_sentry.crypted_attr_name}") do |value|
          send(temp_sentry.crypted_attr_name).instance_variable_get('@instance')[temp_sentry.crypted_attr_name.to_s] = value
          nil
        end
        
        define_method("#{temp_sentry.attr_name}=") do |value|
          decrypted_values[temp_sentry.attr_name] = value
          nil
        end
        
        # Add a method for when the decrypted value is stored - for attachment of audit logging as necessary
        define_method("set_decrypted_value") do |key, value|
          decrypted_values[key] = value
        end
        
        private
        define_method(:decrypted_values) do
          @decrypted_values ||= {}
        end
      end

    end
  end
end
