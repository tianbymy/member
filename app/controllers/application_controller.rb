class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    @user ||= User.where(login: session[:login]).first if session[:login]
    @user ||= User.new
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self, root_url)
  end

end
