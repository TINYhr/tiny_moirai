class HerokuAccess < ActiveRecord::Base
  belongs_to :user

  scope :ready, -> { where(active: nil) }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def fingerprint
    SSHKey.fingerprint(public_key)
  end
end
