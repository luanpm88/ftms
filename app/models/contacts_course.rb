class ContactsCourse < ActiveRecord::Base
  belongs_to :contact
  belongs_to :course
  
  belongs_to :course_register
  belongs_to :discount_program
  
  has_many :payment_record_details
  
  after_create :update_statuses
  after_create :enable_report
  
  
  def enable_report
    self.course.remove_no_report_contact(self.contact)
  end
  
  def self.all_contacts_courses
    ContactsCourse.all
  end
  
  def courses_phrases
    return [] if self.courses_phrase_ids.nil?
    cp_ids = self.courses_phrase_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
    return CoursesPhrase.where(id: cp_ids).includes(:phrase).order("phrases.name, courses_phrases.start_at")
  end
  
  def courses_phrase_list
    return "" if no_price? || courses_phrases.empty?
    Course.render_courses_phrase_list(courses_phrases.joins(:phrase).order("phrases.name, courses_phrases.start_at"))
  end
  
  def price=(new)
    self[:price] = new.to_s.gsub(/\,/, '')
  end  
  def discount=(new)
    self[:discount] = new.to_s.gsub(/\,/, '')
  end
  def hour=(new)
    self[:hour] = new.to_s.gsub(/\,/, '')
  end
  def money=(new)
    self[:money] = new.to_s.gsub(/\,/, '')
  end
  def additional_money=(new)
    self[:additional_money] = new.to_s.gsub(/\,/, '')
  end
  
  def total
    if price != -1
      list_price = price
      pricing = price
      
      # transfer/defer
      if hour.to_f > 0
        pricing = additional_money.to_f - money.to_f
      end
      
      # discount program
      all_discount_programs.each do |row|
        if row["id"].present?
          dp = DiscountProgram.find(row["id"])
          if row["discount_program_type"] == "list_price"
            d_amount = dp.type_name == "percent" ? (dp.rate/100)*list_price : dp.rate
          else
            d_amount = dp.type_name == "percent" ? (dp.rate/100)*pricing : dp.rate
          end
          
          pricing -= d_amount
        end
      end
      
      return pricing - other_discount_amount.to_f - money.to_f
    else     
      return no_price_payment_record_detail.nil? ? 0 : no_price_payment_record_detail.total.to_f
    end
  end
  
  def no_price_payment_record_detail
    payment_record_details.includes(:payment_record).where(payment_records: {status: 1}).first
  end
  
  def no_price?
    #price == -1    
    if price == -1
      # find total in payment record
      no_price_payment_record_detail.nil? ? true : false
    else
      return false
    end
  end
  
  def discount_program_amount_old
    return 0.00 if discount_program.nil?
    
    return discount_program.type_name == "percent" ? (discount_program.rate/100)*price : discount_program.rate
  end
  
  def discount_program_amount
    result = 0.00    
    all_discount_programs.each do |row|
      if row["id"].present?
        dp = DiscountProgram.find(row["id"])
        result += dp.type_name == "percent" ? (dp.rate/100)*price : dp.rate
      end
    end
    
    return result
  end
  
  def all_discount_programs
    discount_programs.nil? ? [] : JSON.parse(discount_programs)
  end
  
  def all_other_discounts
    other_discounts.nil? ? [] : JSON.parse(other_discounts)
  end
  
  def other_discount_amount
    result = 0.00
    all_other_discounts.each do |row|
      if row["amount"].present?
        result += row["amount"].to_f
      end
    end    
    return result
  end
  
  def paid(from_date=nil, to_date=nil)
    records = course_register.all_payment_records
    
    total = 0.00
    records.each do |p|
      prds = p.payment_record_details.where(contacts_course_id: self.id)
      if from_date.present? && to_date.present?
        prds = prds.includes(:payment_record)
                    .where("payment_records.payment_date >= ? AND payment_records.payment_date >= ? ", from_date.beginning_of_day, to_date.end_of_day)
      end
      
      prds.each do |prd|
        total += prd.real_amount
      end
    end
    return total
  end
  
  def remain(from_date=nil, to_date=nil)
    total - paid(from_date=nil, to_date=nil)
  end
  
  def report_toggle
    class_name = self.report ? "success" : "none"
    text = self.report ? "UCRS: yes" : "UCRS: no"
    '<a rel="'+self.id.to_s+'" class="badge badge-'+class_name+' report_toggle report_toggle_'+self.id.to_s+'" href="#rt">'+text+'</a>'
  end
  
  def paid?
    paid == total && !no_price?
  end
  
  def out_of_date?
    return false if paid?
    
    return course_register.real_debt_date.nil? ? false : course_register.real_debt_date < Time.now
  end
  
  def payment_status
    str = []
    if paid?
      str << "fully_paid"
    else
      str << "receivable"
    end
    if out_of_date?    
      str << "chase_for_payment"
    end
    
    return str
  end
  
  def display_payment_status
    line = []
    payment_status.each do |s|
      line << "<div class=\"#{s} text-center\">#{s}</div>".html_safe
    end
    
    return line.join("")
  end
  
  def all_payment_records
    course_register.all_payment_records.includes(:payment_record_details).where(payment_record_details: {contacts_course_id: self.id})
  end
  
  def delivery_status
    delivered? ? "delivered" : "not_delivered"
  end
  
  def update_statuses
    # payment
    self.update_attribute(:cache_payment_status, self.payment_status.join(","))
  end
  
  def write_off_amount
    return is_write_off? ? remain : 0.00
  end
  
  def is_write_off?
    return false if !course_register.statuses.include?("active")
    contact.active_courses_with_phrases.each do |row|
      row[:contacts_courses].each do |cc|
        return false if cc.id == self.id
      end
    end
    return self.remain > 0.0 ? true : false
  end
  
  # for old course res: run 1 time
  def self.check_full_course
    self.all.each do |cc|
      cc.check_full_course
    end
  end
  # for old course res: run 1 time
  def check_full_course
    if self.courses_phrases.count == self.course.courses_phrases.count
      self.update_attribute(:full_course, true)
    end
  end
  
end
