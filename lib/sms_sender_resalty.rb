require 'message_parser'
require 'normalizer'
require 'response_codes'

module SmsSenderResalty
  require 'net/http'

  include MessageParser
  include Normalizer
  include ResponseCodes

  # According to documentation: http://www.resalty.net/files/RESALTY.NET_HTTP_API.pdf
  def self.send_sms(userid, password, mobile_number, sender, message)
    mobile_number_normalized = Normalizer.normalize_number(mobile_number)
    message_normalized = Normalizer.normalize_message(message)
    http = Net::HTTP.new('resalty.net', 80)
    path = '/api/sendSMS.php'
    params = {
      'userid' => userid,
      'password' => password,
      'to' => mobile_number_normalized,
      'sender' => sender,
      'msg' => message_normalized,
      'encoding' => 'utf-8'
    }
    body = URI.encode_www_form(params)
    headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    response = http.post(path, body, headers)
    error_number = MessageParser.extract_number(response.body, 'Error')
    if response.code.to_i == 200 && !error_number.nil? && error_number == 0
      return { message_id: MessageParser.extract_number(response.body, 'MessageID'), code: 0 }
    elsif response.code.to_i == 200 && !error_number.nil?
      result = ResponseCodes.get_error_send_sms(error_number)
      raise result[:error]
      return result
    elsif response.code.to_i == 200
      result = { error: 'Unexpected response: ' + response.body.to_s }
      raise result[:error]
      return result
    else 
      result = { error: 'Unexpected http response code: ' + response.code.to_s + ' Body: ' + response.body }
      raise result[:error]
      return result
    end
  end

  def self.get_balance(userid, password)
    http = Net::HTTP.new('resalty.net', 80)
    path = '/api/getBalance.php'
    params = {
      'userid' => userid,
      'password' => password
    }
    body = URI.encode_www_form(params)
    headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    response = http.post(path, body, headers)
    if response.body.starts_with?("ERROR")
      result = ResponseCodes.get_error(response.body[5..6])
      raise result[:error]
      return result
    else
      return { balance: response.body.to_i, code: nil }
    end
  end

  def self.query_message(userid, password, msgid)
    http = Net::HTTP.new('resalty.net', 80)
    path = '/api/msgQuery.php'
    params = {
      'userid' => userid,
      'password' => password,
      'msgid' => msgid
    }
    body = URI.encode_www_form(params)
    headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    response = http.post(path, body, headers)
    if response.code.to_i == 200 && !response.body.blank? && response.body.starts_with?("STATUS")
      result = ResponseCodes.get_status(response.body[6..7])
      return result
    elsif response.code.to_i == 200 && !response.body.blank? && response.body.starts_with?("ERROR")
      result = ResponseCodes.get_error(response.body[5..6])
      raise result[:error]
      return result
    else
      result = { error: 'Unexpected http response code: ' + response.code.to_s + ' Body: ' + response.body }
      raise result[:error]
      return result
    end
  end
end
