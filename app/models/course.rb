class Course < ActiveRecord::Base
  include PgSearch
  
  validates :course_type, :presence => true
  validates :subject_id, :presence => true
  
  validate :course_exist
  
  belongs_to :user
  belongs_to :course_type
  belongs_to :subject
  
  belongs_to :lecturer, :class_name => "Contact"
  
  has_and_belongs_to_many :contacts
  has_many :contacts_courses
  
  has_many :courses_phrases, :dependent => :destroy
  has_and_belongs_to_many :phrases
  
  has_many :course_prices, :dependent => :destroy
  
  has_many :transfers
  has_many :received_transfers, class_name: "Transfer", foreign_key: "to_course_id"
  
  ########## BEGIN REVISION ###############
  has_many :drafts, :class_name => "Course", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Course", :foreign_key => "parent_id"  
  has_one :current, -> { order created_at: :desc }, class_name: 'Course', foreign_key: "parent_id"
  ########## END REVISION ###############
  
  pg_search_scope :search,
                  against: [:description],
                  associated_against: {
                    course_type: [:name, :short_name],
                    subject: [:name]
                  },
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
  
  def active_transfers
    transfers.where("transfers.parent_id IS NULL AND transfers.status IS NOT NULL AND transfers.status LIKE ?", "%[active]%").where("contact_id = ? OR transfer_for = ?", self.id, self.id)
            .uniq
  end
  
  def active_received_transfers
    received_transfers.where("transfers.parent_id IS NULL AND transfers.status IS NOT NULL AND transfers.status LIKE ?", "%[active]%").where("contact_id = ? OR transfer_for = ?", self.id, self.id)
            .uniq
  end
  
  def active_contacts_courses
    contacts_courses.includes(:course_register)
          .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status LIKE ?", "%[active]%")
          .uniq
  end
  
  def active_contacts
    contacts.includes(:contacts_courses).joins("LEFT JOIN course_registers ON course_registers.id = contacts_courses.course_register_id")
          .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status LIKE ?", "%[active]%")
          .uniq
  end
  
  def active_transfers
    Transfer.active_transfers.where(course_id: self.id)
  end
  
  def self.all_courses
    self.active_courses.order("created_at DESC")
  end
  
  def self.full_text_search(q, params=nil)
    result = self.main_courses.order("upfront DESC, courses.intake DESC")
    if !params.nil?
      if params[:student_id].present?
        contact = Contact.find(params[:student_id])
        learned_course_ids = contact.learned_courses.map{|c| c.id}
        
        result = result.where.not(id: learned_course_ids)
      end      
    end
    
    result = result.search(q).limit(50).map {|model| {:id => model.id, :text => model.display_name} }
  end
  
  def course_exist
    return false if draft?
    
    exist = Course.main_courses.where("upfront = ? AND course_type_id = ? AND subject_id = ? AND EXTRACT(YEAR FROM courses.intake) = ? AND EXTRACT(MONTH FROM courses.intake) = ?",
                          self.upfront, self.course_type_id, self.subject_id, self.intake.year, self.intake.month
                        )
    
    if self.id.nil? && exist.length > 0
      errors.add(:base, "Course exists")
    end
    
  end
  
  def self.filters(params, user, active=false)
    if active
      @records = self.active_courses.joins(:course_type,:subject)
    else
      @records = self.main_courses.joins(:course_type,:subject)
    end
    
    
    
    #@records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    @records = @records.where("LOWER(course_types.short_name) LIKE ? OR LOWER(subjects.name) LIKE ?", "%#{params["search"]["value"].downcase}%", "%#{params["search"]["value"].downcase}%") if !params["search"]["value"].empty?
    @records = @records.where("EXTRACT(YEAR FROM courses.intake) = ? ", params["intake_year"]) if params["intake_year"].present?
    @records = @records.where("EXTRACT(MONTH FROM courses.intake) = ? ", params["intake_month"]) if params["intake_month"].present?
    @records = @records.where("courses.course_type_id IN (#{params["course_types"].join(",")})") if params["course_types"].present?
    @records = @records.where("courses.subject_id IN (#{params["subjects"].join(",")})") if params["subjects"].present?
    
    if params["students"].present?
      @records = @records.includes(:contacts)
      @records = @records.where("contacts.id IN (#{params["students"]})") if params["students"].present?
    end
    
    if params["lecturers"].present?
      @records = @records.where("courses.lecturer_id IN (#{params["lecturers"]})") if params["lecturers"].present?
    end
    
    
    ########## BEGIN REVISION-FEATURE #########################
    
    if params[:status].present?
      if params[:status] == "pending"
        @records = @records.where("courses.status LIKE ?","%_pending]%")
      elsif params[:status] == "approved" # for approved
        @records = @records.where("courses.annoucing_user_ids LIKE ?", "%[#{user.id}%]")
      else
        @records = @records.where("courses.status LIKE ?","%[#{params[:status]}]%")
      end
    end    

    ########## END REVISION-FEATURE #########################
    
    if params["for_exam_year"].present?
      @records = @records.where(for_exam_year: params["for_exam_year"])
    end
    
    if params["for_exam_month"].present?
      @records = @records.where(for_exam_month: params["for_exam_month"])
    end
    
    
    return @records
  end
  
  def self.datatable(params, user)
    @records =  self.filters(params, user)
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "0"
        order = "courses.intake #{params["order"]["0"]["dir"]}, course_types.short_name, subjects.name"
      when "1"
        order = "course_types.short_name #{params["order"]["0"]["dir"]}, subjects.name"
      when "3"
        order = "courses.for_exam_year #{params["order"]["0"]["dir"]}, courses.for_exam_month #{params["order"]["0"]["dir"]}"
      when "7"
        order = "courses.created_at"
      else
        order = "courses.created_at"
      end
      order += " "+params["order"]["0"]["dir"] if !["0","1","3"].include?(params["order"]["0"]["column"])
    else
      order = "courses.intake DESC, course_types.short_name, subjects.name"
    end
    
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 10
    @records.each do |item|
      ############### BEGIN REVISION #########################
      # update approved status
      if params[:status].present? && params[:status] == "approved"
        item.remove_annoucing_users([user])
      end
      ############### END REVISION #########################
      
      item = [
              '<div class="text-left nowrap">'+item.display_intake+"</div>",
              '<div class="text-left nowrap">'+item.program_paper_name+"</div>",
              '<div class="text-left">'+item.courses_phrase_list+"</div>",
              '<div class="text-center nowrap">'+item.display_for_exam+"</div>",
              '<div class="text-center nowrap">'+item.display_lecturer+"</div>",
              '<div class="text-right">'+item.display_prices+"</div>",
              '<div class="text-center">'+item.student_count_link+"</div>",              
              '<div class="text-center">'+item.created_at.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-center">'+item.user.staff_col+"</div>",
              '<div class="text-center">'+item.display_statuses+"</div>",
              "", 
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
  
  def display_for_exam
    return "" if upfront
    mn = for_exam_month.to_i == 0 ? for_exam_month.to_s : Date::MONTHNAMES[for_exam_month.to_i]    
    mn+"-"+for_exam_year.to_s
  end
  
  def self.student_courses(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    
    @student = Contact.find(params[:students])
    
    @records =  @student.active_courses_with_phrases
    @records = @records.sort {|a, b| b[:course].intake <=> a[:course].intake}
    
    total = @records.count
    
    data = []
    actions_col = 6

    @records.each do |item|
      itemz = [
              '<div class="text-left nowrap">'+item[:course].display_intake+"</div>",
              '<div class="text-left nowrap">'+item[:course].program_paper_name+"</div>",
              '<div class="text-left">'+@student.display_active_course(item[:course].id)+"</div>",
              '<div class="text-center">'+item[:course].display_for_exam+"</div>",
              '<div class="text-center nowrap">'+item[:course].display_lecturer+"</div>",             
              '<div class="text-center">'+item[:course].created_at.strftime("%d-%b-%Y")+"</div>",              
              "", 
            ]     

        data << itemz
    end
    
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    return {result: result, items: @records, actions_col: actions_col}
    
  end
  
  
  
  def self.render_courses_phrase_list(list, contacts_course = nil)
    arr = []
    group_name = ""
    list.each do |p|
        if group_name != p.phrase.name
          arr << "<div><strong class=\"width100 phrase_title\" rel=\"phrase_date_#{p.course_id}_#{p.phrase.id}\">#{p.phrase.name} <span class=\"phrase_date_#{p.course_id}_#{p.phrase.id}\">[<i class=\"icon-ellipsis-horizontal\"></i>]</span></strong></div>"
          group_name = p.phrase.name
        end
        
        if contacts_course.present?
          transferred = !p.transferred?(contacts_course) ? "" : "transferred"
        end
        arr << "<span style=\"display:none\" class=\"#{transferred} phrase_date_#{p.course_id}_#{p.phrase.id}\" title=\"#{transferred}\">[#{p.start_at.strftime("%d-%b-%Y") if p.start_at.present?}]</span> "
    end
    return "<div>"+arr.join("").html_safe+"</div>"
  end
  
  def ordered_courses_phrases
    courses_phrases.joins(:phrase).order("phrases.id, courses_phrases.start_at")
  end
  
  def courses_phrase_list
    Course.render_courses_phrase_list(ordered_courses_phrases)
  end
  
  def courses_phrase_list_by_sudent(student)
    Course.render_courses_phrase_list(ordered_courses_phrases)    
  end
  
  def courses_phrases_by_student(student)
    ccs = contacts_courses_by_student(student)
    if !ccs.empty?
      ids = []
      ccs.each do |cc|
        cc.courses_phrases.each do |cp|
          ids << cp.id
        end
      end
      return CoursesPhrase.where(id: ids)
    else
      return []
    end
  end
  
  def contacts_course(student)
    active_contacts_courses.where(contact_id: student.id).first
  end
  
  def contacts_courses_by_student(student)
    active_contacts_courses.where(contact_id: student.id)
  end
  
  def course_register(student)
    CourseRegister.find(contacts_course(student).course_register_id)
  end
  
  def course_registers_by_student(student)
    CourseRegister.main_course_registers.where(id: (contacts_courses_by_student(student).map {|cc| cc.course_register_id}))
  end
  
  def list_course_registers_by_student(student)
    (course_registers_by_student(student).map {|cr| cr.course_register_link}).join("<br />").html_safe
  end
  
  
  def display_name
    display_intake.to_s+"-"+program_paper_name.to_s
  end
  
  def display_lecturer
    !lecturer.nil? ? lecturer.contact_link : ""
  end
  
  def name
    display_intake+"-"+course_type.short_name+"-"+subject.name
  end
  
  def display_intake
    upfront ? "Upfront" : intake.strftime("%b")+"-"+intake.year.to_s
  end
  
  def update_program_paper(sid)
    return false if sid.nil?
    
    ct = CourseType.find(sid.split("_")[0])
    sj = Subject.find(sid.split("_")[1])
    
    if !ct.nil? && !sj.nil?
      self.course_type = ct
      self.subject = sj
    end
    
  end
  
  def program_paper_id
    "#{course_type.id}_#{subject.id}" if course_type.present? && subject.present?
  end
  
  def program_paper_name
    "#{course_type.short_name}-#{subject.name}" if course_type.present? && subject.present?
  end
  
  def student_list_link(title=nil)
    title = title.nil? ? "Student List (#{contacts.count.to_s})" : title
    ActionController::Base.helpers.link_to(title, {controller: "courses", action: "edit", id: id, tab_page: 1, tab: "student"}, title: "#{display_name}: Student List", class: "tab_page")
  end
  
  def student_count_link
    student_list_link("["+contacts.count.to_s+"]")
  end
  
  def course_link(title=nil, psrc=nil)
    title = title.nil? ? name : title
    ActionController::Base.helpers.link_to(title, {controller: "courses", action: "edit", id: id, tab_page: 1}, psrc: psrc, title: name, class: "tab_page")
  end
  
  def update_courses_phrases(params)
    courses_phrases.destroy_all
    params.each do |row|
      if row[1]["phrase_id"].present?
        courses_phrases.create(phrase_id: row[1]["phrase_id"],
                        start_at: row[1]["start_at"],
                        hour: row[1]["hour"]
                    )
      end
    end
  end
  
  def course_price
    course_prices.order("created_at DESC").first
  end
  
  def prices
    course_prices.where("course_prices.deadline IS NULL OR course_prices.deadline >= ?", Time.now.beginning_of_day)
  end
  
  def display_prices
    a = prices.map {|p| ApplicationController.helpers.format_price(p.amount)+("<br />(#{p.deadline.strftime("%d-%b-%Y")})".html_safe if p.deadline.present?)}
    return a.join("<br />")
  end
  
  def update_price(new_price)
    if course_price.nil?
      new_price.save
    else
      if course_price.prices != new_price.prices
        new_price.save
      end      
    end
  end
  
  def update_course_prices(params)
    course_prices.destroy_all
    params.each do |row|
      if row[1]["amount"].present?
        course_prices.create(
                        amount: row[1]["amount"],
                        deadline: row[1]["deadline"]
                      )
      end
    end
  end
  
  
  
  ############### BEGIN REVISION #########################
  
  def self.main_courses
    self.where(parent_id: nil)
  end
  def self.active_courses(filter=nil)
    result = self.main_courses.where("status IS NOT NULL AND status LIKE ?", "%[active]%")
    if !filter.nil?
      if filter[:course_type_id].present?
        result = result.where(course_type_id: filter[:course_type_id])
      end
      if filter[:subject_id].present?
        result = result.where(subject_id: filter[:subject_id])
      end
      if !filter[:upfront].nil?
        result = result.where(upfront: filter[:upfront])
      end
    end    
    return result
  end
  
  def draft?
    !parent.nil?
  end
  
  def update_status(action, user, older = nil)
    statuses = []
    
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
    
    cps = []
    self.courses_phrases.each do |cp|
      draft.courses_phrases << cp.dup
    end
    
    cps = []
    self.course_prices.each do |cp|
      draft.course_prices << cp.dup
    end
    
    draft.save
    
    return draft
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
    
    if type == "program_paper"
      drafts = drafts.select {|u| u.course_type_id != self.course_type_id || u.subject_id != self.subject_id}
    elsif type == "for_exam"
      drafts = drafts.select{|c| c.for_exam_year != self.for_exam_year || c.for_exam_month != self.for_exam_month}
    elsif type == "course_price"
      drafts = drafts.select{|c| self.course_price.prices != c.course_price.prices}
    elsif type == "phrases"
      
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
  
  
  def self.months_with_CBE
    months = [""]
    (1..12).each do |m|
      months << m
    end
    months += ["CBE_1H","CBE_2H"]
  end
  
  def total_hour
    courses_phrases.sum(:hour)
  end
  
end
