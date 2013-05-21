# encoding: utf-8
class UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, only: [:index,:update,:change_password,:edit,:reset_password]
  before_filter :current_user, only: [:change_password,:edit_user]
  before_filter :find_ldap_by_login, only: [:update_info,:edit,:destroy,:reset_password,:update_password]
  before_filter :authorize_admin, only: [:index, :destroy]
  # load_and_authorize_resource
  
  def index
    @users = User.all_ldap
  end

  def search
    @users = User.where_ldap({:displayName => params[:q], :uid => params[:q]}) if params[:q]
    render :index
  end

  def create
    if @user.create_ldap
      Resque.enqueue(Email,"四川生产服务网-用户注册信息",Email.to_html("new_register",params[:user]),@user.mail)
      redirect_to Settings.register_redirect
    else
      render :new
    end
  end

  def update_password
    bind_password_value
    if @user.validate_password
      if @user.update_password
        if request.put?
          redirect_to change_password_users_path,:notice => "修改成功" and return if @user.attributes.include?("old_password")
          redirect_to Settings.home_page_url and return
        end
        redirect_to users_path,:notice => "修改成功" and return if request.post?
      end
    end
    render :change_password and return if request.put?
    redirect_to users_path,:notice => "修改失败" if request.post?
  end

  def reset_password
    @user = User.find_by_login(params[:login]) unless params[:login].to_s.empty? 
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

  def update_info
    if @user.update_info(params[:user])
      flash[:notice] ="保存成功"
    else
      flash[:notice] ="保存失败"
      render :edit_user and return if request.put?
    end
    redirect_to edit_user_users_path if request.put?
    redirect_to users_path if request.post?
  end

  def destroy
    if @user and @user.delete_user
      flash[:notice] = "删除成功"
    else
      flash[:notice] = "删除失败"
    end
    redirect_to users_path
  end

  private

  def find_ldap_by_login
    @user = User.find_by_login(params[:login]) unless params[:login].to_s.empty?
  end

  def bind_password_value
    params[:user].each do |k,v|
      @user[k.to_sym] = v
    end
  end
  def authorize_admin
    unless Settings.admin_user.split(",").include?(current_user.login)
      redirect_to root_path, :notice => '权限不足'
    end
  end
end
