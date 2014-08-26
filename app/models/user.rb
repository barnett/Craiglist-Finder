class User < ActiveRecord::Base
  has_many :rooms, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

  before_save :set_housing, if: :url_changed?, on: :update

  scope :ready, -> do
    where('last_sign_in_at > (?)', 7.days.ago)
      .where('url IS NOT NULL')
      .where('token IS NOT NULL')
      .where('message IS NOT NULL')
      .where('subject IS NOT NULL')
      .where('housing_type IS NOT NULL')
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    creds = access_token.credentials
    data  = access_token.info

    user = signed_in_resource ||
    User.where(:uid => access_token.uid).first ||
    User.where(:email => access_token.info.email).first ||
    User.new(
      email:         data.email,
      name:          data.name,
      refresh_token: creds.refresh_token,
      uid:           access_token.uid,
      password:      Devise.friendly_token[0,20]
    )
    user.expires_at    = Time.at(creds.expires_at)
    user.token         = creds.token
    user.save
    user
  end

  def f_name
    name.split(' ')[0]
  end

  def ready?
    url && token && message && subject && housing_type
  end

  def set_housing
    write_attribute(:housing_type, url.include?('apa') ? 'apa' : 'sub')
  end
end
