class DiscountProgram < ActiveRecord::Base
  include PgSearch
  
  validates :name, :presence => true
  
  belongs_to :user
  
  has_many :course_registers
  has_many :contacts_courses
  has_many :books_contacts
  has_and_belongs_to_many :course_types
  
  ########## BEGIN REVISION ###############
  validate :check_exist
  
  has_many :drafts, :class_name => "DiscountProgram", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "DiscountProgram", :foreign_key => "parent_id"  
  has_one :current, -> { order created_at: :desc }, class_name: 'DiscountProgram', foreign_key: "parent_id"
  ########## END REVISION ###############
  
  pg_search_scope :search,
                  against: [:name, :rate, :description],
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
  
  def self.full_text_search(q, course_type_id=nil)
    result = self.active_discount_programs
    
    #if course_type_id.present?
    #  result = result.includes(:course_types).where(course_types: {id: course_type_id})
    #end    
    
    result = result.order("discount_programs.name").search(q).limit(50).map {|model| {:id => model.id, :text => model.display_name} }
  end
  
  def display_name
    "[#{self.display_rate}] " + self.name
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.main_discount_programs
    
    ########## BEGIN REVISION-FEATURE #########################
    
    if params[:status].present?
      if params[:status] == "pending"
        @records = @records.where("discount_programs.status LIKE ?","%_pending]%")
      elsif params[:status] == "approved" # for approved
        @records = @records.where("discount_programs.annoucing_user_ids LIKE ?", "%[#{user.id}%]")
      else
        @records = @records.where("discount_programs.status LIKE ?","%[#{params[:status]}]%")
      end
    end    
    
    if !params[:status].present? || params[:status] != "deleted"
      @records = @records.where("discount_programs.status NOT LIKE ?","%[deleted]%")
    end
    
    ########## END REVISION-FEATURE #########################
    
    if params["course_types"].present? && params["search"]["value"].empty?
      @records = @records.joins(:course_types)
      @records = @records.where("course_types.id IN (#{params["course_types"].join(",")})")
    end
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "0"
        order = "discount_programs.name"
      when "3"
        order = "discount_programs.rate"
      when "4"
        order = "discount_programs.start_at"
      when "5"
        order = "discount_programs.end_at"
      else
        order = "discount_programs.start_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "discount_programs.start_at"
    end
    
    @records = @records.order(order) if !order.nil?
    
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
              item.name,
              item.description,
              '<div class="text-center">'+item.programs_name+"</div>",
              '<div class="text-center">'+item.display_rate+"</div>",
              '<div class="text-center">'+item.start_at.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-center">'+item.end_at.strftime("%d-%b-%Y")+"</div>",              
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
  
  def programs_name
    course_types.map(&:short_name).join(", ")
  end
  
  def display_rate
    result = ApplicationController.helpers.format_price(rate).to_s
    result += " "+rate_unit.to_s
    
    return result
  end
  
  def rate_unit
    if type_name == "percent"
      return "%"
    elsif type_name == "amount"
      return Setting.get("currency_code")
    end
  end
  
  def rate=(new)
    self[:rate] = new.to_s.gsub(/\,/, '')
  end
  
  ############### BEGIN REVISION #########################
  
  def check_exist
    return false if draft?
    
    exist = DiscountProgram.main_discount_programs.where("discount_programs.status NOT LIKE ?", "%[deleted]%").where("name = ?",
                          self.name
                        )
    
    if self.id.nil? && exist.length > 0
      errors.add(:base, "Discount Program exists")
    end
    
  end
  
  def self.main_discount_programs
    self.where(parent_id: nil)
  end
  def self.active_discount_programs(course_type_id=nil)
    result = self.main_discount_programs.where("discount_programs.status IS NOT NULL AND discount_programs.status LIKE ?", "%[active]%")
        .where("start_at <= ? AND end_at >= ?", Time.now.end_of_day, Time.now.beginning_of_day)
    if course_type_id.present?
      result = result.includes(:course_types).where(course_types: {id: course_type_id})
    end
    return result
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
    
    draft.course_types = self.course_types
    
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
      drafts = drafts.where("created_at >= ?", self.created_at)
    else
      drafts = self.drafts
      
      drafts = drafts.where("created_at <= ?", self.current.created_at) if self.current.present?    
      drafts = drafts.where("created_at >= ?", self.active_older.created_at) if !self.active_older.nil?    
      drafts = drafts.order("created_at")
    end
    
    #if type == "course_type"
    #  drafts = drafts.select{|c| c.course_types.order("short_name").map(&:short_name).join("") != self.course_types.order("short_name").map(&:short_name).join("")}
    #else
    #  value = value.nil? ? self[type] : value
    #  drafts = drafts.where("#{type} IS NOT NUll AND #{type} != ?", value)
    #end
    
    arr = []
    value = "-1"
    drafts.each do |c|
      if type == "course_type"
        arr << c if c.course_types.order("short_name").map(&:short_name).join("") != value
        value = c.course_types.order("short_name").map(&:short_name).join("")
      else
        arr << c if !c[type].nil? && c[type] != value
        value = c[type]
      end      
    end
    
    return (arr.count > 1) ? arr : []
    
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
  
  def json_encode_course_type_ids_names
    json = course_types.map {|t| {id: t.id.to_s, text: t.short_name}}
    json.to_json
  end
  
end
