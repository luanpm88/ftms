class DeliveryDetail < ActiveRecord::Base
  belongs_to :book
  belongs_to :delivery
  belongs_to :books_contact
end
