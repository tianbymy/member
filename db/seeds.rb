
account = Account::Account.get_accout
account.each do |x|
  a = rand(999999)
  User.create!(login: x["login"], sn:  x["login"] , cn:  x["login"], name:  x["login"], mail: x["email"], mobile: 13800000000 ,password_confirmation: a ,password: a)
  p "#{x['login']},#{x['login']},#{x['login']},#{x['login']},#{x['email']},13800000000,#{a}"
end

