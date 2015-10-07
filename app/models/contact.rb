class Contact < ActiveRecord::Base
  mount_uploader :image, LogoUploader
  
  include PgSearch
  
  #validates :address, presence: true
  #validates :email, presence: true
  validates :name, presence: true
  #validates :mobile, presence: true, if: :is_individual?
  #validates :birthday, presence: true, if: :is_individual?
  #validates :sex, presence: true, if: :is_individual?
  #validates :account_manager_id, presence: true, if: :is_individual?
  
  validate :not_exist
  
  has_many :parent_contacts, :dependent => :destroy
  has_many :parent, :through => :parent_contacts, :source => :parent
  has_many :child_contacts, :class_name => "ParentContact", :foreign_key => "parent_id", :dependent => :destroy
  has_many :children, :through => :child_contacts, :source => :contact
  
  has_many :agents_contacts, :dependent => :destroy
  has_many :agents, :through => :agents_contacts, :source => :agent, :dependent => :destroy
  has_many :companies_contacts, :class_name => "AgentsContact", :foreign_key => "agent_id", :dependent => :destroy
  has_many :companies, :through => :companies_contacts, :source => :contact
  
  has_many :contact_types_contacts
  
  belongs_to :contact_type
  belongs_to :user
  
  belongs_to :referrer, :class_name => "Contact", :foreign_key => "referrer_id"
  has_many :contacts, :class_name => "Contact", :foreign_key => "referrer_id"
  
  belongs_to :invoice_info, :class_name => "Contact", :foreign_key => "invoice_info_id"

  belongs_to :city
  has_one :state, :through => :city
  
  has_and_belongs_to_many :contact_types
  
  has_and_belongs_to_many :contact_tags
  has_many :contact_tags_contacts, :dependent => :destroy
  
  belongs_to :tag, :class_name => "ContactTagsContact", :foreign_key => "tag_id"
  
  has_many :contacts_courses
  has_and_belongs_to_many :courses
  
  has_many :books_contacts
  has_and_belongs_to_many :books
  
  has_many :contacts_seminars, :dependent => :destroy
  has_and_belongs_to_many :seminars
  
  belongs_to :account_manager, :class_name => "User"
  belongs_to :creator, :class_name => "User"
  
  has_and_belongs_to_many :course_types
  
  has_many :contacts_lecturer_course_types
  has_many :lecturer_course_types, :through => :contacts_lecturer_course_types, :source => :course_type
  
  has_many :course_registers, :dependent => :destroy
  
  has_many :drafts, :class_name => "Contact", :foreign_key => "draft_for", :dependent => :destroy
  belongs_to :draft_for_contact, :class_name => "Contact", :foreign_key => "draft_for"
  
  has_one :current_revision, -> { order created_at: :desc }, class_name: 'Contact', foreign_key: "draft_for"
  
  has_many :transfers
  has_many :received_transfers, class_name: "Transfer", foreign_key: "to_contact_id"
  
  has_many :transferred_records, :class_name => "Transfer", :foreign_key => "transfer_for"
  
  has_many :payment_records
  
  has_many :activities, :dependent => :destroy
  
  after_validation :update_cache
  before_validation :check_type
  
  def active_books
    books.includes(:books_contacts).joins("LEFT JOIN course_registers ON course_registers.id = books_contacts.course_register_id")
          .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status LIKE ?", "%[active]%")
          .uniq
  end
  
  def active_courses
    courses.includes(:contacts_courses).joins("LEFT JOIN course_registers ON course_registers.id = contacts_courses.course_register_id")
          .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status LIKE ?", "%[active]%")
          .uniq
  end
  
  def active_contacts_courses
    contacts_courses.joins("LEFT JOIN course_registers ON course_registers.id = contacts_courses.course_register_id")
                    .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status LIKE ?", "%[active]%")
                    .uniq
  end
  
  def active_course_registers
    course_registers.where("course_registers.parent_id IS NULL AND course_registers.status IS NOT NULL AND course_registers.status LIKE ?", "%[active]%")
  end
  
  def self.format_mobile(string)
    result = string.gsub(/\D/, '')
    if (result =~ /84/i) != 0
      if result[0] == "0"
        result[0] = ""        
      end
      result = "84"+result      
    end
    
    return result
  end
  
  def display_mobile
    "+"+mobile
  end
  
  def self.update_all_info
    self.all.each do |c|
      c.update_info
    end
  end
  
  def update_info
    self.check_type
    self.save
    
    self.update_cache_course_type_ids
    self.update_cache_intakes
    self.update_cache_subjects
    self.update_cache_courses
    self.update_cache_search
  end
  
  def check_type
    self.course_types = [] if !contact_types.include?(ContactType.inquiry)
    self.lecturer_course_types = [] if !contact_types.include?(ContactType.lecturer)
    # self.contact_types.delete(ContactType.student) if joined_course_types.empty?
    if !joined_course_types.empty?
      self.contact_types << ContactType.student if !self.contact_types.include?(ContactType.student)
      self.course_types = self.course_types - joined_course_types
      self.contact_types.delete(ContactType.inquiry) if self.course_types.empty?
    end
  end
  
  def is_not_individual?
    !is_individual
  end
  def is_individual?
    is_individual
  end
  
  def first_name=(str)
    self[:first_name] = str.to_s.strip
  end
  def last_name=(str)
    self[:last_name] = str.to_s.strip
  end
  def name=(str)
    self[:name] = str.strip
  end
  def email=(str)
    self[:email] = str.strip
  end
  #def email_2=(str)
  #  self[:email_2] = str.strip
  #end
  def mobile=(value)
    self[:mobile] = Contact.format_mobile(value)
  end
  #def mobile_2=(value)
  #  self[:mobile_2] = Contact.format_mobile(value)
  #end
  def not_exist
    return true if self.draft?
    
    if !exist_contacts.empty?
      cs = exist_contacts.map {|c| c.contact_link}
      errors.add(:base, "There are/is contact(s) with the same information: #{cs.join(";")}".html_safe)
    end
  end
  
  
  
  def exist_contacts
    exist = []    
    if is_individual
      exist += Contact.where("(LOWER(name) = ? AND LOWER(email) = ?) OR (LOWER(name) = ? AND LOWER(mobile) = ?)", name.downcase, email.downcase, name.downcase, mobile.downcase) if mobile.present? && name.present? && email.present?
    else
      exist += Contact.where("LOWER(name) = ?", name.downcase) if name.present?
    end
    
    cs = []
    if exist.length > 0 && !self.id.present?      
      exist.each do |c|
        cs << c
      end      
    end
    
    return cs
  end
  
  def self.filters(params, user)
    @records = self.main_contacts
    
    @records = @records.where_by_types(params[:contact_types]) if params[:contact_types].present?
    @records = @records.where("contacts.is_individual = #{params[:is_individual]}") if params[:is_individual].present?
    @records = @records.where("contacts.referrer_id IN (#{params[:companies]})") if params[:companies].present?
    
    if params[:courses].present?
      @records = @records.where("contacts.cache_courses LIKE ?", "%[#{params[:courses]}]%")
    end
    
    if params[:courses_phrases].present?
       @records = @records.joins(:contacts_courses)
      @records = @records.where("contacts_courses.courses_phrase_ids LIKE ?","%[#{params[:courses_phrases]}]%")
    end
    
    if params[:seminars].present?
      @seminar = Seminar.find(params[:seminars])
      c_ids = @seminar.contacts.map(&:id)
      @records = @records.where(id: c_ids)
    end
    
    if params[:tags].present?
      cond = []
      params[:tags].each do |t|
        cond << "contacts.cache_search LIKE '%[tag:#{ContactTag.find(t).name}]%'"
      end
      @records = @records.where(cond.join(" OR "))
    end
    
    if params["course_types"].present?
      conds = []
      params["course_types"].each do |ccid|
        conds << "contacts.cache_course_type_ids LIKE '%[#{ccid}]%'"
      end
      
      @records = @records.joins("LEFT JOIN contacts_course_types ON contacts_course_types.contact_id = contacts.id")
      #@records = @records.joins("LEFT JOIN contacts_lecturer_course_types ON contacts_lecturer_course_types.contact_id = contacts.id")
      conds << "contacts_course_types.course_type_id IN (#{params["course_types"].join(", ")})"
      #conds << "contacts_lecturer_course_types.course_type_id IN (#{params["course_types"].join(", ")})"
      
      @records = @records.where(conds.join(" OR "))
    end
    
    if params["intake_year"].present? && params["intake_month"].present?
      @records = @records.where("contacts.cache_intakes LIKE '%{:year=>#{params["intake_year"]}, :month=>#{params["intake_month"]}}%'")
    elsif params["intake_year"].present?
      @records = @records.where("contacts.cache_intakes LIKE '%{:year=>#{params["intake_year"]}%'")
    elsif params["intake_month"].present?
      @records = @records.where("contacts.cache_intakes LIKE '%:month=>#{params["intake_month"]}}%'")
    end
    
    if params["subjects"].present?
      conds = []
      params["subjects"].each do |sid|
        conds << "contacts.cache_subjects LIKE '%[#{sid}]%'"
      end
      @records = @records.where(conds.join(" OR "))
    end
    
    if params[:status].present?
      if params[:status] == "pending"
        @records = @records.where("contacts.status LIKE ?","%_pending]%")
      elsif params[:status] == "approved"
        @records = @records.where("contacts.annoucing_user_ids LIKE ?", "%[#{user.id}%]")
      else
        @records = @records.where("contacts.status LIKE ?","%[#{params[:status]}]%")
      end
    end
    
    if params["created_from"].present?      
      @records = @records.where("created_at >= ?", params["created_from"].to_date.beginning_of_day)
    end
    if params["created_to"].present?      
      @records = @records.where("created_at <= ?", params["created_to"].to_date.end_of_day)
    end
    if params["payment_type"].present?      
      @records = @records.where(payment_type: params["payment_type"])
    end
    if params["company"].present?      
      @records = @records.where(referrer_id: params["company"])
    end
    if params["user"].present?      
      @records = @records.where(account_manager_id: params["user"])
    end
    
    if !params[:status].present? || params[:status] != "deleted"
      @records = @records.where("contacts.status NOT LIKE ?","%[deleted]%")
    end
    
    # Areas filter
    cities_ids = []
    if params[:area_ids].present?
      params[:area_ids].split(",").each do |area|
        area_type = area.split("_")[0]
        area_id = area.split("_")[1]
        if area_type == "c"
          cities_ids << area_id
        elsif area_type == "s"
          cities_ids << State.find(area_id.to_i).cities.map{|c| c.id}          
        end
      end
      @records = @records.where(city_id: cities_ids)
    end
    
    @records = @records.search(params["search"]["value"]) if params["search"].present? && !params["search"]["value"].empty?
    
    return @records
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    @records = self.filters(params, user)
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "contacts.name"
      when "6"
        order = "contacts.created_at"
      when "8"
        @records = @records.includes(:current_revision)
        order = "current_revisions_contacts.created_at"
      else
        order = "contacts.name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "contacts.name"
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
              
              '<div class="text-left"><strong>'+item.contact_link+"</strong></div>"+'<div class="text-left">'+item.html_info_line.html_safe+item.referrer_link+"</div>"+item.picture_link,              
              '<div class="text-right">'+item.contact_type_name+"</div>",
              '<div class="text-left">'+item.course_types_name_col+"</div>",
              '<div class="text-center">'+item.course_count_link+"</div>",
              '<div class="text-center contact_tag_box" rel="'+item.id.to_s+'">'+ContactsController.helpers.render_contact_tags_selecter(item)+"</div>",
              '<div class="text-center">'+item.created_at.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-center">'+item.account_manager_col+"</div>",
              '<div class="text-center">'+item.display_statuses+"</div>",
              '',
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
  
  def account_manager_col
    if is_individual
      result = !account_manager.nil? ? account_manager.staff_col : ""
    else
      arr = []
      contacts.each do |c|
        arr << c.account_manager if !c.account_manager.nil? && !arr.include?(c.account_manager)
      end
      
      result = (arr.map {|u| u.staff_col}).join("<br /><br />")
    end
    return result    
  end
  
  def self.course_students(params, user)
    @course = Course.find(params[:courses])
    
    @records = self.filters(params, user)
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "2"
        order = "contacts.name"
      else
        order = "contacts.name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "contacts.name"
    end
    @records = @records.order(order) if !order.nil? && !params["search"]["value"].present?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 8
    @records.each do |item|
      item = [
              "<div class=\"checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
              item.picture_link,
              '<div class="text-left">'+item.contact_link+"</div>",
              '<div class="text-left">'+item.html_info_line.html_safe+item.referrer_link+"</div>",               
              '<div class="text-center">'+item.joined_course_types_name+"</div>",
              '<div class="text-center">'+item.course_count_link+"</div>",
              #'<div class="text-left">'+item.referrer_link+"</div>",
              '<div class="text-center contact_tag_box" rel="'+item.id.to_s+'">'+ContactsController.helpers.render_contact_tags_selecter(item)+"</div>",
              '<div class="text-center">'+item.active_course(@course.id)[:created_at].strftime("%d-%b-%Y")+"</div>",
              '',
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
  
  def self.seminar_students(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    @seminar = Seminar.find(params[:seminars])
    
    @records = self.filters(params, user)
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "2"
        order = "contacts.name"
      else
        order = "contacts.name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "contacts.name"
    end
    @records = @records.order(order) if !order.nil? && !params["search"]["value"].present?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 8
    @records.each do |item|
      item = [
              "<div class=\"checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
              item.picture_link,
              '<div class="text-left">'+item.contact_link+"</div>",
              '<div class="text-left">'+item.html_info_line.html_safe+item.referrer_link+"</div>",               
              '<div class="text-center">'+item.joined_course_types_name+"</div>",
              '<div class="text-center">'+item.course_count_link+"</div>",
              #'<div class="text-left">'+item.referrer_link+"</div>",
              '<div class="text-center contact_tag_box" rel="'+item.id.to_s+'">'+ContactsController.helpers.render_contact_tags_selecter(item)+"</div>",
              '<div class="text-center">'+item.display_present_with_seminar(@seminar)+"</div>",
              "<div class=\"text-right\"><div rel=\"#{@seminar.id}\" contact_ids=\"#{item.id}\" class=\"remove_contact_from_seminar_but btn btn-mini btn-danger\">Remove</div></div>",
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
  
  def display_present_with_seminar(seminar, link=true)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    url = link ? link_helper.url_for({controller: "seminars", action: "check_contact", value: !present_with_seminar?(seminar), id: seminar.id, contact_id: self.id}) : "#none"
    
    ApplicationController.helpers.check_ajax_button(present_with_seminar?(seminar), url)    
  end
  
  def present_with_seminar?(seminar)
    cs = contacts_seminar(seminar)
    cs.nil? ? false : cs.present?
  end
  
  def contacts_seminar(seminar)
    contacts_seminars.where(seminar_id: seminar.id).first
  end
  
  def course_register(course)
    CourseRegister.find(contacts_courses.where(course_id: course.id).first.course_register_id)
  end
  
  def joined_course_types
    # active_contacts_courses.map {|cc| cc.course.course_type}.uniq
    cts = []
    active_courses_with_phrases.each do |row|
      cts << row[:course].course_type
    end
    
    return cts.uniq
  end
  
  def intakes
    # active_contacts_courses.map {|cc| {year: cc.course.intake.year, month: cc.course.intake.month}}.uniq
    result = []
    active_courses_with_phrases.each do |row|
      result << {year: row[:course].intake.year, month: row[:course].intake.month}
    end
    return result.uniq
  end
  
  def update_cache_intakes
    self.update_attribute(:cache_intakes, intakes.to_s)
  end
  
  def subjects
    # contacts_courses.map {|cc| cc.course.subject}.uniq
    sus = []
    active_courses_with_phrases.each do |row|
      sus << row[:course].subject
    end    
    return sus.uniq
  end
  
  def update_cache_subjects
    cache = "["+subjects.map(&:id).join("][")+"]"
    self.update_attribute(:cache_subjects, cache)
  end
  
  def joined_course_types_name
    joined_course_types.map(&:short_name).join(", ")
  end
  
  def contact_type_name
    if is_individual
      result = ""
      if !contact_types.empty?
        result += "<div class=\"contact_type_line\">"+contact_types.order(:display_order).map(&:name).join("</div><div class=\"contact_type_line\">")+"</div>"
      else
        result += "none"
      end
      
      #if !course_types.empty?
      #  result += "<div class=\"text-center\"><label class=\"col_label text-center\">Inquiry:</label>"
      #  result += course_types.map(&:short_name).join(", ")
      #  result += "</div>"
      #end
      
      return result
    else
      "Company/Organization"
    end    
  end
  
  def course_types_name_col
    result = ""
    result += "<div class=\"contact_type_line\">#{joined_course_types_name}</div>" if contact_types.include?(ContactType.student)
    result += "<div class=\"contact_type_line\">#{course_types.map(&:short_name).join(", ")}</div>" if contact_types.include?(ContactType.inquiry)
    result += "<div class=\"contact_type_line\">#{lecturer_course_types.map(&:short_name).join(", ")}</div>" if contact_types.include?(ContactType.lecturer)
    
    return result
  end
  
  def referrer_link
    referrer.nil? ? "" : ('<i class="icon-building"></i> '+referrer.contact_link).html_safe
  end
  
  def contact_link(title=nil)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    title = title.nil? ? display_name : title
    
    link_helper.link_to(title, {controller: "contacts", action: "edit", id: id, tab_page: 1}, class: "tab_page", title: display_name)
  end
  
  def picture_link
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.link_to(display_picture(:thumb), logo+".png", class: "fancybox.image fancybox logo", title: display_name)
  end
  
  def city_name
    city.present? ? city.system_name : ""
  end
  
  def self.where_by_types(types)
    wheres = []
    types.each do |t|
      wheres << "contacts.contact_types_cache LIKE '%[#{t}]%'"
    end
    where("(#{wheres.join(" OR ")})")
  end
  
  def is_main
    parent.first.nil? && !is_agent
  end
  
  def is_agent
    contact_types.include?(ContactType.agent)
  end
  
  
  
  def self.import(file)
    require 'roo'
    
    spreadsheet = Roo::Excelx.new(file.path, nil, :ignore)
    puts spreadsheet.sheets() 
    header = spreadsheet.row(1)
    
    result = Array.new
    
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i, "KH2014")].transpose]
      
      str = String.new
      contact = Contact.new
      if !row["TÊN ĐƠN VỊ"].nil?
        str = row["TÊN ĐƠN VỊ"].strip

        
        contact.name = row["TÊN ĐƠN VỊ"].strip
        contact.contact_type_id = ContactType.supplier
        contact.tax_code = row["MST"].to_s.strip if !row["MST"].nil?
        contact.address = row["ĐỊA CHỈ"].to_s.strip if !row["ĐỊA CHỈ"].nil?
        contact.phone = row["SỐ ĐIỆN THOẠI"].to_s.strip if !row["ĐIỆN THOẠI"].nil?
        contact.fax = row["SỐ FAX"].to_s.strip if !row["SỐ FAX"].nil?
        contact.email = row["EMAIL CÔNG TY"].to_s.strip if !row["EMAIL CÔNG TY"].nil?
        
        contact.website = row["WEBSITE"].to_s.strip if !row["WEBSITE"].nil?
        contact.account_number = row["SỐ TÀI KHOẢN"].to_s.strip if !row["SỐ TÀI KHOẢN"].nil?
        contact.bank = row["NGÂN HÀNG"].to_s.strip if !row["NGÂN HÀNG"].nil?
        contact.representative = row["NGƯỜI ĐẠI DIỆN"].to_s.strip if !row["NGƯỜI ĐẠI DIỆN"].nil?
        contact.representative_role = row["CHỨC VỤ"].to_s.strip if !row["CHỨC VỤ"].nil?
        contact.representative_phone = row["SỐ ĐT ĐẠI DIỆN"].to_s.strip if !row["SỐ ĐT ĐẠI DIỆN"].nil?
        contact.note = row["NOTE"].to_s.strip if !row["NOTE"].nil?
        
        contact.save
        
        if !row["TÊN NGƯỜI LIÊN HỆ"].nil?
          agent = Contact.new
          
          if row["TÊN NGƯỜI LIÊN HỆ"].strip.split(/,/).length > 1
            names = row["TÊN NGƯỜI LIÊN HỆ"].strip.split(/,/)
            
            names.each_with_index {|name, index|            
              agent = Contact.new
              
              agent.contact_type_id = ContactType.agent
              agent.name = name.strip
              
              
              agent.phone = row["SỐ ĐT NGƯỜI LIÊN HỆ"].to_s.split(/,/)[index].to_s.strip if !row["SỐ ĐT NGƯỜI LIÊN HỆ"].nil?
              agent.email = row["EMAIL NGƯỜI LIÊN HỆ"].to_s.split(/,/)[index].to_s.strip if !row["EMAIL NGƯỜI LIÊN HỆ"].nil?
              agent.account_number = row["SỐ TÀI KHOẢN NGƯỜI LIÊN HỆ"].to_s.split(/,/)[index].to_s.strip if !row["SỐ TÀI KHOẢN NGƯỜI LIÊN HỆ"].nil?
              agent.bank = row["NGÂN HÀNG NGƯỜI LH"].to_s.split(/,/)[index].to_s.strip if !row["NGÂN HÀNG NGƯỜI LH"].nil?
              
              agent.companies << contact
            
              agent.save
            }
            
          else
            agent = Contact.new
            
            agent.contact_type_id = ContactType.agent
            agent.name = row["TÊN NGƯỜI LIÊN HỆ"].strip
            agent.phone = row["SỐ ĐT NGƯỜI LIÊN HỆ"].to_s.strip if !row["SỐ ĐT NGƯỜI LIÊN HỆ"].nil?
            agent.email = row["EMAIL NGƯỜI LIÊN HỆ"].to_s.strip if !row["EMAIL NGƯỜI LIÊN HỆ"].nil?
            agent.account_number = row["SỐ TÀI KHOẢN NGƯỜI LIÊN HỆ"].to_s.strip if !row["SỐ TÀI KHOẢN NGƯỜI LIÊN HỆ"].nil?
            agent.bank = row["NGÂN HÀNG NGƯỜI LH"].to_s.strip if !row["NGÂN HÀNG NGƯỜI LH"].nil?
            
            agent.companies << contact
          
            agent.save
          end
          
        end
        
        
        #note = String.new
        #note = row["STK"].to_s.strip if !row["STK"].nil?
        #note += " / "+row["TẠI NH"].to_s.strip if !row["TẠI NH"].nil?
        #contact.note = note
        
        #contact.save
      end
      
      result << str
    end
    
    return result
  end
  
  def html_info_line
    line = "";
    
    
    
    if is_individual
      birth = !birthday.nil? ? birthday.strftime("%d-%b-%Y") : ""
      line += "<span class=\"box_mini_info nowrap\"><i class=\"icon-calendar\"></i> " + birth + "</span> " if !mobile.nil? && !mobile.empty?
      line += "<span class=\"box_mini_info nowrap\"><i class=\"icon-envelope\"></i> " + email + "</span> " if !email.nil? && !email.empty?
      line += "<span class=\"box_mini_info nowrap\"><i class=\"icon-phone\"></i> " + display_mobile + "</span> " if !mobile.nil? && !mobile.empty? 
    else
      line += "<span class=\"box_mini_info nowrap\"><i class=\"icon-phone\"></i> " + phone + "</span> " if !phone.nil? && !phone.empty?
      line += "<span class=\"box_mini_info nowrap\"><i class=\"icon-envelope\"></i> " + email + "</span> " if !email.nil? && !email.empty?
      line += "Tax Code " + tax_code + "</span><br />" if tax_code.present?
    end
    line += "<div class=\"address_info_line\"><i class=\"icon-truck\"></i> " + address + "</div>" if address.present?
    
    
    return line
  end
  
  def html_agent_line
    line = "";
    line += "<strong>" + name + "</strong><br /> "

    if !phone.nil? && !phone.empty?
      line += "phone: " + phone + " "
    end
    if !mobile.nil? && !mobile.empty?
      line += "mobile: " + mobile + " "
    end
    if !email.nil? && !email.empty?
      line += "email: " + email + " "
    end
    
    return line
  end
  
  def html_agent_input
    line = "";
    line += name

    if !phone.nil? && !phone.empty?
      line += "; phone: " + phone + " "
    end
    if !mobile.nil? && !mobile.empty?
      line += "; mobile: " + mobile + " "
    end
    if !email.nil? && !email.empty?
      line += "; email: " + email + " "
    end
    
    return line
  end
  
  def self.HK
    Contact.where(is_mine: true).first
  end
  
  pg_search_scope :search,
                against: [:cache_search, :name, :address, :website, :phone, :mobile, :fax, :email, :tax_code, :note, :account_number, :bank, :bases],
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def self.full_text_search(params)
    records = self.active_contacts
    if params[:is_individual].present?
      records = records.where(is_individual: params[:is_individual])
    end
    if params[:contact_type_id].present?
      cids = Contact.joins(:contact_types).where(contact_types: {id: params[:contact_type_id]}).map(&:id)
      records = records.where(id: cids)
    end
    records.search(params[:q]).limit(50).map {|model| {:id => model.id, :text => model.display_name(params)} }
  end
  
  def short_name
    name.gsub(/công ty /i,'').gsub(/TNHH /i,'').gsub(/cổ phần /i,'')
  end
  
  def full_address
    ad = ""
    if city.present?
      ad += ", "+city.name_with_state
    end
    ad = address+ad if address.present?
    
    return ad
  end
  
  def agent_list_html
    html = ""
    if !agents.nil?
      agents.each do |agent|
        html += '<div class="agent-line">'
        html += agent.html_agent_line.html_safe
        html += '</div>'
      end
    end
    
    return html
  end
  
  def update_cache
    types = contact_types.map{|t| t.id}
    types_cache = types.empty? ? "" : "["+types.join("][")+"]"
    self.update_attribute(:contact_types_cache, types_cache)
  end
  
  def logo_path(version = nil)
    if self.image_url.nil?
      return "public/img/avatar.jpg"
    elsif !version.nil?
      return self.image_url(version)
    else
      return self.image_url
    end
  end
  
  def logo(version = nil)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.url_for(controller: "contacts", action: "logo", id: self.id, type: version)
  end
  
  def display_name(params=nil)
    sirname = sex == "female" ? "[Ms]" : "[Mr]"
    result = is_individual ? (sirname+" "+name).html_safe.mb_chars.titleize : name
    result = result
    
    if params.present?
      result = result+" (#{self.email})" if params[:email].present?
    end
    
    return result
  end
  
  def name
    return "" if self[:name].nil?
    is_individual ? self[:name].mb_chars.titleize : self[:name]
  end
  
  def display_picture(version = nil)
    self.image_url.nil? ? "<i class=\"icon-picture icon-nopic-60\"></i>".html_safe : "<img width='60' src='#{logo(version)}' />".html_safe
  end
  
  def course_register_count
    active_course_registers.count
  end
  
  def active_transfers
    transfers.where("transfers.parent_id IS NULL AND transfers.status IS NOT NULL AND transfers.status LIKE ?", "%[active]%")
  end
  
  def active_received_transfers
    received_transfers.where("transfers.parent_id IS NULL AND transfers.status IS NOT NULL AND transfers.status LIKE ?", "%[active]%")
  end
  
  def active_all_transfers
    Transfer.where("transfers.parent_id IS NULL AND transfers.status IS NOT NULL AND transfers.status LIKE ?", "%[active]%")
            .where("transfers.contact_id = ? OR transfers.to_contact_id = ?", self.id, self.id)
            .order("created_at ASC")
  end
  
  def transfer_count
    active_all_transfers.count
  end
  
  def payment_count
    count = 0
    active_course_registers.each do |cr|
      count += cr.all_payment_records.count
    end
    
    return count
  end
  
  def contact_tag
    tag.nil? ? ContactTag.new(id: nil, name: "No Tag", description: "") : ContactTag.find(tag.contact_tag_id)
  end
  
  def update_tag(contact_tag, user)
    if self.contact_tag.id == contact_tag.id
      return false
    end    
    
    if !contact_tag.nil?
      tag = ContactTagsContact.create(contact_id: self.id, contact_tag_id: contact_tag.id, user_id: user.id)
      if !tag.id.nil?
        self.update_attribute(:tag_id, tag.id)
        return true
      else
        return false
      end      
    end
    return false
  end
  
  def update_cache_course_type_ids
    cache = "["+joined_course_types.map(&:id).join("][")+"]"
    self.update_attribute(:cache_course_type_ids,cache)
  end
  
  def students
    ContactType.student.contacts
  end
  
  def course_list_link(title=nil)
    title = title.nil? ? "Course List (#{active_courses_with_phrases.count.to_s})" : title
    ActionController::Base.helpers.link_to(title, {controller: "contacts", action: "edit", id: self.id, tab_page: 1, tab: "course"}, title: "#{display_name}: Course List", class: "tab_page")
  end
  
  def course_count_link
    if is_individual
      result = active_courses_with_phrases.count == 0 ? "" : self.course_list_link("["+active_courses_with_phrases.count.to_s+"]")
    else
      result = contacts_link
    end
  end
  
  def contacts_link
    ActionController::Base.helpers.link_to("["+contacts.count.to_s+"]", {controller: "contacts", action: "index", company_id: self.id, tab_page: 1}, title: "#{display_name}: Contact List", class: "tab_page")
  end
  
  def json_encode_course_type_ids_names
    json = course_types.map {|t| {id: t.id.to_s, text: t.short_name}}
    json.to_json
  end
  
  def json_encode_contact_tag_ids_names
    json = contact_tags.map {|t| {id: t.id.to_s, text: t.name}}
    json.to_json
  end
  
  def json_encode_lecturer_course_type_ids_names
    json = lecturer_course_types.map {|t| {id: t.id.to_s, text: t.short_name}}
    json.to_json
  end
  
  def set_present_in_seminar(seminar, checked)
    contacts_seminar = seminar.contacts_seminars.where(contact_id: self.id).first    
    contacts_seminar.update_attribute(:present, checked)
  end
  
  def default_mailing_address
    if preferred_mailing == "home"
      return address
    elsif preferred_mailing == "company"
      return referrer.address
    elsif preferred_mailing == "ftms"
      return "FTMS"
    else
      return mailing_address
    end
    
  end
  
  def default_mailing_title
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
  
  def course_count
    active_courses_with_phrases.count
  end
  
  def learned_courses
    arr = []
    active_courses_with_phrases.each do |row|
      if row[:course].upfront || row[:courses_phrases].count == row[:course].courses_phrases.count
        arr << row[:course]
      end
    end
    return arr
  end
  
  def book_count
    active_books.count
  end
  
  def vat_name
    if invoice_required == true
      return invoice_info.nil? ? "" : invoice_info.name
    else
      return ""
    end    
  end
  def vat_code
    if invoice_required == true
      return invoice_info.nil? ? "" : invoice_info.tax_code
    else
      return ""
    end 
  end
  def vat_address
    if invoice_required == true
      return invoice_info.nil? ? "" : invoice_info.address
    else
      return ""
    end
  end
  
  def update_bases(bases)
    result = []
    bases.each do |row|
      if row[1]["course_type_id"].present? && row[1]["name"].present? && row[1]["password"].present?
        item = {}
        item[:course_type_id] = row[1]["course_type_id"]
        item[:name] = row[1]["name"]
        item[:password] = row[1]["password"]
        item[:status] = row[1]["status"]
        
        result << item
      end
    end
    
    self.bases = result.to_json
  end
  
  def base_items
    arr = self.bases.present? ? JSON.parse(self.bases) : []
    result = []
    arr.each do |item|
      one = item
      one["course_type"] = CourseType.find(one["course_type_id"])
      
      result << one
    end
    
    return result
  end
  
  def books_contact(book)
    books_contacts.where(book_id: book.id).first
  end
  
  
  ############### BEGIN REVISION #########################
  
  def self.main_contacts
    self.where(draft_for: nil)
  end
  
  def self.active_contacts
    self.main_contacts.where("status IS NOT NULL AND status LIKE ?", "%[active]%")
  end
  
  
  
  def draft?
    !draft_for.nil?
  end
  
  def update_status(action, user, older = nil)
    # when create new contact
    if action == "create"      
      # check if the contact is student
      if is_individual?        
        self.add_status("new_pending")
        
        # check if education consultant peding
        if self.account_manager.present?
          self.add_status("education_consultant_pending")
        end        
      else
        # auto active if contact is company/organization
        self.add_status("active")
      end
    end
    
    # when update exist contact
    if action == "update"
      # check if the contact is student
      if is_individual?        
        self.add_status("update_pending") if !self.has_status("new_pending")
        
        # check if education consultant peding
        if self.account_manager != self.current.account_manager
          self.add_status("education_consultant_pending")
        end
      else
      end
    end
    
    self.check_statuses
  end  
  
  def statuses
    status.to_s.split("][").map {|s| s.gsub("[","").gsub("]","")}
  end
  
  def display_statuses
    return "" if statuses.empty?
    result = statuses.map {|s| "<span title=\"Last updated: #{current.created_at.strftime("%d-%b-%Y, %I:%M %p")} / By: #{current.user.name}\" class=\"badge user-role badge-info contact-status #{s}\">#{s}</span>"}
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
  
  def approve_education_consultant(user)
    if statuses.include?("education_consultant_pending")
      self.delete_status("education_consultant_pending")      
      self.check_statuses
      
      # Annoucing users
      add_annoucing_users([self.current.user, self.account_manager])
      
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
    if !statuses.include?("deleted") && !statuses.include?("delete_pending") && !statuses.include?("update_pending") && !statuses.include?("new_pending") && !statuses.include?("education_consultant_pending") && !statuses.include?("no_education_consultant")
      add_status("active")
      if self.account_manager.present? && !self.creator.present?
        self.creator = self.account_manager 
        self.save
      end
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
    new_contact = self.dup
    new_contact.draft_for = self.id
    new_contact.user_id = user.id
    
    new_contact.contact_types = self.contact_types
    new_contact.course_types = self.course_types
    new_contact.lecturer_course_types = self.lecturer_course_types
    
    new_contact.save
    
    # copy image
    new_contact = self.current
    new_contact.image = File.open(self.image_url) if self.image.present?    
    new_contact.save
    
    return new_contact
  end
  
  def current
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
      return draft_for_contact.drafts.where("created_at < ?", self.created_at).order("created_at DESC").first
    end
  end
  
  def active_older
    if !draft?
      olders = drafts.order("created_at DESC").where("status LIKE ?", "%[active]%")
      return statuses.include?("active") ? olders.second : olders.first
    else
      return draft_for_contact.drafts.where("created_at < ?", self.created_at).where("status LIKE ?", "%[active]%").order("created_at DESC").first
    end
  end
  
  def field_history(type,value=nil)
    return [] if !self.current.nil? && self.current.statuses.include?("active")
        
    
    if self.draft?
      drafts = self.draft_for_contact.drafts #.where("contacts.status LIKE ?","%[active]%")
      drafts = drafts.where("created_at > ?", self.created_at)
    else
      drafts = self.drafts
      drafts = drafts.where("created_at < ?", self.current.created_at) if self.current.present?    
      drafts = drafts.where("created_at >= ?", self.active_older.created_at) if !self.active_older.nil?
    end
    
    drafts = drafts.order("created_at DESC")
    
    if type == "inquiry_course_type"
      drafts = drafts.select{|c| c.course_types.order("short_name").map(&:short_name).join("") != self.course_types.order("short_name").map(&:short_name).join("")}
    elsif type == "lecturer_course_type"
      drafts = drafts.select{|c| c.lecturer_course_types.order("short_name").map(&:short_name).join("") != self.lecturer_course_types.order("short_name").map(&:short_name).join("")}    
    elsif type == "contact_type"
      drafts = drafts.select{|c| c.contact_types.order("name").map(&:name).join("") != self.contact_types.order("name").map(&:name).join("")}
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
      ["Education Consultant Pending","education_consultant_pending"],
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
    older = self.active_older
    
    self.update_attributes(older.attributes.select {|k,v| !["draft_for","id", "created_at", "updated_at"].include?(k) })
    
    self.contact_types = older.contact_types
    self.course_types = older.course_types
    self.lecturer_course_types = older.lecturer_course_types
    
    self.save
    
    self.save_draft(user)
  end
  
  def add_annoucing_users(users)
    us = self.annoucing_users.map(&:id)
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
  
  
  def preferred_mailing_address
    case preferred_mailing
    when "ftms"
      result = "FTMS address"
    when "home"
      result = self.address
    when "company"
      result = self.referrer.address
    when "other"
      result = self.mailing_address
    else
    end
    
    return result
  end
  
  def display_bases
    result = []
    base_items.each do |b|
      result << b["name"]
    end
  end
  
  def current_contacts_courses
    self.contacts_courses.includes(:course).order("courses.intake DESC")
  end
  
  def budget_hour
    hours = {}
    
    active_received_transfers.where(to_type: "hour").each do |transfer|
      hour_id = transfer.course.course_type_id.to_s+"-"+transfer.course.subject_id.to_s
      hours[hour_id] = hours[hour_id].nil? ? transfer.hour.to_f :  hours[hour_id] + transfer.hour.to_f
    end
    active_contacts_courses.joins("LEFT JOIN courses ON courses.id = contacts_courses.course_id").each do |cc|
      hour_id = cc.course.course_type_id.to_s+"-"+cc.course.subject_id.to_s
      hours[hour_id] = hours[hour_id].nil? ? -cc.hour.to_f : hours[hour_id] - cc.hour.to_f
    end
    
    active_transfers.where.not(from_hour: nil).each do |transfer|
        JSON.parse(transfer.from_hour).each do |row|
          tr = Transfer.find(row[0])
          hour_id = tr.course.course_type_id.to_s+"-"+tr.course.subject_id.to_s
          hours[hour_id] = hours[hour_id].nil? ? -row[1].to_f : hours[hour_id] - row[1].to_f
        end
    end
    
    return hours
  end
  
  def recent_hour_transfers(hid)
    origin = []
    active_received_transfers.where(to_type: "hour").order("created_at").each do |transfer|
      hour_id = transfer.course.course_type_id.to_s+"-"+transfer.course.subject_id.to_s
      origin << transfer if hid == hour_id
    end
    
    # total used
    used_hours = {}

    active_contacts_courses.joins("LEFT JOIN courses ON courses.id = contacts_courses.course_id").each do |cc|
      hour_id = cc.course.course_type_id.to_s+"-"+cc.course.subject_id.to_s
      used_hours[hour_id] = used_hours[hour_id].nil? ? cc.hour.to_f : used_hours[hour_id] + cc.hour.to_f
    end
    
    # calculate used hour
    arr = []
    origin.each do |transfer|      
      hour_id = transfer.course.course_type_id.to_s+"-"+transfer.course.subject_id.to_s
      
      row = {}
      row[:transfer] = transfer
      row[:remain_hour] = transfer.remain_hour(self)
      row[:remain_money] = transfer.remain_money(self)
      if used_hours[hour_id] > 0
        if used_hours[hour_id] > row[:remain_hour]
          used_hours[hour_id] -= row[:remain_hour]
          row[:remain_hour] = 0
          row[:remain_money] = 0
        else
          rate = row[:remain_money]/row[:remain_hour]
          row[:remain_hour] -= used_hours[hour_id]
          row[:remain_money] -= used_hours[hour_id]*rate
          used_hours[hour_id] = 0
        end        
      end
      
      arr << row if row[:remain_hour] > 0
    end
    
    return arr
  end
  
  def recent_hour_rate
    rates = {}
    
    active_received_transfers.where(to_type: "hour").order("created_at").each do |transfer|
      hour_id = transfer.course.course_type_id.to_s+"-"+transfer.course.subject_id.to_s
      rates[hour_id] = transfer.hour_money.to_f / transfer.hour.to_f if rates[hour_id].nil?
    end
    
    return rates
  end
  
  def budget_hour_sum
    total = 0
    budget_hour.each do |col|
      total += col[1]
    end
    return total
  end
  
  def display_budget_hour
    str = []
    budget_hour.each do |col|
      str << CourseType.find(col[0].split("-")[0]).short_name+"-"+Subject.find(col[0].split("-")[1]).name+": "+col[1].to_s if col[1] != 0
    end
    return str.join("<br >").html_safe
  end
  
  def budget_money
    active_received_transfers.where(to_type: "money").sum(:money) - active_contacts_courses.sum(:money)
  end
  
  def active_transferred_records
    transferred_records.where("transfers.parent_id IS NULL AND transfers.status IS NOT NULL AND transfers.status LIKE ?", "%[active]%")
  end
  
  
  
  def self.base_status_options
    [["In Progress","in_progress"],["Completed","completed"]]
  end
  
  def activity_count
    activities.where(deleted: 0).count
  end
  
  def seminar_count
    seminars.count
  end
  
  def base_id_by_program_id(course_type_id)
    return "" if bases.nil?
    
    b_arr = JSON.parse(bases)
    b_arr.each do |item|
      return CourseType.find(course_type_id).short_name+"-"+item["name"] if item["course_type_id"].to_i == course_type_id.to_i
    end
    return ""
  end
  
  def base_ids_by_program_id(ids)
    arr = []
    ids.each do |bid|
      arr << base_id_by_program_id(bid)
    end
    return arr.join("\n")
  end
  
  def staff_col
    account_manager.nil? ? "" : account_manager.staff_col
  end
  
  def active_courses_with_phrases(datetime=nil)
    origin = []
    accs = active_contacts_courses
    accs = accs.where("course_registers.created_at <= ?", datetime) if !datetime.nil?
    accs.each do |cc|
      row = {}
      row[:course] = cc.course
      th = 0
      ContactsCourse.find(cc.id).courses_phrases.each do |cp|
        th += cp.hour
      end
      row[:hour] = th == 0 ? "N/A" : th
      row[:money] = ContactsCourse.find(cc.id).price
      row[:courses_phrases] = ContactsCourse.find(cc.id).courses_phrases
      row[:created_at] = ContactsCourse.find(cc.id).course_register.created_at
      origin << row
    end
    
    # transferred to others
    transfers = active_all_transfers
    transfers = transfers.where("transfers.created_at <= ?", datetime) if !datetime.nil?
    transfers.each do |transfer|
      
      # TRANSFER      
      if self == transfer.contact
        new_origin = []
        origin.each do |row|
          remove_course = false
          
          
          if !transfer.course.nil? && !row[:course].nil? && row[:course].id == transfer.course.id && row[:created_at] < transfer.created_at
            
            # upfront course
            if transfer.course.upfront == true
              remove_course = true
            else
              row[:courses_phrases] -= transfer.courses_phrases
              remove_course = true if row[:courses_phrases].empty?
            end
          end

          
          # remove course
          new_origin << row if remove_course == false
        end
        origin = new_origin
      end
      
      
      
      # RECEIVED
      if self == transfer.to_contact
        if transfer.to_type == "course"
          # add or update course
          course = transfer.to_course
          courses_phrases = transfer.to_courses_phrases
          
          exist = false
          origin.each do |row|
            if row[:course] == transfer.to_course
              row[:courses_phrases] += transfer.to_courses_phrases
              row[:courses_phrases] = row[:courses_phrases].uniq
              
              exist = true
            end           
          end
          origin << {course: course, courses_phrases: courses_phrases, hour: transfer.to_course_hour, money: transfer.to_course_money, created_at: transfer.created_at} if exist == false
          
          
        end
      end
      
    end
    
    # uniq courses
    #row[:course] = cc.course
    #  th = 0
    #  ContactsCourse.find(cc.id).courses_phrases.each do |cp|
    #    th += cp.hour
    #  end
    #  row[:hour] = th == 0 ? "N/A" : th
    #  row[:money] = ContactsCourse.find(cc.id).price
    #  row[:courses_phrases] = ContactsCourse.find(cc.id).courses_phrases
    #  row[:created_at] = cc.course_register.created_at
    merged_courses = {}
    origin.each do |item|
      if merged_courses[item[:course].id].nil?
        merged_courses[item[:course].id] = {}
        merged_courses[item[:course].id][:course] = item[:course]
        merged_courses[item[:course].id][:hour] = item[:hour]
        merged_courses[item[:course].id][:money] = item[:money]
        merged_courses[item[:course].id][:courses_phrases] = item[:courses_phrases]
        merged_courses[item[:course].id][:created_at] = item[:created_at]
      else
        merged_courses[item[:course].id][:hour] = item[:hour]
        merged_courses[item[:course].id][:money] = item[:money]
        merged_courses[item[:course].id][:courses_phrases] = item[:courses_phrases]
        merged_courses[item[:course].id][:created_at] = item[:created_at]
      end     
    end
    
    new_origin = []
    merged_courses.each do |mc|
      new_origin << mc[1]
    end
    
    return new_origin
  end
  
  def active_course(course_id, datetime=nil)
    active_courses_with_phrases(datetime).each do |row|
      if row[:course].id == course_id
        return row
      end      
    end
    return nil
  end
  
  def display_active_course(course_id)
    course = Course.find(course_id)
    
    arr = []
    arr << "<div class=\"nowrap\"><strong>"+active_course(course_id)[:course].display_name+"</strong> <span>#{course.report_toggle(self)}</span></div>"
    arr << "<div class=\"courses_phrases_list\">"+Course.render_courses_phrase_list(active_course(course_id)[:courses_phrases])+"</div>" if !active_course(course_id)[:courses_phrases].empty?
    arr << "<br /><div>Hour: <strong>#{self.active_course(course_id)[:hour]}</strong> <br /> Money: <strong>#{ApplicationController.helpers.format_price(self.active_course(course_id)[:money])}</trong></div>"
    return arr.join("")
  end
  
  def courses_phrase_registered?(courses_phrase)
    active_courses_with_phrases.each do |row|
      row[:courses_phrases].each do |cp|
        if cp.id == courses_phrase.id
          return true
        end        
      end
    end
    return false
  end
  
  def render_cache_search
    str = []
    str << display_name.unaccent
    str << "[tag:"+(contact_tags.map {|ct| ct.name}).join("][tag:")+"]"
    str << mobile.to_s.gsub(/^84/,"")
    str << "0" + mobile.to_s.gsub(/^84/,"")
    str << phone.to_s.gsub(/^84/,"")
    str << "0" + phone.to_s.gsub(/^84/,"")
    str << referrer.name if !referrer.nil?
    
    return str.join(" ")
  end
  
  def update_cache_search
    return false if !self.draft_for.nil?
    
    self.update_attribute(:cache_search, self.render_cache_search)
  end
  
  def real_courses
    arr = []
    active_courses_with_phrases.each do |row|
      arr << row[:course]
    end
    
    return arr
  end
  
  def update_cache_courses
    self.update_attribute(:cache_courses, "["+real_courses.map(&:id).join("][")+"]")
  end
  
end
