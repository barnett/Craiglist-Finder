class Room < ActiveRecord::Base
  belongs_to :user
  validates :href,  uniqueness: { scope: :user_id }, presence: true
  validates :email, uniqueness: { scope: :user_id }, presence: true, allow_nil: true
  scope :need_emails, -> { where(emailed_at: nil).where('email IS NOT NULL') }
end
