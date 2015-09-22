class PaymentRecordDetail < ActiveRecord::Base
  belongs_to :payment_record
  belongs_to :contacts_course
  
  def amount=(new)
    self[:amount] = new.to_s.gsub(/\,/, '')
  end
  
  def total=(new)
    self[:total] = new.to_s.gsub(/\,/, '')
  end
end
