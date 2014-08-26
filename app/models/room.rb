class Room < ActiveRecord::Base
  belongs_to :user
  validates :href, uniqueness: true, presence: true
  validates :email, uniqueness: true, presence: true, allow_nil: true
  scope :need_emails, -> { where(emailed_at: nil).where('email IS NOT NULL') }
end
