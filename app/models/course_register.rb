class CourseRegister < ActiveRecord::Base
  belongs_to :user
  
  has_many :contacts_courses, class_name: "ContactsCourse", foreign_key: "course_register_id", :dependent => :destroy
  has_many :books_contacts, class_name: "BooksContact", foreign_key: "course_register_id", :dependent => :destroy
  
  belongs_to :contact
  belongs_to :discount_program
  belongs_to :bank_account
  belongs_to :sponsored_company, class_name: "Contact"
  
  belongs_to :account_manager, class_name: "User"
  
  has_many :deliveries, :dependent => :destroy
  
  has_many :payment_records, :dependent => :destroy
  
  has_one :last_payment_record, -> { order created_at: :desc }, class_name: 'PaymentRecord', foreign_key: "course_register_id"
  
  ########## BEGIN REVISION ###############
  validate :check_exist
  
  has_many :drafts, :class_name => "CourseRegister", :foreign_key => "parent_id", :dependent => :destroy
  belongs_to :parent, :class_name => "CourseRegister", :foreign_key => "parent_id"  
  has_one :current, -> { order created_at: :desc }, class_name: 'CourseRegister', foreign_key: "parent_id"
  ########## END REVISION ###############
  
  include PgSearch
  
  pg_search_scope :search,
                  against: [:mailing_address, :cache_search],
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
  
  after_create :update_statuses
  after_create :update_cache_search
  
  def all_deliveries
    deliveries.where(status: 1).order("deliveries.delivery_date DESC, deliveries.created_at DESC")
  end
  
  def all_payment_records
    payment_records.where(status: 1).order("payment_date DESC, payment_records.created_at DESC")
  end
  
  def save_contacts_courses(cids)
    contact = self.contact
    
    cids.each do |row|
      if row[1]["course_id"].present?
        cc = contact.contacts_courses.new
        cc.course_id = row[1]["course_id"]
        cc.course_register_id = self.id
        cc.courses_phrase_ids = "["+row[1]["courses_phrase_ids"].join("][")+"]"
        cc.upfront = row[1]["upfront"]
        cc.price = row[1]["price"]
        cc.discount_program_id = row[1]["discount_program_id"]
        cc.discount = row[1]["discount"]
        cc.save if ContactsCourse.where(contact_id: cc.contact_id, course_id: cc.course_id).empty?
      end
    end
    
    #change contact type when add course
    contact.update_info
  end
  
  def update_contacts_courses(cids)
    contact = self.contact
    
    cids.each do |row|
      if row[1]["course_id"].present?
        cc = self.contacts_courses.new
        cc.course_id = row[1]["course_id"]
        cc.contact_id = contact.id
        
        if row[1]["price"] == "no_price"
          cc.price = -1
        else
          cc.courses_phrase_ids = "["+row[1]["courses_phrase_ids"].join("][")+"]" if !row[1]["courses_phrase_ids"].nil?
          #cc.upfront = row[1]["upfront"]
          cc.price = row[1]["price"]        
          cc.discount = row[1]["discount"]
          
          # Discount programs
          dps = []
          row[1]["discount_programs"].each do |r|
            dps << {id: r[1]["id"], discount_program_type: r[1]["discount_program_type"]} if r[1]["id"].present?
          end
          cc.discount_programs = dps.to_json
          
          # Other Discounts
          dps = []
          row[1]["other_discounts"].each do |r|
            dps << {amount: r[1]["amount"].to_s.gsub(/\,/, ''), description: r[1]["description"]} if r[1]["amount"].present?
          end
          cc.other_discounts = dps.to_json
          
          #budget
          cc.hour = row[1]["hour"]
          cc.money = row[1]["money"]
          cc.additional_money = row[1]["additional_money"]
        end
      end
    end

  end
  
  def update_books_contacts(cids)
    contact = self.contact    
    cids.each do |row|
      if row[1]["book_id"].present? && row[1]["selected"].present?
        cc = self.books_contacts.new
        cc.book_id = row[1]["book_id"]
        cc.quantity = row[1]["quantity"]
        cc.contact_id = contact.id
        
        if row[1]["price"] == "no_price"
          cc.price = -1
        else
          cc.price = row[1]["price"]
          cc.discount_program_id = row[1]["discount_program_id"]
          cc.discount = row[1]["discount"]
        end
      end
    end
  end
  
  def self.filter(params, user)
    @records = self.main_course_registers
    
    if params["course_types"].present?
      cc_ids = ContactsCourse.includes(:course).where(courses: {course_type_id: params["course_types"]}).map(&:id)
      bc_ids = BooksContact.includes(:book).where(books: {course_type_id: params["course_types"]}).map(&:id)
      
      cond = []
      cond << "contacts_courses.id IN (#{cc_ids.join(",")})" if !cc_ids.empty?
      cond << "books_contacts.id IN (#{bc_ids.join(",")})" if !bc_ids.empty?
      @records = @records.joins(:books_contacts, :contacts_courses)
                          .where(cond.join(" OR ")) if !cond.empty?
    end
    
    if params["subjects"].present?
      course_ids = Course.where(subject_id: params["subjects"]).map(&:id)
      book_ids = Book.where(subject_id: params["subjects"]).map(&:id)
      cond = []
      cond << "courses.id IN (#{course_ids.join(",")})" if !course_ids.empty?
      cond << "books.id IN (#{book_ids.join(",")})" if !book_ids.empty?
      @records = @records.joins(:contacts_courses => :course, :books_contacts => :book)
                          .where(cond.join(" OR ")) if !cond.empty?
    end
    
    if params["student"].present?
      @records = @records.where(:contact_id => params["student"])
    end
    
    if params[:courses].present?
      @records = @records.joins(:contacts_courses => :course)
                          .where(courses: {id: params[:courses].split(",")})
    end
    
    if params["delivery_statuses"].present?
      @records = @records.where(cache_delivery_status: params["delivery_statuses"])
    end
    
    if params["payment_statuses"].present?
      @records = @records.where("course_registers.cache_payment_status LIKE ?", "%"+params["payment_statuses"]+"%")
    end
    
    if params["company"].present?
      @records = @records.where(payment_type: "company-sponsored").where(sponsored_company_id: params["company"])
    end
    
    course_ids = nil
    if params["upfront"].present?
      u_course_ids = Course.where(upfront: params["upfront"]).map(&:id)
    end
    
    if params["upfront"] == "true"
      course_ids = u_course_ids
    else
      if params["intake_year"].present? && params["intake_month"].present?
        course_ids = Course.where("EXTRACT(YEAR FROM courses.intake) = ? AND EXTRACT(MONTH FROM courses.intake) = ? ", params["intake_year"], params["intake_month"]).map(&:id)
      elsif params["intake_year"].present?
        course_ids = Course.where("EXTRACT(YEAR FROM courses.intake) = ? ", params["intake_year"]).map(&:id)
      elsif params["intake_month"].present?
        course_ids = Course.where("EXTRACT(MONTH FROM courses.intake) = ? ", params["intake_month"]).map(&:id)
      end
      if params["upfront"] == "false"
        course_ids = Course.where(upfront: false).map(&:id) if course_ids.nil?
      end
    end
    @records = @records.joins(:contacts_courses => :course).where(courses: {id: course_ids}) if !course_ids.nil?

    
    ########## BEGIN REVISION-FEATURE #########################
    
    if params[:status].present?
      if params[:status] == "pending"
        @records = @records.where("course_registers.status LIKE ?","%_pending]%")
      elsif params[:status] == "approved" # for approved
        @records = @records.where("course_registers.annoucing_user_ids LIKE ?", "%[#{user.id}%]")
      else
        @records = @records.where("course_registers.status LIKE ?","%[#{params[:status]}]%")
      end
    end
    
    if !params[:status].present? || params[:status] != "deleted"
      @records = @records.where("course_registers.status NOT LIKE ?","%[deleted]%")
    end
   
    ########## END REVISION-FEATURE #########################
    
    return @records
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    
    @records = self.filter(params, user)
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "6"
        order = "course_registers.created_at"
      else
        order = "course_registers.created_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "course_registers.created_at DESC, course_registers.created_at DESC"
    end
    @records = @records.order(order) if !order.nil? && !params["search"]["value"].present?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 9
    @records.each do |item|
      ############### BEGIN REVISION #########################
      # update approved status
      if params[:status].present? && params[:status] == "approved"
        item.remove_annoucing_users([user])
      end
      ############### END REVISION #########################
      item = [
              "<div class=\"checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
              item.contact.contact_link,
              item.description,
              '<div class="text-center">'+item.display_delivery_status+"</div>",
              '<div class="text-right"><label class="col_label top0">Total:</label>'+ApplicationController.helpers.format_price(item.total)+"<label class=\"col_label top0\">Paid:</label>"+ApplicationController.helpers.format_price(item.paid_amount)+"<label class=\"col_label top0\">Receivable:</label>"+ApplicationController.helpers.format_price(item.remain_amount)+"</div>",
              '<div class="text-center">'+item.display_payment_status+item.display_payment+"</div>",
              '<div class="text-center">'+item.created_at.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-center">'+item.contact.account_manager.staff_col+"</div>",
              '<div class="text-center">'+item.display_statuses+"</div>",
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
  
  def self.payment_list(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    
    @records = self.filter(params, user)
    @records = @records.where("course_registers.status IS NOT NULL AND course_registers.status LIKE ?", "%[active]%")
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when false
      else
        order = "course_registers.created_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "course_registers.created_at DESC"
    end
    @records = @records.order(order) if !order.nil? && !params["search"]["value"].present?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 8
    @records.each do |item|
      ############### BEGIN REVISION #########################
      # update approved status
      if params[:status].present? && params[:status] == "approved"
        item.remove_annoucing_users([user])
      end
      ############### END REVISION #########################
      item = [
              "<div class=\"checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
              item.contact.contact_link,
              item.description,
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.total)+"</div>",
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.paid_amount)+"</div>",
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.remain_amount)+"</div>",
              '<div class="text-center">'+item.display_payment_status+item.display_payment+"</div>",
              '<div class="text-center">'+item.contact.account_manager.staff_col+"</div>",
              ""
              #"<div class=\"checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
              #item.contact.contact_link,
              #item.description,
              #'<div class="text-center">'+item.display_delivery_status+"</div>",
              #'<div class="text-right"><label class="col_label top0">Total:</label>'+ApplicationController.helpers.format_price(item.total)+"<label class=\"col_label top0\">Paid:</label>"+ApplicationController.helpers.format_price(item.paid_amount)+"<label class=\"col_label top0\">Receivable:</label>"+ApplicationController.helpers.format_price(item.remain_amount)+"</div>",
              #'<div class="text-center">'+item.display_payment_status+item.display_payment+"</div>",
              #'<div class="text-center">'+item.created_at.strftime("%d-%b-%Y")+"</div>",
              #'<div class="text-center">'+item.contact.account_manager.staff_col+"</div>",
              #'<div class="text-center">'+item.display_statuses+"</div>",
              #""
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
  
  def paid_on
    self.all_payment_records.empty? ? "" : self.all_payment_records.last.payment_date.strftime("%d-%b-%Y")
  end
  def bank_account_name
    self.all_payment_records.empty? ? "" : self.all_payment_records.last.bank_account.name
  end
  def description
    str = []
    str << "<h5 class=\"list_title\">Courses: </h5>#{course_list}" if !contacts_courses.empty?
    str << "<h5 class=\"list_title\">Stocks: </h5>#{book_list}" if !books_contacts.empty?
    
    return str.join("<br />")
  end
  
  def self.student_course_registers(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @student = Contact.find(params[:student])
    
    @records =  self.filter(params, user)
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    
    @records = @records.where(contact_id: @student.id)
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "5"
        order = "course_registers.created_at"
      else
        order = "course_registers.created_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "course_registers.created_at DESC, course_registers.created_at DESC"
    end
    @records = @records.order(order) if !order.nil? && !params["search"]["value"].present?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 8
    @records.each do |item|
      item = [
              item.contact.contact_link,
              item.description,
              '<div class="text-center">'+item.display_delivery_status+"</div>",
              '<div class="text-right"><label class="col_label top0">Total:</label>'+ApplicationController.helpers.format_price(item.total)+"<label class=\"col_label top0\">Paid:</label>"+ApplicationController.helpers.format_price(item.paid_amount)+"<label class=\"col_label top0\">Remain:</label>"+ApplicationController.helpers.format_price(item.remain_amount)+"</div>",
              '<div class="text-center">'+item.display_payment_status+item.display_payment+"</div>",
              '<div class="text-center">'+item.created_at.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-center">'+item.contact.account_manager.staff_col+"</div>",
              '<div class="text-center">'+item.display_statuses+"</div>",
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
  
  def course_list(phrase_list=true)
    arr = []
    courses.each do |row|
      
      
      arr << "<div class=\"nowrap\"><strong>"+row[:course].display_name+"</strong></div>"
      arr << "<div class=\"courses_phrases_list\">"+Course.render_courses_phrase_list(row[:courses_phrases],row[:contacts_course])+"</div>" if phrase_list
      #arr << "<div>#{no_ucrs_html}</div>"
      
    end
    
    return arr.join("")
  end
  
  def courses
    arr = []
    contacts_courses.each do |cc|
      item = {}
      item[:course] = cc.course
      item[:courses_phrases] = cc.courses_phrases
      item[:contacts_course] = cc
      arr << item
    end
    
    return arr
  end
  
  def book_list
    arr = []
    books.each do |row|
      arr << "<div><strong>#{row[:books_contact].quantity} - "+row[:book].display_name+" <br /><span>"+row[:books_contact].display_upfront+"</span></strong></div><br />"
      #arr << row[:volumns].map(&:name).join(", ")
    end
    
    return arr.join("")
  end
  
  def books
    arr = []
    books_contacts.each do |bc|
      item = {}
      item[:books_contact] = bc
      item[:book] = bc.book
      #item[:volumns] = bc.volumns
      arr << item
    end    
    return arr
  end
  
  def course_total
    course = 0.00
    contacts_courses.each do |cc|
      course += cc.total
    end
    return course
  end
  
  def stock_total
    stock = 0.00
    books_contacts.each do |bc|
      stock += bc.total
    end
    
    return stock
  end
  
  def price
    return course_total + stock_total
  end
  
  def total
    price - transfer.to_f
  end
  
  def discount_program_amount_old
    return 0.00 if discount_program.nil?
    
    return discount_program.type_name == "percent" ? (discount_program.rate/100)*price : discount_program.rate
  end
  
  def payment
    str = ""
    if payment_type == "self-financed"
      str += "self-financed"
    else
      str += "company-sponsored"
    end
    
    # str += "<div>#{bank_account.name}</div>"
    
    return str
  end
  
  def discount=(new)
    self[:discount] = new.to_s.gsub(/\,/, '')
  end  
  def transfer=(new)
    self[:transfer] = new.to_s.gsub(/\,/, '')
  end
  
  
  def stock_count
    books_contacts.count
  end
  
  def display_delivery_status    
    return "" if books.count == 0
    
    if delivered?
      return "<a class=\"check-radio ajax-check-radioz\" href=\"#c\"><i class=\"#{delivered?.to_s} icon-check#{delivered? ? "" : "-empty"}\"></i></a>"
    else
      return "<div class=\"nowrap check-radio\">"+ActionController::Base.helpers.link_to("<i class=\"#{delivered?.to_s} icon-check#{delivered? ? "" : "-empty"}\"></i>".html_safe, {controller: "deliveries", action: "new", course_register_id: self.id, tab_page: 1}, title: "Deliver Stock: #{self.contact.display_name}", title: 'Materials Delivery', class: "tab_page")+"</div>"
    end

  end
  
  def delivery_info
    #if delivered?
    #  return "On"+delivery.delivery_date.strftime("%d-%b-%Y")+""
    #end    
  end
  
  def delivered?
    self.books_contacts.each do |bc|
      if !bc.delivered?
        return false
      end      
    end
    return true
  end
  
  def self.all_waiting_deliveries
    self.includes(:deliveries, :books_contacts).where(deliveries: {id: nil}).where.not(books_contacts: {id: nil})
  end
  
  def paid_amount(date=nil)
    return total if self.company_payment_records(date).count > 0
    
    records = all_payment_records
    if date.present?
      records = records.where("payment_date <= ?", date)
    end
    
    total = 0.00
    records.each do |p|
      total += p.total
    end
    return total #records.sum(:amount)
  end
  
  def no_price?
    # check if course no price
    contacts_courses.each do |cc|
      if cc.no_price?
        return true
      end      
    end
    
    # check if stock no price
    books_contacts.each do |bc|
      if bc.no_price?
        return true
      end      
    end
    
    return false
  end
  
  def paid?(date=nil)
    return false if no_price? && paid_amount(date).to_f == 0
    paid_amount(date) == total
  end
  
  def remain_amount(date=nil)
    total - paid_amount(date)
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
  
  def debt?
    return false if paid?
    
    return real_debt_date.nil? ? false : real_debt_date >= Time.now
  end
  
  def out_of_date?
    return false if paid?
    
    return real_debt_date.nil? ? false : real_debt_date < Time.now
  end
  
  def real_debt_date
    if !last_payment.nil?
      self.last_payment.debt_date
    else
      self.debt_date
    end
  end
  
  def last_payment
    all_payment_records.order("payment_date DESC, created_at DESC").first
  end
  
  def course_register_link
    ActionController::Base.helpers.link_to("<i class=\"icon icon-list-alt\"></i> Course Register [#{created_at.strftime("%d-%b-%Y")}]".html_safe, {controller: "course_registers", action: "show", id: self.id, tab_page: 1}, title: "Course Register Detail: #{self.contact.display_name} [#{created_at.strftime("%d-%b-%Y")}]", class: "tab_page")
  end
  
  def self.update_all_statuses
    self.all.each do |c|
      c.update_statuses
      c.save
    end
  end
  
  def update_statuses
    # delivery
    self.update_attribute(:cache_delivery_status, self.delivery_status)
    
    # payment
    self.update_attribute(:cache_payment_status, self.payment_status.join(","))
  end
  
  def delivery_status
    return "" if self.books.count == 0
    delivered? ? "delivered" : "not_delivered"
  end
  
  ############### BEGIN REVISION #########################
  
  def check_exist
    return false
  
    #return false if draft?
    #
    #exist = CourseRegister.main_course_registers.where("short_name = ? OR name = ?",
    #                      self.short_name, self.name
    #                    )
    #
    #if self.id.nil? && exist.length > 0
    #  errors.add(:base, "Course type exists")
    #end
    
  end
  
  def self.main_course_registers
    self.where(parent_id: nil)
  end
  def self.active_course_registers
    self.main_course_registers.where("status IS NOT NULL AND status LIKE ?", "%[active]%")
  end
  
  def draft?
    !parent.nil?
  end
  
  def update_status(action, user, older = nil)
    # when create new contact
    if action == "create"      
      # check if the contact is student
      self.add_status("new_pending")
    end
    
    # when update exist contact
    if action == "update"
      # just update when exist active
      self.add_status("update_pending") if !self.has_status("new_pending")
    end
    
    self.check_statuses
  end  
  
  def statuses
    status.to_s.split("][").map {|s| s.gsub("[","").gsub("]","")}
  end
  
  def display_statuses
    return "" if statuses.empty?
    result = statuses.map {|s| "<span title=\"Last updated: #{current.created_at.strftime("%d-%b-%Y, %I:%M %p")}; By: #{current.user.name}\" class=\"badge user-role badge-info contact-status #{s}\">#{s}</span>"}
    result.join(" ").html_safe
  end
  
  
  def approve_new(user)
    if statuses.include?("new_pending")          
      self.delete_status("new_pending")      
      self.check_statuses
      
      # Annoucing users
      add_annoucing_users([self.current.user])
      
      self.save_draft(user)
    end
  end
  
  def approve_update(user)
    if statuses.include?("update_pending")
      self.delete_status("update_pending")
      self.check_statuses
      
      # Annoucing users
      add_annoucing_users([self.current.user])
      
      self.save_draft(user) 
    end
  end
  
  def approve_delete(user)
    if statuses.include?("delete_pending")
      self.set_statuses(["deleted"])
      self.check_statuses
      
      # Annoucing users
      add_annoucing_users([self.current.user])
      
      self.save_draft(user)
    end
  end
  
  def check_statuses
    if !statuses.include?("deleted") && !statuses.include?("delete_pending") && !statuses.include?("update_pending") && !statuses.include?("new_pending")
      add_status("active")
      
      self.contact.update_info
    else
      delete_status("active")
    end    
  end
  
  def set_statuses(arr)
    self.update_attribute(:status, "["+arr.join("][")+"]")    
  end
  
  def add_status(st)
    sts = self.statuses
    if !sts.include?(st)
      sts << st
      self.set_statuses(sts)
    end
  end
  
  def delete_status(st)
    sts = self.statuses
    sts.delete(st)
    
    self.set_statuses(sts)
  end
  
  def has_status(st)
    self.statuses.include?(st)
  end
  
  def save_draft(user)
    draft = self.dup
    draft.parent_id = self.id
    draft.user_id = user.id
    
    self.contacts_courses.each do |cc|
      draft.contacts_courses << cc.dup
    end
    
    self.books_contacts.each do |bc|
      draft.books_contacts << bc.dup
    end
    
    draft.save
    
    return draft
  end
  
  def current
    return self if drafts.empty?
    return drafts.order("created_at DESC").first
  end
  
  def revisions
    drafts.where("status LIKE ?", "%[active]%")
  end
  
  def first_revision
    revisions.order("created_at").first
  end
  
  def older
    if !draft?
      return drafts.order("created_at DESC").second
    else
      return parent.drafts.where("created_at < ?", self.created_at).order("created_at DESC").first
    end
  end
  
  def active_older
    if !draft?
      olders = drafts.order("created_at DESC").where("status LIKE ?", "%[active]%")
      return statuses.include?("active") ? olders.second : olders.first
    else
      return parent.drafts.where("created_at < ?", self.created_at).where("status LIKE ?", "%[active]%").order("created_at DESC").first
    end
  end
  
  def field_history(type,value=nil)
    return [] if !self.current.nil? && self.current.statuses.include?("active")
    
    if self.draft?
      drafts = self.parent.drafts #.where("contacts.status LIKE ?","%[active]%")
      drafts = drafts.where("created_at > ?", self.created_at)
    else
      drafts = self.drafts      
      drafts = drafts.where("created_at < ?", self.current.created_at) if self.current.present?    
      drafts = drafts.where("created_at >= ?", self.active_older.created_at) if !self.active_older.nil?    
      drafts = drafts.order("created_at DESC")
    end
    
    if false
    else
      value = value.nil? ? self[type] : value
      drafts = drafts.where("#{type} IS NOT NUll AND #{type} != ?", value)
    end
    
    return drafts
  end
  
  def self.status_options
    [
      ["All",""],
      ["Pending...","pending"],
      ["New Approved...","approved"],
      ["Active","active"],
      ["New Pending","new_pending"],
      ["Update Pending","update_pending"],
      ["Delete Pending","delete_pending"],
      ["Deleted","deleted"]
    ]
  end
  
  def delete    
    self.set_statuses(["delete_pending"])
    return true
  end
  
  def rollback(user)
    #older = self.active_older
    #
    #self.update_attributes(older.attributes.select {|k,v| !["draft_for","id", "created_at", "updated_at"].include?(k) })
    #
    #self.contact_types = older.contact_types
    #self.course_types = older.course_types
    #self.lecturer_course_types = older.lecturer_course_types
    #
    #self.save
    #
    #self.save_draft(user)
  end
  
  def add_annoucing_users(users)
    us = self.annoucing_users
    users.each do |user|
      us << user.id if !us.include?(user.id)
    end    
    self.update_attribute(:annoucing_user_ids, "["+us.join("][")+"]")
  end
  
  def remove_annoucing_users(users)
    us = self.annoucing_users
    users.each do |user|
      us.delete(user.id) if us.include?(user.id)
    end    
    self.update_attribute(:annoucing_user_ids, "["+us.join("][")+"]")
  end
  
  def annoucing_users
    return [] if annoucing_user_ids.nil?
    ids = self.annoucing_user_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
    return User.where(id: ids)
  end
  
  ############### END REVISION #########################
  
  def display_payment
    if payment == "company-sponsored"
      "company-sponsored<br /><i class=\"icon-building\"></i> #{sponsored_company.contact_link}".html_safe
    else
      payment
    end
    
  end
  
  def display_mailing_address
    return contact.default_mailing_address if preferred_mailing.nil?
    
    if preferred_mailing == "home"
      return contact.address
    elsif preferred_mailing == "company"
      return contact.referrer.address
    elsif preferred_mailing == "ftms"
      return "FTMS"
    else
      return contact.mailing_address
    end    
  end
  
  def display_mailing_title
    return contact.default_mailing_title if preferred_mailing.nil?
    
    if preferred_mailing == "home"
      return "Home Address"
    elsif preferred_mailing == "company"
      return "Company Address"
    elsif preferred_mailing == "ftms"
      return "FTMS Address"
    else
      return "Address"
    end    
  end
  
  def company_payment_records(date=nil)
    records = PaymentRecord.where("course_register_ids LIKE ?", "%#{self.id}%")
    if date.present?
      records = records.where("payment_date <= ?", date)
    end
    return records
  end
  
  def update_cache_search
    return false if !self.parent_id.nil?
    
    str = []
    str << contact.display_name
    str << contact.display_name.unaccent
    str << description
    str << display_delivery_status
    str << total.to_s
    str << paid_amount.to_s
    str << remain_amount.to_s
    str << display_payment_status+display_payment
    str << self.created_at.strftime("%d-%b-%Y")
    str << contact.account_manager.name
    str << display_statuses
    
    self.update_attribute(:cache_search, str.join(" "))
  end
  
end
