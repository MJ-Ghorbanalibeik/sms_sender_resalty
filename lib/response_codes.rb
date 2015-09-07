module ResponseCodes
  def self.get_error_send_sms(error_code)
    # Based on http://www.resalty.net/files/RESALTY.NET_HTTP_API.pdf
    { code: error_code.to_i }.merge (case error_code
      when 1
        { error: 'General Wrong API calling' }
      when 2
        { error: 'Wrong API parameter(s) for [send]' }
      when 3
        { error: 'Username or password is incorrect or you don\'t have the permission to use this service' }
      when 4
        { error: 'Sender name must not exceed 11 characters or 16 numbers' }
      when 5
        { error: 'The receiver number must consist of numbers only without + or leading zeros' }
      when 6
        { error: 'Sender name must be in English letters only' }
      when 7
        { error: 'You cannot send to this amount at the same time, please divide this messaging to many groups' }
      when 8
        { error: 'It is not allowed to use sender name you have entered, please choose another one' }
      when 9
        { error: 'The message content you want to send is not allowed... If you think this is error, please contact technical support' }
      when 10
        { error: 'You have not enough balance to send this message' }
      else
        { error: 'Unknown error code' }
    end)
  end

  def self.get_error(error_code)
    { code: error_code.to_i }.merge (case error_code
      when '10'
        { error: 'Wrong API parameter(s) for [balance], Wrong parameter' }
      when '11'
        { error: 'Wrong API parameter(s) for [balance], Wrong password or username' }
      when '12'
        { error: 'Wrong API parameter(s) for [balance], Wrong parameter' }
      when '13'
        { error: 'Wrong API parameter(s) for [balance], Wrong Message ID' }
      else
        { error: 'Unknown error code' }
    end)
  end

  def self.get_status(status)
    { code: status.to_i }.merge (case status
      when '01'
        { result: 'The message is on the send queue' }
      when '02'
        { result: 'The message has been failed' }
      when '03'
        { result: 'The message has been rejected' }
      when '04'
        { result: 'The message has been stopped' }
      when '05'
        { result: 'The message has been sent successfully' }
      else
        { error: 'Unknown status' }
    end)
  end
end
