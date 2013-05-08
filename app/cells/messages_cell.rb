class MessagesCell < Cell::Rails

  def index args
    @message = args[:message]
    render
  end

  def data_empty args
    @alert_info = args[:message]
  end

end
