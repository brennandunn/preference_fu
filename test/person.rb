
class Person < ActiveRecord::Base
  
  has_preferences :send_email, :change_theme, :delete_user, :create_user
  
  set_default_preference :send_email, true
  
end