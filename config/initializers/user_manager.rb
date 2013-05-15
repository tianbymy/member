# Load the user manager
Zhiyi::Member.load("#{Rails.root.to_s}/config/ldap.yaml")
require 'user'
User.manager = Zhiyi::Member::User
