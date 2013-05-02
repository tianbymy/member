class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :current_user
  def current_user
    @user ||= User.where(login: session[:login]).first if session[:login]
    @user ||= User.new
  end

end
