# -*- coding: utf-8 -*-
require "cell/rails/helper_api"

class UserCell < Cell::Rails


  def change_password(args)
    @user = args[:user]
    render
  end

  def edit(args)
    @user = args[:user]
    render
  end

end
