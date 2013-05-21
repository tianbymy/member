# encoding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    if session[:cas_user]
      unless @user ||= User.where(login: session[:cas_user]).first
        user = User.manager.get_by_uid(session[:cas_user])
        @user = User.new({login: user[:uid], name: user[:display], sn: user[:sn], cn: user[:cn], mail: user[:mail], mobile: user[:mobile]})
        @user.save
      end
    end
    @user
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self, root_url)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :notice => "权限不足"
  end

end
