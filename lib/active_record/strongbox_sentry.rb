module ActiveRecord # :nodoc:
  module StrongboxSentry
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end
  
    module ClassMethods
      def strongbox_encrypts(attr_name, crypted_attr_name = nil)
        temp_sentry = ::ActiveRecord::StrongboxSentryCallback.new(attr_name, crypted_attr_name)
        before_validation temp_sentry
        after_save temp_sentry
      
        define_method(temp_sentry.attr_name) do |*optional|
          send("#{temp_sentry.attr_name}!", *optional) rescue nil
        end
      
        define_method("#{temp_sentry.attr_name}!") do |*optional|
          return decrypted_values[temp_sentry.attr_name] unless decrypted_values[temp_sentry.attr_name].nil?
          return nil if send("#{temp_sentry.crypted_attr_name}").nil?
          key = optional.shift
          out = send("#{temp_sentry.crypted_attr_name}").decrypt(key)
          #out = nil if out == "*encrypted*" # This is from Strongbox
          decrypted_values[temp_sentry.attr_name] = out unless out == "*encrypted*" # This is from Strongbox
          out
        end
      
        define_method("#{temp_sentry.attr_name}=") do |value|
          decrypted_values[temp_sentry.attr_name] = value
          nil
        end
      
        private
        define_method(:decrypted_values) do
          @decrypted_values ||= {}
        end
      end

    end
  end
end
