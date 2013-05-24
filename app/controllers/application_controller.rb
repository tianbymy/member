# encoding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    @user = User.find_by_login(session[:cas_user]) if session[:cas_user]
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self, root_url)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :notice => Settings.no_permission
  end

end
