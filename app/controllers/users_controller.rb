# encoding: utf-8

# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, only: [:index,:update_info,:change_password,:edit,:reset_password,:edit_user]
  before_filter :current_user
  before_filter :find_ldap_by_login, only: [:update_info,:edit,:destroy,:reset_password,:update_password]
  before_filter :authorize_admin, only: [:index, :destroy,:reset_password]
  before_filter :set_referer, only: [:forgot_password,:new]

  def index
    @users = User.all_ldap
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html {render "new.slim"}
      format.js {render "new.js"}
    end
  end

  def search
    @users = User.where_ldap({:displayName => "*#{params[:q]}*", :uid => "*#{params[:q]}*"}) if params[:q]
  end

  def create
    @user = User.new(params[:user])
    if @user.create_ldap
      Resque.enqueue(Email,"四川生产服务网-用户注册信息",Email.to_html("new_register",params[:user]),@user.mail)
      flash[:notice] = "注册成功"
      if session[:Referer]
        redirect_to session[:Referer]
      else
        redirect_to Settings.register_redirect
      end
    else
      render :new
    end
  end

  def update_own_password
    bind_password_value
    if @user.update_password
      redirect_to change_password_users_path,:notice => "修改成功" 
    else
      render :change_password
    end
  end

  def update_password
    @user = User.find_by_login(params[:login]) unless params[:login].to_s.empty?
    bind_password_value

    if @user.update_password
      #redirect_to users_path,:notice => "修改成功"
      redirect_to request.headers["Referer"], :notice => "修改成功"
    else
      #redirect_to users_path,:notice => "修改失败"
      redirect_to request.headers["Referer"], :notice => "修改失败"
    end
  end

  def set_password
    @user = User.find_by_login(params[:login]) unless params[:login].to_s.empty?
    bind_password_value

    if @user.update_password
      flash[:notice] = "重置成功"
      Resque.redis.del(@user.login)
      if session[:Referer]
        redirect_to session[:Referer]
      else
        redirect_to Settings.site_host
      end 
    else
      redirect_to request.headers["Referer"],:notice => "设置失败,请注意填写格式"
    end
  end

  def edit
    @user = find_ldap_by_login
  end

  def reset_password
    @user = find_ldap_by_login
    render layout: false
  end

  def send_reset_password_email
    user = User.find_by_mail(params[:mail]) unless params[:mail].to_s.empty?
  
    if user.nil?
      flash[:message] = "邮件地址未找到，请重新输入!"
    else
      User.send_password_reset user
      flash[:message] = "重置密码邮件以发送，请注意查收!"
    end
    redirect_to forgot_password_users_path
  end

  def set_new_password
    if params[:login] and params[:token]
      @user = find_ldap_by_login
      token = Resque.redis.get(params[:login])
      if token.nil?
        flash[:message] = "对不起，找回密码链接已经过期，请重新申请"
      else
        if token != params[:token]
          flash[:message] = "找回密码链接不正确"
        end
      end
    end
    redirect_to forgot_password_users_path and return unless flash[:message].nil?
  end

  def update_info
    @user = find_ldap_by_login

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
    if Settings.admin_user.split(",").include?(params[:login])
      flash[:notice] = "不能删除管理员"
    else
      @user = find_ldap_by_login
      if @user and @user.delete_user
        flash[:notice] = "删除成功"
      else
        flash[:notice] = "删除失败"
      end
    end
    redirect_to users_path
  end

  private

  def set_referer
    session[:Referer] = (request.headers["Referer"].to_s.match /http:\/\/.*?(\/)/).to_s
  end

  def find_ldap_by_login
    User.find_by_login(params[:login]) unless params[:login].to_s.empty?
  end

  def bind_password_value
    params[:user].each do |k,v|
      @user[k.to_sym] = v
    end
  end
  def authorize_admin
    unless Settings.admin_user.split(",").include?(@user.login)
      redirect_to root_path, :notice => Settings.no_permission
    end
  end
end
