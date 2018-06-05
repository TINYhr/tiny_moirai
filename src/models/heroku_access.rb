class HerokuAccess < ActiveRecord::Base
  belongs_to :user

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
end
