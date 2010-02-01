require 'base64'
require 'active_record/strongbox_sentry_callback'

begin
  require 'active_record/strongbox_sentry'
  ActiveRecord::Base.class_eval do
    include ActiveRecord::StrongboxSentry
  end
rescue NameError
  nil
end