class StockType < ActiveRecord::Base
  include PgSearch
  validates :name, :presence => true
  
  has_many :books
  belongs_to :user
  
  ########## BEGIN REVISION ###############
  validate :check_exist
  
  has_many :drafts, :class_name => "StockType", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "StockType", :foreign_key => "parent_id"  
  has_one :current, -> { order created_at: :desc }, class_name: 'StockType', foreign_key: "parent_id"
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
                  
  def self.full_text_search(q)
    self.active_stock_types.order("stock_types.display_order").search(q).limit(50).map {|model| {:id => model.id, :text => model.name} }
  end
  
  def self.filter(params, user)
    @records = self.main_stock_types
    
    ########## BEGIN REVISION-FEATURE #########################
    
    if params[:status].present?
      if params[:status] == "pending"
        @records = @records.where("stock_types.status LIKE ?","%_pending]%")
      elsif params[:status] == "approved" # for approved
        @records = @records.where("stock_types.annoucing_user_ids LIKE ?", "%[#{user.id}%]")
      else
        @records = @records.where("stock_types.status LIKE ?","%[#{params[:status]}]%")
      end
    end
    
    if !params[:status].present? || params[:status] != "deleted"
      @records = @records.where("stock_types.status NOT LIKE ?","%[deleted]%")
    end
   
    ########## END REVISION-FEATURE #########################
    
    @records = @records.search(params["search"]["value"]) if params["search"].present? && !params["search"]["value"].empty?
    
    return @records
  end
                  
  def self.datatable(params, user)
    
    @records = self.filter(params, user)
    
    order = "stock_types.display_order"
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "stock_types.name"
      when "3"
        order = "stock_types.display_order"
      when "4"
        order = "stock_types.created_at"
      else
        order = "stock_types.name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "stock_types.display_order"
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
              "<div item_id=\"#{item.id.to_s}\" class=\"main_part_info checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
              item.name,
              item.description,
              "<div class=\"text-center\"><input type=\"text\" rel=\"#{item.id.to_s}\" class=\"display_order_input\" value=\"#{item.display_order}\" /></div>",
              '<div class="text-center">'+item.created_at.strftime("%Y-%m-%d")+"</div>",
              '<div class="text-center">'+item.staff_col+"</div>",
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
  
  def staff_col
    user.nil? ? "" : user.staff_col
  end

  
  ############### BEGIN REVISION #########################
  
  def check_exist
    return false if draft?
    
    exist = StockType.main_stock_types.where("stock_types.status NOT LIKE ?", "%[deleted]%").where("name = ?",
                          self.name
                        )
    
    if self.id.nil? && exist.length > 0
      errors.add(:base, "Stock type exists")
    end
    
  end
  
  def self.main_stock_types
    self.where(parent_id: nil)
  end
  def self.active_stock_types
    self.main_stock_types.where("stock_types.status IS NOT NULL AND stock_types.status LIKE ?", "%[active]%").order("stock_types.display_order")
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
    return "" if statuses.empty? || current.user.nil?
    result = statuses.map {|s| "<span title=\"Last updated: #{last_updated.created_at.strftime("%d-%b-%Y, %I:%M %p")}; By: #{last_updated.user.name}\" class=\"badge user-role badge-info contact-status #{s}\">#{s}</span>"}
    result.join(" ").html_safe
  end
  
  def last_updated
    return current if older.nil? or current.statuses.include?("new_pending") or current.statuses.include?("education_consultant_pending") or current.statuses.include?("update_pending") or current.statuses.include?("delete_pending")
    return older
  end
  
  def editor
    return last_updated.user
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
    current = drafts.order("created_at DESC").first
    current = self if current.nil?
    return current
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
