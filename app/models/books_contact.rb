class BooksContact < ActiveRecord::Base
  belongs_to :contact
  belongs_to :book
  
  
  belongs_to :course_register
  belongs_to :discount_program
  
  has_many :books_contacts
  
  after_create :update_statuses
  
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
    if remain > book.stock
      book.stock > 0 ? book.stock : 0
    else
      remain
    end
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
  
  def self.filter(params, user)
    @records = self.joins(:book, :course_register, :contact).where("course_registers.parent_id IS NULL").where("course_registers.status LIKE ?", "%[active]%")
    
    if params["course_types"].present?
      @records = @records.includes(:book)
                          .where(books: {id: params["course_types"].split(",")})
    end
    
    if params["subjects"].present?
      @records = @records.includes(:book => :subject)
                          .where(subjects: {id: params["subjects"].split(",")})
    end
    
    if params["student"].present?
      @records = @records.where(:contact_id => params["student"])
    end
    
    if params["delivery_statuses"].present?
      @records = @records.where(cache_delivery_status: params["delivery_statuses"])
    end
    
    if params["books"].present?
      @records = @records.where(book_id: params["books"].split(","))
    end
    
    if params[:stock_types].present?
      @records = @records.where(books: {stock_type_id: params[:stock_types]})
    end
    
    if params[:courses].present?
      @records = @records.includes(:course_register => :contacts_courses).where(contacts_courses: {course_id: params[:courses].split(",")})
    end

    
    course_ids = nil
    if params["intake_year"].present? && params["intake_month"].present?
      course_ids = Course.where("EXTRACT(YEAR FROM courses.intake) = ? AND EXTRACT(MONTH FROM courses.intake) = ? ", params["intake_year"], params["intake_month"]).map(&:id)
    elsif params["intake_year"].present?
      course_ids = Course.where("EXTRACT(YEAR FROM courses.intake) = ? ", params["intake_year"]).map(&:id)
    elsif params["intake_month"].present?
      course_ids = Course.where("EXTRACT(MONTH FROM courses.intake) = ? ", params["intake_month"]).map(&:id)
    end
    
    @records = @records.joins(:contacts_courses => :course).where(courses: {id: course_ids}) if !course_ids.nil?
    
    return @records
  end
  
  def self.datatable(params, user)
    @records = self.filter(params, user)
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "contacts.name"
      else
        order = "books_contacts.created_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "books_contacts.created_at DESC"
    end
    
    @records = @records.order(order) if !order.nil?
    
    
    ## STATISTICS
    #counting = []
    #course_types = CourseType.where(id: Book.where(id: @records.map(&:book_id)).map(&:course_type_id)).order(:short_name)
    #course_types.each do |ct|
    #  row = {}
    #  row[:course_type] = ct
    #  row[:count] = @records.joins(:book => :course_type).where(course_types: {id: ct.id})
    #  
    #  counting << row
    #end
    
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 6
    @records.each do |item|      
      item = [
              "<div class=\"checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
              item.contact.contact_link,
              item.book.display_name,
              '<div class="text-center">'+ item.quantity.to_s+"</div>", 
              '<div class="text-center">'+ item.display_delivery_status+"</div>",
              '<div class="text-center">'+ item.course_register.course_register_link+"</div>", 
              ""
            ]
      data << item
      
    end
    
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    return {result: result, items: @records, actions_col: actions_col}
    
  end
  
  def display_delivery_status    
    if delivered?
      return "<a class=\"check-radio ajax-check-radioz\" href=\"#c\"><i class=\"#{delivered?.to_s} icon-check#{delivered? ? "" : "-empty"}\"></i></a>"
    else
      return "<div class=\"nowrap check-radio\">"+ActionController::Base.helpers.link_to("<i class=\"#{delivered?.to_s} icon-check#{delivered? ? "" : "-empty"}\"></i>".html_safe, {controller: "deliveries", action: "new", course_register_id: self.course_register_id, tab_page: 1}, title: "Deliver Stock: #{self.contact.display_name}", title: 'Materials Delivery', class: "tab_page")+"</div>"
    end

  end
  
  def delivery_status
    delivered? ? "delivered" : "not_delivered"
  end
  
  def update_statuses
    # delivery
    self.update_attribute(:cache_delivery_status, self.delivery_status)
  end
  
  def all_deliveries
    course_register.all_deliveries.includes(:delivery_details).where(delivery_details: {book_id: book_id})
  end
  
  def all_payment_records
    course_register.all_payment_records.includes(:payment_record_details).where(payment_record_details: {books_contact_id: self.id})
  end
  
end
