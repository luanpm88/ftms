class PaymentRecordDetail < ActiveRecord::Base
  belongs_to :payment_record
  belongs_to :contacts_course
  belongs_to :books_contact
  belongs_to :course_type
  
  def amount=(new)
    self[:amount] = new.to_s.gsub(/\,/, '')
  end
  
  def total=(new)
    self[:total] = new.to_s.gsub(/\,/, '')
  end
  
  def real_amount
    if !books_contact_id.nil?
      return 0 if BooksContact.where(id: books_contact_id).count == 0
    end
    if !contacts_course_id.nil?
      return 0 if ContactsCourse.where(id: contacts_course_id).count == 0
    end
    
    return amount
  end
end
