# encoding: utf-8
class User
  @@manager = nil

  def self.manager
    @@manager
  end

  def self.manager= klass
    @@manager = klass.instance_of?(Class) ? klass : klass.to_s.constantize
  end

  include Mongoid::Document
  include Mongoid::Timestamps

  field :login
  field :sn
  field :cn
  field :name
  field :mail
  field :mobile

  validates :login, format: {with: /[a-zA-Z0-9]{6,}/}
  validates :mail, format: { with: /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/ }
  validates_uniqueness_of :login, :mail
  validates_presence_of :sn, :cn, :login, :mail, :mobile
  validates :mobile, format: {with: /^\d{11}$/}

  state_machine :state, initial: :unregistered do
    event :register do
      transition [:unregistered] => :actived
    end

    event :lock do
      transition [:actived] => :locked
    end

    event :unlock do
      transition [:locked] => :actived
    end
  end

  before_save do |user|
    user.name = user.sn + user.cn
  end

  def validate_presence arges
    arges.each do |arge|
      self.errors[arge] << (I18n.t :mongoid)[:errors][:models][:user][:attributes][arge][:blank].to_s if self[arge].to_s.empty?
    end
  end

  def validate_format arges
    arges.each do |k,v|
      unless self[k].to_s.empty?
        self.errors[k] << (I18n.t :mongoid)[:errors][:models][:user][:attributes][k][:invalid].to_s if (self[k].match v).nil?
      end
    end
  end

  def validate_confirmation arge,arge_confirmation
    self.errors[arge_confirmation] << (I18n.t :simple_form)[:labels][:user][arge_confirmation].to_s + "输入不正确" if self[arge].to_s != self[arge_confirmation].to_s
  end

  def validate_password
    self.validate_presence([:password,:password_confirmation])
    self.validate_format({:password => /[a-zA-Z0-9]{6,}/})
    self.validate_confirmation :password,:password_confirmation
    if self.attributes.include?("old_password")
      self.errors[:old_password] << "旧密码输入错误" unless User.manager.mypass?(self.login, self.old_password)
    end
    self.errors.empty?
  end

  def update_password
    if self.validate_password
      return User.manager.reset_password(self.login, self.password)
    end
    return false
  end

  def validate_uniqueness arge
    arge.each do |e|
      self.errors[e.to_sym] << (I18n.t :simple_form)[:labels][:user][e.to_sym].to_s + "已经存在" if User.send("find_by_#{e}".to_sym,self[e.to_sym])
    end
  end

  def create_ldap
    self.create_validate
    if self.errors.empty?
      User.manager.add({
        uid: self.login,
        sn: self.sn,
        cn: self.cn,
        displayName: self.sn + self.cn,
        mail: self.mail,
        mobile: self.mobile,
        userPassword: self.password
      })
      return User.manager.exist?(self.login)
    end
  end

  def delete_user
    self.class.manager.delete(self.login)
  end

  def update_info arge
    arge[:displayName] = arge[:sn] + arge[:cn]
    User.manager.update_info(self.login, arge)
  end

  def self.all_ldap
    where_ldap({objectclass: "person"})
  end
  # 应该用missmethod方法来处理
  def self.find_by_mail mail
    where_ldap({mail: mail}).first
  end

  def self.find_by_login login
    where_ldap({uid: login}).first
  end

  def self.send_password_reset user
    token = SecureRandom.urlsafe_base64
    Resque.redis.set(user.login, token)
    Resque.redis.expire(user.login,Settings.password_reset.expire_time)
    Resque.enqueue(Email,"重置密码",Email.to_html("password_reset",{:token => token, :login => user.login}),user.mail)
    token
  end

  def self.where_ldap arge
    params = ""
    arge.each do |k,v|
      params += "(#{k}=#{v})"
    end
    User.manager.send(:search,"(|#{params})").map { |e|
      User.new({login: e[:uid], name: e[:display], sn: e[:sn], cn: e[:cn], mail: e[:mail], mobile: e[:mobile]})
    }
  end

  def create_validate
    validate_presence([:sn, :cn, :login, :mail, :mobile])
    validate_format({login: /[a-zA-Z0-9]{6,}/, mail: /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/, mobile: /^\d{11}$/})
    validate_password
    validate_uniqueness(["login","mail"])
  end
end
