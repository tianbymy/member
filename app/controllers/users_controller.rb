# encoding: utf-8
class UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, only: [:index,:update,:change_password,:edit,:reset_password]
  before_filter :current_user, only: [:change_password,:edit_user]
  load_and_authorize_resource
  

  def index
    User.all_ldap
    @users = User.all.desc(:updated_at).paginate(:page=>params[:page]||1,:per_page=>20)
  end

  def create
    @user.validate_password
    if @user.save
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
      render :edit_user and return
    end
    flash[:message] = @message
    redirect_to edit_user_users_path
  end

  def destroy
    if @user.delete_user
      flash[:notice] = "删除成功"
    else
      flash[:notice] = "删除失败"
    end
    redirect_to users_path
  end

  private

  def bind_password_value
    params[:user].each do |k,v|
      @user[k.to_sym] = v
    end
  end
end
