class User < ActiveRecord::Base
  has_many :rosters, dependent: :destroy

  validates_presence_of     :username, unless: :guest?
  validates_uniqueness_of   :username, allow_blank: true
  validates_confirmation_of :password

  has_secure_password(validations: true)

  def self.new_guest
    new { |u| u.guest = true }
  end

end