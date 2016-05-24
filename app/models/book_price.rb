class BookPrice < ActiveRecord::Base
  belongs_to :book
  
  def prices=(array)
    self[:prices] = ApplicationController.helpers.split_prices(array).to_json
  end
  
end
