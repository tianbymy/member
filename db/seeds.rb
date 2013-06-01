# encoding: utf-8
require 'csv'
account = Account::Account.get_accout
header = ['登录名','姓','名','姓名','邮箱','电话','密码']
CSV.open("db/file.csv", "wb") do |csv|
  csv << header
  account.each do |x|
    a = rand(999999)
    row = []
    user = User.new({login: x["login"], sn:  x["login"] , cn:  x["login"], name:  x["login"], mail: x["email"], mobile: 13800000000 ,password_confirmation: a ,password: a})
    # user.create_ldap   这一句代码才是创建用户到ldap中
    p "#{x['login']},#{x['login']},#{x['login']},#{x['login']},#{x['email']},13800000000,#{a}"
    row << user.login
    row << user.sn
    row << user.cn
    row << user.name
    row << user.mail
    row << user.mobile
    row << user.password
    csv << row if row.size > 0
  end
end