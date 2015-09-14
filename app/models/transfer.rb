class Transfer < ActiveRecord::Base
  include PgSearch
  
  belongs_to :contact
  belongs_to :user
  
  
  belongs_to :transferred_contact, class_name: "Contact", foreign_key: "transfer_for"
  
  has_many :transfer_details, :dependent => :destroy
  
  ########## BEGIN REVISION ###############
  validate :check_exist
  
  has_many :drafts, :class_name => "Transfer", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Transfer", :foreign_key => "parent_id"  
  has_one :current, -> { order created_at: :desc }, class_name: 'Transfer', foreign_key: "parent_id"
  ########## END REVISION ###############
  
  pg_search_scope :search,
                  against: [:money],
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
  
  def self.filter(params, user)
    @records = self.main_transfers
    
    ########## BEGIN REVISION-FEATURE #########################
    
    if params[:status].present?
      if params[:status] == "pending"
        @records = @records.where("transfers.status LIKE ?","%_pending]%")
      elsif params[:status] == "approved" # for approved
        @records = @records.where("transfers.annoucing_user_ids LIKE ?", "%[#{user.id}%]")
      else
        @records = @records.where("transfers.status LIKE ?","%[#{params[:status]}]%")
      end
    end    
   
    ########## END REVISION-FEATURE #########################
    
    if params["from_date"].present?
      @records = @records.where("transfers.transfer_date >= ?", params["from_date"].to_datetime.beginning_of_day)
    end
    if params["to_date"].present?
      @records = @records.where("transfers.transfer_date <= ?", params["to_date"].to_datetime.end_of_day)
    end
    
    if params["from_contact"].present?
      @records = @records.where(contact_id: params["from_contact"])
    end
    if params["to_contact"].present?
      @records = @records.where(transfer_for: params["to_contact"])
    end
    
    if params["contact"].present?
      @records = @records.where("transfer_for = ? OR contact_id = ?", params["contact"], params["contact"])
    end
    
    return @records
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.filter(params, user)
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "6"
        order = "transfers.transfer_date"
      else
        order = "transfers.transfer_date"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "transfers.transfer_date"
    end
    
    @records = @records.order(order) if !order.nil?
    
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 11
    
    
    @records.each do |item|
      ############### BEGIN REVISION #########################
      # update approved status
      if params[:status].present? && params[:status] == "approved"
        item.remove_annoucing_users([user])
      end
      ############### END REVISION #########################
      
      sign = params["contact"].present? && params["contact"].to_i == item.transferred_contact.id ? "+" : ""
      item = [
              '<div class="text-center">'+item.contact.contact_link+"</div>",
              '<div class="text-center">'+item.transferred_contact.contact_link+"</div>",              
              '<div class="text-left">'+item.transfer_date.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-left">'+item.description+"</div>",
              '<div class="text-center">'+sign.to_s+item.hour.to_s+"</div>",
              '<div class="text-right">'+sign.to_s+ApplicationController.helpers.format_price(item.money)+"</div>",
              '<div class="text-right">'+sign.to_s+ApplicationController.helpers.format_price(item.admin_fee.to_f)+"</div>",
              '<div class="text-right">'+sign.to_s+ApplicationController.helpers.format_price(item.total)+"</div>",
              '<div class="text-center">'+item.created_at.strftime("%d-%b-%Y <br/> %I:%M %p").html_safe+"</div>",
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
  
  def total
    money - admin_fee.to_f
  end
  
  def money=(new)
    self[:money] = new.to_s.gsub(/\,/, '')
  end
  def admin_fee=(new)
    self[:admin_fee] = new.to_s.gsub(/\,/, '')
  end
  
  def description
    arr = []
    transfer_details.each do |td|      
      arr << "<div><strong>"+td.contacts_course.course.display_name+"</strong></div>"
      arr << "<div class=\"courses_phrases_list\">"+Course.render_courses_phrase_list(td.courses_phrases)+"</div>"
    end
    return "<div>"+arr.join("").html_safe+"</div></div>"
  end
  
  def update_transfer_details(params)
    params.each do |row|
      cc = ContactsCourse.find(row[0])
      if cc.present? && row[1]["courses_phrase_ids"].present?
        pd = self.transfer_details.new
        pd.courses_phrase_ids = row[1]["courses_phrase_ids"]
        pd.contacts_course_id = row[0]
      end
    end

  end
  
  ############### BEGIN REVISION #########################
  
  def check_exist
    return false
  
    #return false if draft?
    #
    #exist = Transfer.main_transfers.where("short_name = ? OR name = ?",
    #                      self.short_name, self.name
    #                    )
    #
    #if self.id.nil? && exist.length > 0
    #  errors.add(:base, "Transfer exists")
    #end
    
  end
  
  def self.main_transfers
    self.where(parent_id: nil)
  end
  def self.active_transfers
    self.main_transfers.where("status IS NOT NULL AND status LIKE ?", "%[active]%")
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
    
    self.transfer_details.each do |td|
      draft.transfer_details << td.dup
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
  
  
end
