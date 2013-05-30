module UsersHelper
  def will_page_size count,size
    if (count % size) == 0
      count/size
    else
      (count/size) +1
    end
  end

  def get_current_users users,current_page,size
    if (current_page.to_i <= (will_page_size users.size,size)) and current_page.to_i > 0
      users[(current_page.to_i-1)*size..current_page.to_i*size]
    else
      users.first(size)
    end
  end
end
