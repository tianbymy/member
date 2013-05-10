# encoding: utf-8

module UsersHelper
  def user_lock user
    if user.state == "locked"
      "解除锁定"
    else
      "锁定"
    end
  end
end
