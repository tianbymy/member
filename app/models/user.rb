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
  field :password_reset_token
  field :password_reset_sent_at

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
      self.errors[arge] << (I18n.t :simple_form)[:labels][:user][arge].to_s + "不能为空" if self[arge].to_s.empty?
    end
  end

  def validate_format arges
    arges.each do |k,v|
      unless self[k].to_s.empty?
        self.errors[k] << (I18n.t :simple_form)[:labels][:user][k].to_s + "格式不正确" if (self[k].match v).nil?
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
    self.errors.empty?
  end

  def update_password
    if self.attributes.include?("old_password")
      self.errors[:old_password] << "旧密码输入错误" unless User.manager.mypass?(self.login, self.old_password)
    end
    User.manager.reset_password(self.login, self.password) if self.errors.empty?
  end

  after_create do |user|
    um = user.class.manager
    return unless um
    return user.register if um.exist?(user.login)
    um.add({
      uid: user.login,
      sn: user.sn,
      cn: user.cn,
      displayName: user.name,
      mail: user.mail,
      mobile: user.mobile,
      userPassword: user.password
    })
    if um.exist?(user.login)
      user.register
      ["password","password_confirmation"].each do |attr|
        user.remove_attribute(attr)
        user.save
      end
    else
      user.delete
    end
  end

  def delete_user
    if self.class.manager.delete(self.login)
      return self.delete
    end
  end

  def update_info arge
    if self.update_attributes(arge)
      arge[:displayName] = arge[:sn] + arge[:cn]
      return User.manager.update_info(self.login, arge)
    end
  end

  def self.all_ldap
    User.manager.all.map { |e| 
      unless User.where(login: e[:uid]).first 
        User.new({login: e[:uid], name: e[:display], sn: e[:sn], cn: e[:cn], mail: e[:mail], mobile: e[:mobile]}).save
      end
    }
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    Resque.enqueue(Email,"重置密码",Email.to_html("password_reset",{:token => self.password_reset_token}),self.mail) if self.save
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.where(column => self[column]).exists?
  end
end
