# encoding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    @user ||= User.where(login: session[:login]).first if session[:login]
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self, root_url)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :notice => "权限不足"
  end

end
