require 'google/api_client'

class Gmail
  def initialize(user_id)
    @user   = User.find(user_id)
    @client ||= client
    token
  end

  def send_email(email)
    response = @client.execute(
      api_method:  gmail.users.messages.to_h['gmail.users.messages.send'],
      parameters:  { 'userId' => 'me' },
      body_object: { 'raw' => Base64.urlsafe_encode64(message(email)) }
    )
  end

  private

  def client
    api_client = Google::APIClient.new(
      application_name: 'Found-A-Room',
      application_version: '1.0.0'
    )
    api_client.authorization.client_id     = ENV['GOOGLE_CLIENT_ID']
    api_client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']
    api_client
  end

  def gmail
    @client.discovered_api('gmail', 'v1')
  end

  def message(to_email)
    Mail.new(
     to:      to_email,
     from:    @user.email,
     subject: @user.subject,
     body:    @user.message
    ).to_s
  end

  def token(no_refresh = true)
    if (@user.expires_at > utc_time) && no_refresh
      @client.authorization.access_token = @user.token
    else
      @client.authorization.grant_type    = 'refresh_token'
      @client.authorization.refresh_token = @user.refresh_token

      token            = @client.authorization.fetch_access_token!
      @user.token      = token['access_token']
      @user.expires_at = utc_time + token['expires_in']
      @user.save
    end
    @client.authorization.access_token
  end

  def utc_time
    Time.now.utc
  end

end
