class Book < ActiveRecord::Base
  include PgSearch
  
  #validates :name, presence: true
  validates :user_id, presence: true
  
  belongs_to :user
  belongs_to :course_type
  belongs_to :subject
  belongs_to :stock_type
  
  has_many :book_prices
  has_many :books_contacts
  
  has_many :stock_updates
  
  has_many :delivery_details
  
  ########## BEGIN REVISION ###############
  validate :check_exist
  
  has_many :drafts, :class_name => "Book", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Book", :foreign_key => "parent_id"  
  has_one :current, -> { order created_at: :desc }, class_name: 'Book', foreign_key: "parent_id"
  ########## END REVISION ###############
  
  mount_uploader :image, BookUploader
  after_create :update_cache_search
  
  pg_search_scope :search,
                against: [:name, :publisher, :cache_search],
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def valid_from=(new)
    self[:valid_from] = new.to_datetime.beginning_of_day
  end
  def valid_to=(new)
    self[:valid_to] = new.to_datetime.end_of_day
  end
  
  def self.full_text_search(params)    
    self.main_books.order("name").search(params[:q]).limit(50).map {|model| {:id => model.id, :text => model.name} }
  end
  
  def self.active_books_contacts
    BooksContact.joins("LEFT JOIN course_registers ON course_registers.id = books_contacts.course_register_id")
                    .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status LIKE ?", "%[active]%")
                    .uniq
  end
  
  def active_books_contacts
    Book.active_books_contacts.where(book_id: self.id).uniq
  end
  
  def cover_path(version = nil)
    if self.image_url.nil?
      return "public/img/avatar.jpg"
    elsif !version.nil?
      return self.image_url(version)
    else
      return self.image_url
    end
  end
  
  def cover(version = nil)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.url_for(controller: "books", action: "cover", id: self.id, type: version)
  end
  
  def self.filter(params, user)
    @records = self.main_books.includes(:stock_type, :course_type, :subject, :books_contacts => :course_register)
    @records = @records.where(course_type_id: params["program_id"]) if params["program_id"].present?
    @records = @records.where(subject_id: params["subject_id"]) if params["subject_id"].present?
    
    ########## BEGIN REVISION-FEATURE #########################
    
    if params[:status].present?
      if params[:status] == "pending"
        @records = @records.where("books.status LIKE ?","%_pending]%")
      elsif params[:status] == "approved" # for approved
        @records = @records.where("books.annoucing_user_ids LIKE ?", "%[#{user.id}%]")
      else
        @records = @records.where("books.status LIKE ?","%[#{params[:status]}]%")
      end
    end
    
    if !params[:status].present? || params[:status] != "deleted"
      @records = @records.where("books.status NOT LIKE ?","%[deleted]%")
    end

    ########## END REVISION-FEATURE #########################
    
    if params[:stock_types].present?
      @records = @records.where(stock_type_id: params[:stock_types])
    end
    
    if !params[:status].present?
      @records = @records.where("books.valid_from <= ?", params[:valid_on].to_datetime.beginning_of_day) if params[:valid_on].present?
      @records = @records.where("books.valid_to >= ?", params[:valid_on].to_datetime.end_of_day) if params[:valid_on].present?
    end
        
    return @records
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = Book.filter(params, user)  
    #@records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    @records = @records.where("LOWER(books.cache_search) LIKE ?", "%#{params["search"]["value"].strip.downcase}%") if params["search"].present? && !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "2"
        order = "course_types.short_name #{params["order"]["0"]["dir"]}, subjects.name #{params["order"]["0"]["dir"]}, books.name #{params["order"]["0"]["dir"]}"      
      when "3"
        order = "books.publisher"
      else
        order = "books.name"
      end
      order += " "+params["order"]["0"]["dir"] if params["order"]["0"]["column"] != "1"
    else
      order = "books.created_at"
    end
    
    
    
    @records = @records.order(order) if !order.nil? && !params["search"]["value"].present?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 11
    itemsx = []
    @records.each do |item|
      ############### BEGIN REVISION #########################
      # update approved status
      if params[:status].present? && params[:status] == "approved"
        item.remove_annoucing_users([user])
      end
      ############### END REVISION #########################
      
      itemx = [
              "<div item_id=\"#{item.id.to_s}\" class=\"main_part_info checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
              item.cover_link,                            
              item.book_link, # '<div class="text-center">'+item.stock_type.name+"</div>",
              '<div class="text-left">'+item.publisher.to_s+"</div>",
              '<div class="text-right">'+item.display_prices+"</div>",
              '<div class="text-center">'+item.stock.to_s+"</div>",
              '<div class="text-center">'+BooksContact.to_be_delivered_count(item.id).to_s+"</div>",
              '<div class="text-center">'+BooksContact.to_be_ordered_count(item.id).to_s+"</div>",
              '<div class="text-center">'+BooksContact.to_be_imported_count(item.id).to_s+"</div>",
              '<div class="text-center">'+item.user.staff_col+"</div>",
              '<div class="text-center">'+item.display_statuses+"</div>",
              ''
            ]
      data << itemx
      itemsx << item

      
    end
    
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    return {result: result, items: itemsx, actions_col: actions_col}
    
  end
  
  def self.statistics(params, user)
    @records = Book.filter(params, user)  
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    # date
    from_date = params["from_date"].to_datetime.beginning_of_day
    to_date = params["to_date"].to_datetime.end_of_day

    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "course_types.short_name #{params["order"]["0"]["dir"]}, subjects.name #{params["order"]["0"]["dir"]}, books.name #{params["order"]["0"]["dir"]}"      
      end
      order += " "+params["order"]["0"]["dir"] if params["order"]["0"]["column"] != "1"
    else
      order = "course_types.short_name, subjects.name, books.name"      
    end
    
    @records = @records.order(order) if !order.nil? && !params["search"]["value"].present?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 5
    itemsx = []
    @records.each do |item|
      ############### BEGIN REVISION #########################
      # update approved status
      if params[:status].present? && params[:status] == "approved"
        item.remove_annoucing_users([user])
      end
      ############### END REVISION #########################
      
      itemx = [
              item.cover_link,                            
              item.book_link,
              '<div class="text-center">'+item.stock(nil, from_date).to_s+"</div>",
              '<div class="text-center">'+item.imported_count(from_date, to_date).to_s+"</div>",
              '<div class="text-center">'+item.exported_count(from_date, to_date).to_s+"</div>",
              '<div class="text-center">'+item.delivered_count(from_date, to_date).to_s+"</div>",
              '<div class="text-center">'+item.stock(nil, to_date).to_s+"</div>",
            ]
      data << itemx
      itemsx << item

      
    end
    
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    return {result: result, items: itemsx, actions_col: actions_col}
    
  end
  
  def course_type_short_name
    course_type.nil? ? "" : course_type.short_name
  end
  def subject_name
    subject.nil? ? "" : subject.name
  end
  
  def self.student_books(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @student = Contact.find(params[:student])
    
    @records =  self.filter(params, user)
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    @records = @records.includes(:books_contacts => :course_register)
    bids = Book.active_books_contacts.where(contact_id: @student.id).map(&:book_id)
    @records = @records.where(id: bids)
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "course_types.short_name #{params["order"]["0"]["dir"]}, subjects.name #{params["order"]["0"]["dir"]}, books.name #{params["order"]["0"]["dir"]}"
      when "2"
        order = "books.publisher"
      when "4"
        order = "course_registers.created_at"
      else
        order = "books.name"
      end
      order += " "+params["order"]["0"]["dir"] if !["1"].include?(params["order"]["0"]["column"])
    else
      order = "course_registers.created_at"
    end
    
    @records = @records.order(order) if !order.nil? && !params["search"]["value"].present?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 7
    @records.each do |item|
      item = [
              item.cover_link,
              item.book_link(item.display_name),
              '<div class="text-left">'+item.publisher.to_s+"</div>",
              '<div class="text-center">'+item.active_books_contacts.where(contact_id: @student.id).sum(:quantity).to_s+"</div>", #'<div class="text-right">'+ApplicationController.helpers.format_price(@student.books_contact(item).total)+"</div>",
              '<div class="text-center">'+ item.display_registerd_at(@student)+"</div>",
              '<div class="text-center">'+ item.display_delivery_status(@student)+"</div>", 
              '<div class="text-center">'+item.display_creator(@student)+"</div>",
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
  
  def course_registers
    CourseRegister.where(id: active_books_contacts.map(&:course_register_id))
  end
  
  def display_registerd_at(contact)
    (course_registers.where(contact_id: contact.id).map {|cr| cr.created_at.strftime("%d-%b-%Y")}).join("<br />").html_safe
  end
  
  def display_creator(contact)
    (course_registers.where(contact_id: contact.id).map {|cr| cr.user.staff_col}).join("<br />").html_safe
  end
  
  def display_delivery_status(contact)
    str = []
    active_books_contacts.where(contact_id: contact.id).each do |bc|
      str << bc.display_delivery_status
    end
    return str.join("<br />").html_safe
  end
  
  def cover_link
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.link_to(display_cover(:thumb), cover, class: "fancybox.image fancybox", title: name)
  end
  

  
  def display_volumns
    vs = []
    volumns.each do |b|
      vs << "<div class=\"volumn_line\">#{b.name}</div>"
    end
    
    return vs.join(" ").html_safe
  end
  
  def display_cover(version = nil)
    self.image_url.nil? ? "<i class=\"icon-picture icon-nopic-60\"></i>".html_safe : "<img width='60' src='#{cover(version)}' />".html_safe
  end
  
  def book_link(title=nil)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    title = title.nil? ? display_name : title
    
    link_helper.link_to(title, {controller: "books", action: "edit", id: id, tab_page: 1}, class: "tab_page", title: name)+"<div class=\"nowrap\">#{display_valid_time}</div>".html_safe
  end
  
  def book_price
    book_prices.order("created_at DESC").first
  end
  
  def prices
    if book_price.nil?
      return []
    else
      return JSON.parse(book_price.prices)
    end   
  end
  
  def display_prices
    a = prices.map {|p| ApplicationController.helpers.format_price(p)}
    return a.join("<br />")
  end
  
  def update_price(new_price)
    if book_price.nil?
      new_price.save
    else
      if book_price.prices != new_price.prices
        new_price.save
      end      
    end
  end  
  
  def course_type_ids=(new)
    arr = new.split(",").map {|s| s.to_i}
    self[:course_type_ids] = arr.to_json
  end
  
  def course_type_ids_json
    json = course_types.map {|t| {id: t.id.to_s, text: t.short_name}}
    json.to_json
  end
  
  def course_types
    arr = course_type_ids.nil? ? [] : JSON.parse(course_type_ids)
    
    return CourseType.where(id: arr).order("short_name")
  end
  
  def subject_ids=(new)
    arr = new.split(",").map {|s| s.to_i}
    self[:subject_ids] = arr.to_json
  end
  
  def subject_ids_json
    json = subjects.map {|t| {id: t.id.to_s, text: t.name}}
    json.to_json
  end
  
  def subjects
    arr = subject_ids.nil? ? [] : JSON.parse(subject_ids)
    
    return Subject.where(id: arr).order("name")
  end

  
  def type_name
    course_types.map(&:short_name).join(", ")
  end
  
  def stock(from=nil,to=nil)
    total = 0
    total += imported_count(from,to)
    total -= exported_count(from,to)
    
    #delivery
    total -= delivered_count(from,to)
    
    return total
  end
  
  def delivered_count(from=nil, to=nil)
    records = self.delivery_details.includes(:delivery => :course_register)
                    .where(deliveries: {status: 1})
                    .where("course_registers.parent_id IS NULL").where("course_registers.status LIKE ?", "%[active]%")
    
    if from.present?
      records = records.where("deliveries.delivery_date >= ?", from)
    end
    if to.present?
      records = records.where("deliveries.delivery_date <= ?", to)
    end
    
    return records.sum(:quantity)
                    
  end
  
  def imported_count(from=nil, to=nil)
    records = stock_updates.where(type_name: "import")
    
    if from.present?
      records = records.where("created_at >= ?", from)
    end
    if to.present?
      records = records.where("created_at <= ?", to)
    end
    
    return records.sum(:quantity)
                    
  end
  
  def exported_count(from=nil, to=nil)
    records = stock_updates.where(type_name: "export")
    
    if from.present?
      records = records.where("created_at >= ?", from)
    end
    if to.present?
      records = records.where("created_at <= ?", to)
    end
    
    return records.sum(:quantity)
                    
  end
  
  ############### BEGIN REVISION #########################
  
  def check_exist
    return false
    #return false if draft?
    #
    #exist = Book.main_books.where("name = ?",
    #                      self.name
    #                    )
    #
    #if self.id.nil? && exist.length > 0
    #  errors.add(:base, "Book exists")
    #end
    
  end
  
  def self.main_books
    self.where(parent_id: nil)
  end
  def self.active_books
    self.main_books.where("status IS NOT NULL AND status LIKE ? AND status NOT LIKE ?", "%[active]%", "%[out_of_date]%")
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
    aa = statuses # statuses.include?("out_of_date") ? ["out_of_date"] : statuses
    result = aa.map { |s|
      if (statuses.include?("out_of_date") || is_in_progress?) && s == "active"
        ""
      else
        "<span title=\"Last updated: #{current.created_at.strftime("%d-%b-%Y, %I:%M %p")}; By: #{current.user.name}\" class=\"badge user-role badge-info contact-status #{s}\">#{s}</span>"
      end
    }
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
  
  def undo_delete(user)
    if statuses.include?("delete_pending")  || statuses.include?("deleted")
      recent = older
      while recent.statuses.include?("delete_pending") || recent.statuses.include?("deleted")
        recent = recent.older
      end
      self.update_attribute(:status, recent.status)

      self.check_statuses
      
      # Annoucing users
      add_annoucing_users([self.current.user])
      
      self.save_draft(user)
    end
  end
  
  def check_statuses
    if !statuses.include?("deleted") && !statuses.include?("delete_pending") && !statuses.include?("update_pending") && !statuses.include?("new_pending")
      add_status("active")     
    else
      delete_status("active")
    end    
  end
  
  def is_out_of_date?
    #o_from = (!valid_from.nil? and valid_from >= Time.now)
    o_to = (!valid_to.nil? and valid_to <= Time.now)
    return o_to # (o_from || o_to)
  end
  
  def is_in_progress?
    o_from = (!valid_from.nil? and valid_from >= Time.now)
    #o_to = (!valid_to.nil? and valid_to <= Time.now)
    return o_from # (o_from || o_to)
  end
  
  def check_out_of_date
    if is_out_of_date?
      add_status("out_of_date")
      return true
    else
      delete_status("out_of_date")
      return false
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
    
    # dup book prices
    self.book_prices.each do |p|
      draft.book_prices << p.dup
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
      drafts = drafts.where("created_at >= ?", self.created_at)
    else
      drafts = self.drafts
      
      drafts = drafts.where("created_at <= ?", self.current.created_at) if self.current.present?    
      drafts = drafts.where("created_at >= ?", self.active_older.created_at) if !self.active_older.nil?    
      drafts = drafts.order("created_at")
    end
    
    #if type == "course_type"
    #  drafts = drafts.select{|c| c.course_types.map(&:name).join("") != self.course_types.map(&:name).join("")}
    #elsif type == "subject"
    #  drafts = drafts.select{|c| c.subjects.map(&:name).join("") != self.subjects.map(&:name).join("")}
    #elsif type == "book_price"
    #  drafts = drafts.select{|c| self.book_price.prices != c.book_price.prices}
    #else
    #  value = value.nil? ? self[type] : value
    #  drafts = drafts.where("#{type} IS NOT NUll AND #{type} != ?", value)
    #end
    
    arr = []
    value = "-1"
    drafts.each do |c|
      if type == "course_type"
        arr << c if c.course_types.map(&:name).join("") != value
        value = c.course_types.map(&:name).join("")        
      elsif type == "subject"
        arr << c if c.subjects.map(&:name).join("") != value
        value = c.subjects.map(&:name).join("")        
      elsif type == "book_price"
        arr << c if self.book_price.prices != value
        value = self.book_price.prices
      else
        arr << c if !c[type].nil? && c[type] != value
        value = c[type]
      end
    end
    
    return (arr.count > 1) ? arr : []
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
      ["Out Of Date","out_of_date"],
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
  
  def display_name   
    return [paper_name,type_name].join("-")
  end
  
  def paper_name
    str = []
    str << course_type.short_name if !course_type.nil?
    str << subject.name if !subject.nil?
    
    return str.join("-").html_safe
  end
  
  def type_name
    str = []    
    str << stock_type.name if !stock_type.nil?
    #str << name
    
    return str.join("-").html_safe
  end
  
  def registered?(contact)
    BooksContact.joins(:course_register)
                .where.not("course_registers.status LIKE ?", "%[deleted]%")
                .where(book_id: self.id)
                .where(contact_id: contact.id).count > 0
  end
  
  def update_cache_search
    return false if !self.parent_id.nil?
  
    str = []
    str << display_name
    str << stock_type.name if !stock_type.nil?
    str << publisher.to_s
    str << display_prices
    str << user.name
    str << display_statuses
    
    self.update_attribute(:cache_search, str.join(" "))
  end
  
  def display_valid_time
    str = []
    str << valid_from.strftime("%d-%b-%Y") if valid_from.present?
    str << valid_to.strftime("%d-%b-%Y") if valid_to.present?
    return ("<span class=\"book_valid_time\">"+str.join(" to ")+"</span>").html_safe
  end
  
  def display_valid_time_raw
    str = []
    str << valid_from.strftime("%d-%b-%Y") if valid_from.present?
    str << valid_to.strftime("%d-%b-%Y") if valid_to.present?
    return ("("+str.join(" to ")+")").html_safe
  end
  
end
