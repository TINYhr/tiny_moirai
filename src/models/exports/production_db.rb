module Exports
  class ProductionDb < ActiveRecord::Base
    belongs_to :user
  end
end
