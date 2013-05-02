# -*- coding: utf-8 -*-

class User  #< Unirole::User
  include Mongoid::Document
  field :login
  field :sn
  field :cn
  field :name

  field :email
  field :phone
  field :password
  field :password_reset_token
  field :password_reset_sent_at

  validates :email, uniqueness: true, presence: true, format: { with: /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/ }
  validates :password, confirmation: true, presence: true

  before_create :create_ldap_user

  def validate_old_password arge
    return "旧密码不能为空" if arge.old_password.empty?
    return "两次密码输入不一致" if arge.password != arge.password_confirmation
    return "旧密码输入错误" unless Zhiyi::Member::User.mypass?(self.login,arge.old_password)
  end

  def update_password password
    Zhiyi::Member::User.reset_password(self.login, password)
  end

  def update_user_info arge
    self.email = arge.email
    self.phone = arge.phone
    self.save
  end

  def create_ldap_user
    @person = {
      uid: self.login,
      sn: self.sn,
      cn: self.cn,
      displayName: self.name,
      userPassword: self.password
    }
    unless Zhiyi::Member::User.exist?(self.login)
      self.remove_attribute(:password) if Zhiyi::Member::User.add @person
    end
  end

  def has_organs_of(key)
    has_organs=[]
    organs.each do |organ|
      if Decision.allow?("rank" => organ.rank.name,  "behave" => key)
        has_organs << organ
      end
    end
    has_organs
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    Resque.enqueue(Email,"重置密码",Email.to_html("password_reset",{:id => self.password_reset_token}),self.email) if self.save
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.where(column => self[column]).exists?
  end
end
