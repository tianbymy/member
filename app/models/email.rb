# -*- coding: utf-8 -*-
require 'net/smtp'
require 'erubis'

class Email
  @queue = :email_serve

  def self.perform(subject,content,to)
    sendemail(subject, content, to)
  end

  def self.to_html(template_name,arges)
    eruby = Erubis::Eruby.new(File.read("#{Rails.root}/app/views/email/#{template_name}.html.erb"))
    eruby.result(arges).html_safe
  end

  private
  def self.sendemail(subject,content,to)  
    sendmessage = "From: #{Settings.smtp.nickname} <#{Settings.smtp.username}>\nMIME-Version: 1.0\nContent-type: text/html\nSubject: "+subject +"\n\n"+content  
    smtp = Net::SMTP.start(Settings.smtp.address, Settings.smtp.port, Settings.smtp.helo_domain,
                      Settings.smtp.username, Settings.smtp.password, Settings.smtp.authentication.to_sym)
    smtp.send_message sendmessage, Settings.smtp.username, to
    smtp.finish
  end
end
