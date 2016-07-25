class PaymentRecord < ActiveRecord::Base
  belongs_to :bank_account
  belongs_to :course_register
  belongs_to :user
  belongs_to :bank_account
  belongs_to :company, class_name: "Contact"
  belongs_to :paid_contact, class_name: "Contact", foreign_key: "contact_id"
  belongs_to :transfer
  
  belongs_to :account_manager, class_name: "User"
  
  belongs_to :parent, class_name: "PaymentRecord"
  has_one :previous, class_name: "PaymentRecord", foreign_key: "parent_id"
  
  has_many :payment_record_details
  
  include PgSearch
  
  pg_search_scope :search,
                  against: [:note, :cache_search],
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
  
  after_save :update_course_register_statuses
  after_create :update_statuses
  after_create :update_cache_search
  before_destroy :update_last_company_record
  
  def update_last_company_record
    if !company.nil?
      self.previous.update_attribute(:parent_id, nil) if !self.previous.nil?
    end
  end
  
  def update_course_register_statuses
    if !course_register.nil?
      course_register.update_statuses
      course_register.contacts_courses.each do |cc|
        cc.update_statuses
      end
    end
    if !company.nil?
      self.course_registers.each do |cr|
        cr.update_statuses
      end
    end
    if !transfer.nil?
      transfer.update_statuses
    end  
  end
  
  def self.filter(params, user)
    @records = self.all
    
    if params["students"].present?
      @records = @records.joins("LEFT JOIN course_registers crs ON crs.id = payment_records.course_register_id")
                          .joins("LEFT JOIN transfers ON transfers.id = payment_records.transfer_id")
      @records = @records.where("crs.contact_id IN (?) OR payment_records.company_id IN (?)  OR transfers.contact_id IN (?) OR payment_records.contact_id IN (?)", params["students"], params["students"], params["students"], params["students"])
    end
    
    if params["company"].present?
      @records = @records.where(company_id: params["company"])
    end
    
    if params["from_date"].present?
      @records = @records.where("payment_records.payment_date >= ?", params["from_date"].to_datetime.beginning_of_day)
    end
    if params["to_date"].present?
      @records = @records.where("payment_records.payment_date <= ?", params["to_date"].to_datetime.end_of_day)
    end
    
    if params["account_manager"].present?
      @records = @records.joins(:course_register => :contact)
      @records = @records.where("contacts.account_manager_id = ?", params["account_manager"])
    end
    
    if params["bank_account"].present?
      @records = @records.where("payment_records.bank_account_id = ?", params["bank_account"])
    end
    
    if params["courses"].present?
      @records = @records.joins(:course_register => :contacts_courses)
      @records = @records.where("contacts_courses.course_id = ?", params["courses"])
    end
    
    
    if params["receivable"].present? && params["payment_for"] == "company"
      @records = @records.where.not(company_id: nil).where("payment_records.cache_payment_status LIKE ?", "%#{params["receivable"]}%")
    end
    
    if params["payment_for"].present?
      if params["payment_for"] == "company"
        @records = @records.where.not(company_id: nil)
      elsif params["payment_for"] == "transfer"
        @records = @records.where.not(transfer_id: nil)
      elsif params["payment_for"] == "custom"
        @records = @records.where.not(contact_id: nil)
      #else
      #  @records = @records.where(company_id: nil).where(transfer_id: nil)
      end      
    end    
    
    if params["status"].present?
      @records = @records.where(status: params["status"])
    end
    
    if params["user"].present?
        @records = @records.where("payment_records.cache_search LIKE ?", "%EC[#{params["user"]}]%")
    end
    
    ## role
    #if !user.has_role?("manager") && !user.has_role?("admin") && !user.has_role?("accountant")
    #  @records = @records.joins(:course_register => :contact)
    #                      .where("contacts.account_manager_id = ?", user.id)
    #end
    
     
     return @records
  end
  
  def self.datatable(params, user)
    @records = self.filter(params, user).where(parent_id: nil)
    
    #@records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    @records = @records.where("LOWER(payment_records.cache_search) LIKE ?", "%#{params["search"]["value"].unaccent.strip.downcase}%") if params["search"].present? && !params["search"]["value"].empty?
    #if !params["search"]["value"].empty?
    #  q = params["search"]["value"].downcase
    #  @records = @records.joins(:course_register => :contact, :course => :course_types)
    #                      .where("LOWER(contacts.name) LIKE ? OR course_types.short_name LIKE ?", q, q)
    #end
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "payment_records.payment_date"
      when "5"
        order = "payment_records.payment_date"
      else
        order = "payment_records.payment_date"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "payment_records.payment_date DESC, payment_records.created_at DESC"
    end    
    @records = @records.order(order) if !order.nil? && !params["search"]["value"].present?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 10
    @records.each do |item|
      item = [
              "<div item_id=\"#{item.id.to_s}\" class=\"main_part_info checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
              item.contact.contact_link,
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              ""
              #'<div class="text-left">'+item.description+"</div>",
              #'<div class="text-right">'+ApplicationController.helpers.format_price(item.ordered_total)+"</div>",
              #'<div class="text-right">'+item.display_paid_amount+'</div>',
              #'<div class="text-right">'+item.paid_on+"<br /><strong>by:</strong><br />"+item.user.staff_col+"</div>",
              #'<div class="text-center">'+item.bank_account_name+"</div>",
              #'<div class="text-right">'+ApplicationController.helpers.format_price(item.remain)+"</div>",
              #'<div class="text-center">'+item.staff_col+"</div>",
              #'<div class="text-center">'+item.display_statuses+"</div>",
              #""
              #'<div class="text-right">'+ApplicationController.helpers.format_price(item.amount)+"</div>",
              #'<div class="text-center">'+item.payment_date.strftime("%d-%b-%Y")+"</div>",
              #'<div class="text-left">'+item.note+"</div>",
              ##'<div class="text-center">'+item.course_register.display_payment_status+"</div>",
              #'<div class="text-center">'+item.course_register.course_register_link+"</div>",
              #'<div class="text-right">'+ApplicationController.helpers.format_price(item.course_register.remain_amount)+"</div>",
              #'<div class="text-center">'+item.course_register.user.staff_col+"</div>",  
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
  
  def staff
    if !company.nil?
      account_manager
    elsif !transfer.nil?
      transfer.contact.account_manager
    elsif !contact_id.nil?
      paid_contact.account_manager
    else
      course_register.account_manager
    end    
  end
  
  def staff_col
    staff.staff_col
  end
  
  def ec
    if !company.nil?
      account_manager
    elsif !transfer.nil?
      transfer.user
    elsif !contact_id.nil?
      contact.account_manager
    else
      course_register.account_manager
    end    
  end
  
  def paid_on
    if !company.nil?
      (company_records.map {|r| r.payment_record_link(payment_date.strftime("%d-%b-%Y"))}).join("<br />")
    elsif !transfer.nil?
      payment_date.strftime("%d-%b-%Y")
    elsif !contact_id.nil?
      payment_date.strftime("%d-%b-%Y")
    else
      self.payment_record_link      
    end    
  end
  
  def bank_account_name
    if company.nil?
      self.bank_account.name
    else
      (company_records.map {|r| r.bank_account.name}).join("<br />")
    end    
  end
  
  def payment_record_link(title=nil)
    title = title.nil? ? "<i class=\"icon icon-print\"></i> Receipt [#{self.payment_date.strftime("%d-%b-%Y")}]".html_safe : title
    ActionController::Base.helpers.link_to(title, {controller: "payment_records", action: "show", id: self.id, tab_page: 1}, title: "Receipt [#{self.payment_date.strftime("%d-%b-%Y")}]", class: "tab_page")
  end
  
  def contact
    if !company.nil?
      company
    elsif !transfer.nil?
      transfer.contact
    elsif !contact_id.nil?
      paid_contact
    else
      course_register.contact
    end
  end
  
  def description_raw
    if !company.nil?
      paper_count = 0
      students = {}
      course_registers.each do |cr|
        paper_count += cr.contacts_courses.count
        students[cr.contact_id] = students[cr.contact_id].nil? ? 1 : students[cr.contact_id] + 1
      end
      
      return "Student count: #{students.count.to_s}; Paper count: #{paper_count.to_s}"
    elsif !transfer.nil?
      "Defer/Transfer at [#{transfer.created_at.strftime("%d-%b-%Y")}]"
    elsif !contact_id.nil?
      "Custom payment at [#{created_at.strftime("%d-%b-%Y")}]"
    else
      course_register.course_list_raw(false)+"; "+course_register.book_list_raw(false)
    end
  end
  
  def description
    if !company.nil?
      paper_count = 0
      students = {}
      course_registers.each do |cr|
        paper_count += cr.contacts_courses.count
        students[cr.contact_id] = students[cr.contact_id].nil? ? 1 : students[cr.contact_id] + 1
      end
      
      return "<span class=\"text-nowrap\">Student count: <strong>#{students.count.to_s}</strong></span><br /><span class=\"text-nowrap\">Paper count: <strong>#{paper_count.to_s}<strong></span>"
    elsif !transfer.nil?
      "Defer/Transfer at [#{transfer.created_at.strftime("%d-%b-%Y")}]"
    elsif !contact_id.nil?
      "<span class='text-nowrap'>[Custom payment]</span><br /><br />" + self.note
    else
      course_register.course_list(false)+course_register.book_list(false)
    end
  end
  
  def company_records
    records = []    
    interval = last_company_record
    records << interval
    while !interval.previous.nil? do
      interval = interval.previous
      records << interval
    end
    
    return records
  end
  
  def last_company_record
    result = self
    while !result.parent.nil? do
      result = result.parent
    end    
    return result
  end
  
  def first_company_record
    result = self
    while !result.previous.nil? do
      result = result.previous
    end    
    return result
  end
  
  def ordered_total
    if !company.nil?
      first_company_record.amount
    elsif !transfer.nil?
      transfer.total
    elsif !contact_id.nil?
      amount
    else
      course_register.total
    end
  end
  
  def remain
    if !company.nil?
      amount - total
    elsif !transfer.nil?
      transfer.remain
    elsif !contact_id.nil?
      0
    else
      return course_register.remain_amount(self.payment_date)
    end
  end
  
  def paid_amount
    result = 0.0
    company_records.each do |pr|
      result += pr.total
    end
    return result
  end
  
  def display_paid_amount
    if !company.nil?
      (company_records.map {|r| ApplicationController.helpers.format_price_round(r.total)}).join("<br />")
    else
      ApplicationController.helpers.format_price_round(paid_amount)
    end
  end
  
  def payment_status
    if !company.nil?
      str = []
      if paid?
        str << "paid"
      else
        str << "receivable"
      end
      return str      
    elsif !transfer.nil?
      transfer.payment_status
    elsif !contact_id.nil?
      ["paid"]
    else
      return course_register.payment_status
    end
  end
  
  def update_statuses
    self.update_attribute(:cache_payment_status, self.payment_status.join(","))
    course_registers.each do |cr|
      cr.update_statuses
    end
  end
  
  def self.datatable_payment_list(params, user)
    @records = ContactsCourse.joins(:course_register, :contact).where("course_registers.parent_id IS NULL").where("course_registers.status LIKE ?", "%[active]%")
    
    course_ids = nil
    if params["intake_year"].present? && params["intake_month"].present?
      @records = Course.where("EXTRACT(YEAR FROM courses.intake) = ? AND EXTRACT(MONTH FROM courses.intake) = ? ", params["intake_year"], params["intake_month"]).map(&:id)
    elsif params["intake_year"].present?
      course_ids = Course.where("EXTRACT(YEAR FROM courses.intake) = ? ", params["intake_year"]).map(&:id)      
    elsif params["intake_month"].present?
      course_ids = Course.where("EXTRACT(MONTH FROM courses.intake) = ? ", params["intake_month"]).map(&:id)
    end    
    @records = @records.where(course_id: course_ids) if !course_ids.nil?
    
    if params["upfront"].present?
      @records = @records.includes(:course).where(courses: {upfront: params["upfront"]})
    end
    
    if params["course_types"].present?
      @records = @records.joins(:course)
                          .where(courses: {course_type_id: params["course_types"].split(",")})
    end
    
    if params["subjects"].present?
      @records = @records.joins(:course)
                          .where(courses: {subject_id: params["subjects"]})
    end
    
    if params["student"].present?
      @records = @records.where(:contact_id => params["student"])
    end
    
    if params["payment_statuses"].present?
      @records = @records.where("contacts_courses.cache_payment_status LIKE ?", "%"+params["payment_statuses"]+"%")
    end
    
    if params["company"].present?
      @records = @records.includes(:course_register).where(course_registers: {payment_type: "company-sponsored", sponsored_company_id: params["company"]})
    end
    
    if !params["search"]["value"].empty?
      q = params["search"]["value"].downcase
      @records = @records.joins(:contact, :course => :course_types)
                          .where("LOWER(contacts.name) LIKE ? OR course_types.short_name LIKE ?", q, q)
    end
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "contacts.name"
      else
        order = "contacts_courses.created_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "contacts_courses.created_at DESC"
    end
    @records = @records.order(order) if !order.nil? && !params["search"]["value"].present? 
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 6
    @records.each do |item|
      item = [
              "<div class=\"checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
              item.contact.contact_link,
              '<div class="text-left">'+item.course.display_name+"</div>",
              '<div class="text-right"><label class="col_label top0">Total:</label>'+ApplicationController.helpers.format_price_round(item.total)+"<label class=\"col_label top0\">Paid:</label>"+ApplicationController.helpers.format_price_round(item.paid)+"<label class=\"col_label top0\">Receivable:</label>"+ApplicationController.helpers.format_price_round(item.remain)+"</div>",
              '<div class="text-center">'+item.display_payment_status+item.course_register.display_payment+"</div>",
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
  
  def paid?
    if company.nil?
      return total == amount
    else
      return remain == 0
    end    
  end
  
  def trash
    self.update_attribute(:status, 0)
    self.previous.update_attribute(:parent_id, nil) if !self.previous.nil?
  end
  
  def update_payment_record_details(params)
    params.each do |row|
      cc = ContactsCourse.find(row[0])
      if cc.present? && (row[1]["amount"].present? || row[1]["total"].present?)
        pd = self.payment_record_details.new
        pd.amount = row[1]["amount"]
        pd.contacts_course_id = row[0]
        if cc.no_price?
          pd.total = row[1]["total"]
        end        
      end
    end

  end
  
  def update_company_payment_record_details(params)
    params.each do |row|
      if row[1]["amount"].present? && row[1]["course_type_id"].present?
        pd = self.payment_record_details.new
        pd.amount = row[1]["amount"]
        pd.course_type_id = row[1]["course_type_id"]       
      end
    end

  end
  
  def update_stock_payment_record_details(params)
    params.each do |row|
      bc = BooksContact.find(row[0])
      if bc.present? && (row[1]["amount"].present? || row[1]["total"].present?)
        pd = self.payment_record_details.new
        pd.amount = row[1]["amount"]
        pd.books_contact_id = row[0]
        if bc.no_price?
          pd.total = row[1]["total"]
        end
      end
    end

  end
  
  def total
    if !transfer.nil?
      self.amount
    elsif !contact_id.nil?
      amount
    else
      total = 0.0
      payment_record_details.each do |prd|
        total += prd.real_amount
      end
      return total
    end
  end
  
  def amount=(new)
    self[:amount] = new.to_s.gsub(/\,/, '')
  end
  
  def course_registers
    return [] if self.course_register_ids.nil?
    cr_ids = first_company_record.course_register_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
    return CourseRegister.where(id: cr_ids)
  end
  
  def save_old_record(rid)    
      @old_record = PaymentRecord.find(rid)
      @old_record.parent = self
      @old_record.save
      
      self.company = @old_record.company
      self.course_register_ids = @old_record.course_register_ids
      self.amount = @old_record.remain
      self.save
  end
  
  def update_cache_search
    
    str = []
    str << description
    str << bank_account_name
    str << contact.display_name
    str << contact.display_name.unaccent
    str << staff_col
    str << staff_col.unaccent
    str << user.name
    str << user.name.unaccent
    str << ordered_total.to_s
    str << paid_amount.to_s
    str << remain.to_s
    
    if !company.nil?
      str << "EC["+account_manager_id.to_s+"]"
    elsif !transfer.nil?
      str << "EC["+transfer.user_id.to_s+"]"
    elsif !contact_id.nil?
      str << "EC["+contact.account_manager_id.to_s+"]"
    else
      str << "EC["+course_register.account_manager_id.to_s+"]"      
    end 
    
    update_attribute(:cache_search, str.join(" "))
  end
  
  def self.status_options
    [
      ["Active","1"],
      ["Deleted","0"],
      ["All",""]      
    ]
  end
  
  def display_statuses
    s = status == 1 ? "active" : "deleted"
    result = ["<span title=\"\" class=\"badge user-role badge-info contact-status #{s}\">#{s}</span>"]
    result.join(" ").html_safe
  end
  
  def transferred?
    return course_register.nil? ? false : course_register.transferred?
  end
  
end
