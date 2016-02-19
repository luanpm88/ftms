class Delivery < ActiveRecord::Base
  belongs_to :course_register
  belongs_to :user
  belongs_to :contact
  has_many :delivery_details, :dependent => :destroy
  after_save :update_statuses
  
  
  def update_statuses
    course_register.update_statuses
    course_register.books_contacts.each do |bc|
      bc.update_statuses
    end
  end
  
  def update_deliveries(params)
    params.each do |row|
      if row[1]["book_id"].present? && row[1]["quantity"].to_f > 0
        dd = self.delivery_details.new
        dd.book_id = row[1]["book_id"]
        dd.books_contact_id = row[1]["books_contact_id"]
        dd.quantity = row[1]["quantity"]
      end
    end
  end
  
  def trash
    self.update_attribute(:status, 0)
  end
  
end
