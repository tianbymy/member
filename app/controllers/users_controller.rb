# encoding: utf-8
class UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, only: [:index,:update,:change_password,:edit,:reset_password]
  load_and_authorize_resource

  def index
    @users = User.all.desc(:created_at).paginate(:page=>params[:page]||1,:per_page=>5)
  end

  def create
    validate_password
    if @user.save
      redirect_to Settings.register_redirect
    else
      render :new
    end
  end

  def update_password
    bind_password_value
    validate_password
    if @user.update_password
      flash[:message] ="修改成功"
    else
      render :change_password and return if @user.attributes.include?("old_password")
      render :set_new_password and return
    end
    redirect_to change_password and return if @user.attributes.include?("old_password")
    redirect_to users_path and return if request.referer.to_s.match /\/users$/
    redirect_to Settings.home_page_url
  end

  def send_reset_password_email
    @user = User.where(mail: params[:mail]).first
    if @user.nil?
      flash[:message] = "信息输入错误,请重新输入!" 
    else
      @user.send_password_reset
      flash[:message] = "重置密码邮件以发送，请注意查收!"
    end
    redirect_to forgot_password_users_path
  end

  def set_new_password
    @user = User.where(password_reset_token: params[:token]).first unless params[:token].nil?
    if @user.nil?
      flash[:message] = "找回密码链接不正确"
    else
      flash[:message] = "找回密码链接过期" if @user.password_reset_sent_at < Settings.password_reset.expire_time.hours.ago
    end
    redirect_to forgot_password_users_path and return unless flash[:message].nil?
  end

  def update
    if @user.update_info(params[:user])
      @message ="保存成功"
    else
      @message ="保存失败"
      render :edit and return
    end
    flash[:message] = @message
    redirect_to edit_user_path
  end

  def lock
    if @user.state == "actived"
      @user.lock
    else
      @user.unlock
    end
    redirect_to users_path
  end

  private
  def validate_password
    @user.validate_presence([:password,:password_confirmation])
    @user.validate_format({:password => /[a-zA-Z0-9]{6,}/})
    @user.validate_confirmation :password,:password_confirmation
  end

  def bind_password_value
    params[:user].each do |k,v|
      @user[k.to_sym] = v
    end
  end
end
