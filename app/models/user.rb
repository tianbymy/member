# encoding: utf-8

# -*- coding: utf-8 -*-

class User #< Unirole::User
  include Mongoid::Document
  field :login
  field :sn
  field :cn
  field :name

  field :email
  field :phone
  field :id_card
  field :password
  field :password_reset_token
  field :password_reset_sent_at

  
  def self.manager
    @@manager
  end

  def self.manager= klass
    @@manager = klass.instance_of?(Class) ? klass : klass.to_s.constantize
  end

  # validates :email, uniqueness: true, presence: true, format: { with: /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/ }
  # validates :password, confirmation: true, presence: true

  def validate_presence arges
    arges.each do |arge|
      self.errors[arge] << (I18n.t :simple_form)[:labels][:user][arge].to_s + "不能为空" if self[arge].to_s.empty?
    end
  end

  def validate_format arges
    arges.each do |k,v|
      self.errors[k] << (I18n.t :simple_form)[:labels][:user][k].to_s + "格式不正确" if (self[k].match v).nil? 
    end
  end

  def validate_confirmation arge,arge_confirmation
    self.errors[arge_confirmation] << (I18n.t :simple_form)[:labels][:user][arge_confirmation].to_s + "输入不正确" if self[arge].to_s != self[arge_confirmation].to_s
  end

  def update_password password
    User.manager.reset_password(self.login, password)
  end

  def update_user_info arge
    self.email = arge.email
    self.phone = arge.phone
    self.save
  end

  def create_user
    @person = {
      uid: self.login,
      sn: self.sn,
      cn: self.cn,
      displayName: self.name,
      email: self.email,
      phone: self.phone,
      idCard: self.id_card,
      userPassword: self.password
    }
    unless User.manager.exist?(self.login)
     return User.manager.add(@person)
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
