# encoding: utf-8

require "#{Rails.root}/db/city_account.rb"
require "#{Rails.root}/db/city_enterprise.rb"

account = Cityaccount::City.city_account
enterprise = Cityenterprise::City.city_account
fh = File.new("db/fail", "rw")
enterprise.each do |x|
  row = []
  user = User.new({login: x["login"], sn:  x["login"] , cn:  x["login"], name:  x["login"], mail: x["email"], mobile: "13800000000" ,password_confirmation: "123456" ,password: "123456"})
  begin
    user.create_ldap #  这一句代码才是创建用户到ldap中
    p "#{x['login']},#{x['login']},#{x['login']},#{x['login']},#{x['email']},13800000000,123456"
  rescue Exception => e
    fh.puts "#{x['login']},#{x['login']},#{x['login']},#{x['login']},#{x['email']},13800000000,123456"
  end
end

account.each do |x|
  row = []
  user = User.new({login: x["login"], sn:  x["login"] , cn:  x["login"], name:  x["login"], mail: x["email"], mobile: "13800000000" ,password_confirmation: "123456" ,password: "123456"})
  begin
    user.create_ldap #  这一句代码才是创建用户到ldap中
    p "#{x['login']},#{x['login']},#{x['login']},#{x['login']},#{x['email']},13800000000,123456"    
  rescue Exception => e
    fh.puts "#{x['login']},#{x['login']},#{x['login']},#{x['login']},#{x['email']},13800000000,123456"
  end
end
