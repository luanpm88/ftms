class DeliveryDetail < ActiveRecord::Base
  belongs_to :book
  belongs_to :delivery
end
