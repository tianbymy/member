# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => "http://www.scscfw.com:443",
  :username_session_key => :cas_user,
  :extra_attributes_session_key => :login_extra_attributes,
  :enable_single_sign_out => true,
  :authenticate_on_every_request => false
)



Member::Application.initialize!
