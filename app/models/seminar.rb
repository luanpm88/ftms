class Seminar < ActiveRecord::Base
  include PgSearch
  
  validates :name, presence: true
  validates :user_id, presence: true
  
  belongs_to :user
  belongs_to :course_type
  
  has_many :contacts_seminars, :dependent => :destroy
  has_and_belongs_to_many :contacts
  
  ########## BEGIN REVISION ###############
  validate :check_exist
  
  has_many :drafts, :class_name => "Seminar", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Seminar", :foreign_key => "parent_id"  
  has_one :current, -> { order created_at: :desc }, class_name: 'Seminar', foreign_key: "parent_id"
  ########## END REVISION ###############
  
  pg_search_scope :search,
                against: [:name, :description],
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def main_contacts
    contacts.where(draft_for: nil).where("contacts.status IS NOT NULL AND contacts.status NOT LIKE ?", "%[deleted]%")
  end
  
  def self.full_text_search(params)    
    records = self.active_seminars
    records = records.search(params[:q]) if params[:q].present?    
    records = records.order("name").limit(50).map {|model| {:id => model.id, :text => model.name} }
  end
  
  def self.filter(params, user)
    @records = self.main_seminars
    
    if params["contact_id"].present?
      sids = (Contact.find(params["contact_id"]).seminars.map(&:id) << "0").join(",")
      @records = @records.where("seminars.id IN (#{sids})")
    end
    
    if params["course_types"].present?
      @records = @records.where(course_type_id: params["course_types"])
    end
    
    ########## BEGIN REVISION-FEATURE #########################
    
    if params[:status].present?
      if params[:status] == "pending"
        @records = @records.where("seminars.status LIKE ?","%_pending]%")
      elsif params[:status] == "approved" # for approved
        @records = @records.where("seminars.annoucing_user_ids LIKE ?", "%[#{user.id}%]")
      else
        @records = @records.where("seminars.status LIKE ?","%[#{params[:status]}]%")
      end
    end
    
    if !params[:status].present? || params[:status] != "deleted"
      @records = @records.where("seminars.status NOT LIKE ?","%[deleted]%")
    end
   
    ########## END REVISION-FEATURE #########################
    
     @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
     
     
    
    @records = @records.where("course_type_id IN (#{params["course_types"].join(",")})") if params["course_types"].present?
    
    return @records
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    
    @records = self.filter(params, user)
      
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "seminars.name"
      else
        order = "seminars.name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "seminars.created_at"
    end
    @records = @records.order(order) if !order.nil?
    

    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 7
    @records.each do |item|
      ############### BEGIN REVISION #########################
      # update approved status
      if params[:status].present? && params[:status] == "approved"
        item.remove_annoucing_users([user])
      end
      ############### END REVISION #########################
      
      item = [
              item.seminar_link,
              item.description,
              '<div class="text-center">'+item.course_type_name+"</div>",
              '<div class="text-center">'+item.contact_count_link+"</div>",
              '<div class="text-center">'+item.display_start_at+"</div>",
              '<div class="text-center">'+item.user.staff_col+"</div>",
              '<div class="text-center">'+item.display_statuses+"</div>",              
              ''
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
  
  def self.student_seminars(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    
    @records = self.filter(params, user)
    
    student = Contact.find(params["contact_id"])
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "seminars.name"
      else
        order = "seminars.name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "seminars.created_at"
    end
    @records = @records.order(order) if !order.nil?
    

    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 7
    @records.each do |item|
      ############### BEGIN REVISION #########################
      # update approved status
      if params[:status].present? && params[:status] == "approved"
        item.remove_annoucing_users([user])
      end
      ############### END REVISION #########################
      
      item = [
              item.seminar_link,
              item.description,
              '<div class="text-center">'+item.course_type_name+"</div>",
              '<div class="text-center">'+item.contact_count_link+"</div>",
              '<div class="text-center">'+item.display_start_at+"</div>",
              '<div class="text-center">'+item.user.staff_col+"</div>",
              '<div class="text-center">'+student.display_present_with_seminar(item, false)+"</div>",              
              ''
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
  
  def course_type_name
    course_type.nil? ? "" : course_type.short_name
  end
  
  def display_start_at
    start_at.nil? ? "" : start_at.strftime("%d-%b-%Y %I:%M %p")
  end
  
  def contact_list_link(title=nil)
    title = title.nil? ? "Attendance List (#{contacts.count.to_s})" : title
    ActionController::Base.helpers.link_to(title, {controller: "seminars", action: "edit", id: id, tab_page: 1, tab: "attendance"}, title: name, class: "tab_page")
  end
  
  def contact_count_link
    contact_list_link("["+contacts.count.to_s+"]")
  end
  
  def seminar_link(title=nil)
    title = title.nil? ? self.name : title
    ActionController::Base.helpers.link_to(title, {controller: "seminars", action: "edit", id: id, tab_page: 1}, title: name, class: "tab_page")
  end
  
  def add_contacts(contact_ids)
    Contact.where(id: contact_ids).each do |contact|
      self.contacts << contact unless self.contacts.include?(contact)
    end
    self.save
  end
  
  def remove_contacts(contact_ids)
    Contact.where(id: contact_ids).each do |contact|
      self.contacts.delete(contact) if self.contacts.include?(contact)
    end
    self.save
  end
  
  def json_encode_ids_names
    json = [{id: id, text: name}]
    json.to_json
  end
  
  def render_list(file, user)
    list = []
    
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      
      # Background: "University: #{row["University"]}\nMajor: #{row["Major"]}\nYear: #{row["Year"]}"
      bg = "Imported Date: #{Time.now.strftime("%d-%b-%Y")}\n"
      bg += "Creator: #{user.name.to_s}\n"
      bg += "University: #{row["University"].to_s.strip}\n" if row["University"].present?
      bg += "Major: #{row["Major"].to_s.strip}\n" if row["Major"].present?
      bg += "Major: #{row["Major "].to_s.strip}\n" if row["Major "].present?
      bg += "Year: #{row["Year"].to_s.strip}\n" if row["Year"].present?
      
      item = {name: row["Fullname"], company: row["Company"], mobile: row["Mobile"], email: row["Email"], present: row["Status"], background: bg}
      item[:contacts] = similar_contacts({email: item[:email], name: item[:name], mobile: item[:mobile]})
      list << item if row["Fullname"].present?
    end
    
    return list
  end
  
  def process_rendered_list(list)
    new_count = 0
    old_count = 0
    waiting_count = 0
    
    new_list = []
    list.each do |row|
      if !row[:contacts].empty?
        row[:status] = "not_sure"
        row[:contacts].each do |contact|
          if row[:name].strip.downcase == contact.name.downcase && row[:email].strip.downcase == contact.email.downcase && Contact.format_mobile(row[:mobile]) == contact.mobile
            row[:selected_id] = contact.id
            
            row[:status] = "old_imported"
            
            old_count += 1
            break
          end        
        end
        
        waiting_count += 1 if row[:status] == "not_sure"
      else
        row[:status] = "new_imported"
        new_count += 1
      end
      
        
      new_list << row
    end
    return { list: new_list,
              new_count: new_count,
              old_count: old_count,
              waiting_count: waiting_count,
              total: new_count+old_count+waiting_count
    }
              
  end
  
  def similar_contacts(data={})
    result = []
    if data[:email].present?
      result += Contact.main_contacts.where("LOWER(email) = ? OR LOWER(name) = ? OR LOWER(mobile) = ?", data[:email].strip.downcase, data[:name].to_s.strip.downcase, Contact.format_mobile(data[:mobile].to_s))
    end
    
    return result
  end
  
  ############### BEGIN REVISION #########################
  
  def check_exist
    return false if draft?
    
    exist = Seminar.main_seminars.where("seminars.status NOT LIKE ?", "%[deleted]%").where("name = ?",
                          self.name
                        )
    
    if self.id.nil? && exist.length > 0
      errors.add(:base, "Seminar exists")
    end
    
  end
  
  def self.main_seminars
    self.where(parent_id: nil)
  end
  def self.active_seminars
    self.main_seminars.where("status IS NOT NULL AND status LIKE ?", "%[active]%")
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
    
    if false
    else
      value = value.nil? ? self[type] : value
      drafts = drafts.where("#{type} IS NOT NUll")
    end
    
    arr = []
    value = "-1"
    drafts.each do |c|
      arr << c if c[type] != value
      value = c[type]
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
  
end
