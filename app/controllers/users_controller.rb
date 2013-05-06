# encoding: utf-8
class UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, except: [:new,:create]
  
  before_filter :find_user, only: [:create]

  def new
    @user = User.new
  end

  def create
    @user.validate_presence([:login,:sn,:cn,:name,:email,:phone,:password,:id_card])
    @user.validate_format({:email => /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/,:login => /[a-zA-Z0-9]{6,}/,:password => /[a-zA-Z0-9]{6,}/,:id_card => /^(\d{15}$|^\d{18}$|^\d{17}(\d|X|x))$/,:phone => /^\d{11}$/})
    @user.validate_confirmation :password,:password_confirmation

    if @user.errors.empty?

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

  private

  def find_user
    @user = User.new(params[:user])
  end
end
