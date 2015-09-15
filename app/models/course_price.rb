class CoursePrice < ActiveRecord::Base
  belongs_to :course
  
  def prices=(array)
    self[:prices] = ApplicationController.helpers.split_prices(array).to_json
  end
  
  def amount=(new_price)
    self[:amount] = new_price.to_s.gsub(/\,/, '')
  end
  
end
