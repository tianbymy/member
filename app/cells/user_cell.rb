# -*- coding: utf-8 -*-
require "cell/rails/helper_api"
include UsersHelper

class UserCell < Cell::Rails

  def change_password(args)
    @user = args[:user]
    render
  end

  def index(args)
    @users = args[:users]
    render
  end

  def edit(args)
    @user = args[:user]
    render
  end

  def update_info(args)
    @user = args[:user]
    render
  end

  def new(args)
    @user = args[:user]
    render
  end

end
