# -*- coding: utf-8 -*-

class UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, except: [:new,:create]
#  load_and_authorize_resource

  def new
    @user = User.new
  end

  def create
    if @user.save
      flash[:message] = "注册成功!"
      redirect_to :controller => :dashboard, :action=>:index
    else
      render :new
    end
  end


  def change_password
    @user ||= current_user
  end

  def update_password
    unless (@message = @user.validate_old_password(User.new(params[:user])))
      if @user.update_password params[:user][:password].to_s
        @message ="保存成功"
      else
        @message ="保存失败"
        render :change_password and return
      end
    end

    flash[:message] = @message
    redirect_to change_password_users_path
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
end
