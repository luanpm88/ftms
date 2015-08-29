class BooksContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :book
  
  belongs_to :course_register
  belongs_to :discount_program
  
  #def volumns
  #  b_ids = self.volumn_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
  #  return Book.where(id: b_ids)
  #end  
  def price=(new)
    self[:price] = new.to_s.gsub(/\,/, '')
  end
  def discount=(new)
    self[:discount] = new.to_s.gsub(/\,/, '')
  end
  
  def self.all_delivery_waiting
    self.includes(:book, :course_register).where(course_registers: {cache_delivery_status: "not_delivered"}).order("books.name")
  end
  
  def total
    price*quantity - discount.to_f - discount_program_amount
  end
  
  def discount_program_amount
    return 0.00 if discount_program.nil?
    
    return discount_program.type_name == "percent" ? (discount_program.rate/100)*price : discount_program.rate
  end
  
  def remain
    quantity - delivered_count
  end
  
  def max_delivery
    remain > book.stock ? book.stock : remain
  end
  
  def delivered_count
    course_register.all_deliveries.joins(:delivery_details)
                              .where(delivery_details: {book_id: self.book_id}).sum("delivery_details.quantity")
  end
  
  def delivered?
    remain == 0
  end
  
  def paid_amount
    records = course_register.all_payment_records
    
    total = 0.00
    records.each do |p|
      total += p.payment_record_details.where(books_contact_id: self.id).sum(:amount)
    end
    return total
  end
  
  def remain_amount
    total - paid_amount
  end
  
end
