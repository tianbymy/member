# -*- coding: utf-8 -*-
class UserInfo
  def self.current_user
    Thread.current[:current_user]
  end
end

