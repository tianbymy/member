# encoding: utf-8
class UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, only: [:update,:change_password,:edit]
  before_filter :bind_password_value, only: [:update_password]
  before_filter :validate_password, only: [:create,:update_password]
  load_and_authorize_resource

  def new
    @user = User.new
  end

  def create
    if @user.save
      redirect_to Settings.register_redirect
    else
      render :new
    end
  end

  def update_password
    if @user.attributes.include?("old_password")
      @user.errors[:old_password] << "旧密码输入错误" unless User.manager.mypass? @user.login,@user.old_password
    end
    if @user.errors.count > 0
      render :change_password and return if @user.attributes.include?("old_password")
      render :set_new_password and return
    else
      @message ="修改成功" if @user.update_password
    end
    flash[:message] = @message
    redirect_to change_password_users_path if @user.attributes.include?("old_password")
    redirect_to Settings.register_redirect
  end

  def reset_password
    @user = User.where(email: params[:email]).first
    if @user.nil?
      flash[:message] = "信息输入错误,请重新输入!" 
    else
      @user.send_password_reset
      flash[:message] = "重置密码邮件以发送，请注意查收!"
    end
    redirect_to forgot_password_users_path
  end

  def set_new_password
    @user = User.where(password_reset_token: params[:id]).first unless params[:id].nil?
    if @user.nil?
      flash[:message] = "找回密码链接不正确"
    else
      flash[:message] = "找回密码链接过期" if @user.password_reset_sent_at < Settings.password_reset.expire_time.hours.ago
    end
    redirect_to new_password_reset_path and return unless flash[:message].nil?
  end

  def update
    if @user.update_user_info User.new(params[:user])
      @message ="保存成功"
    else
      @message ="保存失败"
      render :edit and return
    end
    flash[:message] = @message
    redirect_to edit_user_path
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
