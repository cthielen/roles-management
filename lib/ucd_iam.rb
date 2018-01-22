module UcdIam
  require 'net/https'
  require 'json'

  IAM_URL = ENV['IAM_URL']
  IAM_API_KEY = ENV['IAM_API_KEY']

  def self.fetch_sis_majors
    url = "#{IAM_URL}/api/iam/orginfo/sis/majors?key=#{IAM_API_KEY}&v=1.0"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    return nil if response.code.to_i == 404

    begin
      json = JSON.parse(response.body)
    rescue JSON::ParserError
      return nil # not a 404 but JSON response did not make sense
    end

    return json['responseData']['results'] # rubocop:disable Style/RedundantReturn
  end

  def self.fetch_bous
    url = "#{IAM_URL}/api/iam/orginfo/pps/divisions?key=#{IAM_API_KEY}&v=1.0"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    return nil if response.code.to_i == 404

    begin
      json = JSON.parse(response.body)
    rescue JSON::ParserError
      return nil # not a 404 but JSON response did not make sense
    end

    return json['responseData']['results'] # rubocop:disable Style/RedundantReturn
  end
end