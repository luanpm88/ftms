class ContactsCourse < ActiveRecord::Base
  belongs_to :contact
  belongs_to :course
  
  belongs_to :course_register
  belongs_to :discount_program
  
  def self.all_contacts_courses
    ContactsCourse.all
  end
  
  def courses_phrases
    cp_ids = self.courses_phrase_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
    return CoursesPhrase.where(id: cp_ids)
  end
  
  def courses_phrase_list
    Course.render_courses_phrase_list(courses_phrases.joins(:phrase).order("phrases.name, courses_phrases.start_at"))
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
  
  def paid(from_date=nil, to_date=nil)
    records = course_register.all_payment_records
    
    total = 0.00
    records.each do |p|
      prds = p.payment_record_details.where(contacts_course_id: self.id)
      if from_date.present? && to_date.present?
        prds = prds.includes(:payment_record)
                    .where("payment_records.payment_date >= ? AND payment_records.payment_date >= ? ", @from_date.beginning_of_day, @to_date.end_of_day)
      end
      
      total += prds.sum(:amount)
    end
    return total
  end
  
  def remain(from_date=nil, to_date=nil)
    total - paid(from_date=nil, to_date=nil)
  end
  
  def report_toggle
    class_name = self.report ? "success" : "none"
    text = self.report ? "report: yes" : "report: no"
    '<a rel="'+self.id.to_s+'" class="badge badge-'+class_name+' report_toggle report_toggle_'+self.id.to_s+'" href="#rt">'+text+'</a>'
  end
  
end
