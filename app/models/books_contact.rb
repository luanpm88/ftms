class BooksContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :book
  
  belongs_to :course_register
  belongs_to :discount_program
  
  def volumns
    b_ids = self.volumn_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
    return Book.where(id: b_ids)
  end  
  def price=(new)
    self[:price] = new.to_s.gsub(/\,/, '')
  end
  def discount=(new)
    self[:discount] = new.to_s.gsub(/\,/, '')
  end
  
  def total
    price - discount.to_f - discount_program_amount
  end
  
  def discount_program_amount
    return 0.00 if discount_program.nil?
    
    return discount_program.type_name == "percent" ? (discount_program.rate/100)*price : discount_program.rate
  end
end
