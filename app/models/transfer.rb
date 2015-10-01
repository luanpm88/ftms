class Transfer < ActiveRecord::Base
  include PgSearch
  
  belongs_to :contact
  belongs_to :user
  belongs_to :course
  belongs_to :to_course, class_name: "Course"
  belongs_to :to_contact, class_name: "Contact"
  
  belongs_to :transferred_contact, class_name: "Contact", foreign_key: "transfer_for"
  
  has_many :transfer_details, :dependent => :destroy
  has_many :payment_records, :dependent => :destroy
  
  ########## BEGIN REVISION ###############
  validate :check_exist
  
  has_many :drafts, :class_name => "Transfer", :foreign_key => "parent_id", :dependent => :destroy
  belongs_to :parent, :class_name => "Transfer", :foreign_key => "parent_id"  
  has_one :current, -> { order created_at: :desc }, class_name: 'Transfer', foreign_key: "parent_id"
  ########## END REVISION ###############
  
  after_create :update_statuses
  after_update :update_contact_info
  after_create :update_cache_search
  
  pg_search_scope :search,
                  against: [:money, :cache_search],
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
  
  def update_contact_info
    self.contact.update_info
    self.to_contact.update_info
  end
  
  def all_payment_records
    payment_records.where(status: 1).order("payment_date DESC, payment_records.created_at DESC")
  end
  
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
    
    if !params[:status].present? || params[:status] != "deleted"
      @records = @records.where("transfers.status NOT LIKE ?","%[deleted]%")
    end
   
    ########## END REVISION-FEATURE #########################
    
    if params["from_date"].present?
      @records = @records.where("transfers.created_at >= ?", params["from_date"].to_datetime.beginning_of_day)
    end
    if params["to_date"].present?
      @records = @records.where("transfers.created_at <= ?", params["to_date"].to_datetime.end_of_day)
    end
    
    if params["from_contact"].present?
      @records = @records.where(contact_id: params["from_contact"])
    end
    if params["to_contact"].present?
      @records = @records.where(to_contact_id: params["to_contact"])
    end
    
    if params["contact"].present?
      @records = @records.where("to_contact_id = ? OR contact_id = ?", params["contact"], params["contact"])
    end
    
    if params["payment_statuses"].present?
      @records = @records.where("cache_payment_status LIKE ?", "%"+params["payment_statuses"]+"%")
    end
    
    return @records
  end
  
  def self.datatable(params, user)
    @records = self.filter(params, user)
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "7"
      else
        order = "transfers.created_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "transfers.created_at DESC"
    end
    
    @records = @records.order(order) if !order.nil?
    
    
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
      
      # sign = params["contact"].present? && params["contact"].to_i == item.transferred_contact.id ? "+" : ""
      item = [
              '<div class="text-center">'+item.contact.contact_link+"</div>",
              '<div class="text-center">'+item.to_contact.contact_link+"</div>",              
              '<div class="text-left">'+item.diplay_from_course+"</div>",
              '<div class="text-left">'+item.diplay_to_course+"</div>",
              '<div class="text-center">'+item.display_hour+"</div>",
              '<div class="text-right">'+item.display_money+"</div>",
              '<div class="text-right"><label class="col_label top0">Total:</label>'+ApplicationController.helpers.format_price(item.total)+"<label class=\"col_label top0\">Paid:</label>"+ApplicationController.helpers.format_price(item.paid)+"<label class=\"col_label top0\">Receivable:</label>"+ApplicationController.helpers.format_price(item.remain)+"</div>",
              #'<div class="text-right">'+ApplicationController.helpers.format_price(item.admin_fee.to_f)+"</div>",              
              '<div class="text-center">'+item.created_at.strftime("%d-%b-%Y <br/> %I:%M %p").html_safe+"</div>",
              '<div class="text-center">'+item.display_statuses+"<br /><br />"+item.display_payment_status+"</div>",
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
  
  def courses_phrases
    return [] if courses_phrase_ids.nil?
    ids = self.courses_phrase_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
    return CoursesPhrase.where(id: ids)
  end
  
  def to_courses_phrases
    return [] if to_courses_phrase_ids.nil?
    ids = self.to_courses_phrase_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
    return CoursesPhrase.where(id: ids)
  end
  
  def diplay_from_course
    if !course.nil?
      arr = []
      arr << "<div class=\"nowrap\"><strong>"+course.display_name+"</strong></div>"
      arr << "<div class=\"courses_phrases_list\">"+Course.render_courses_phrase_list(courses_phrases)+"</div>" if courses_phrases
      arr << "<br /><div>Hour: <strong>#{contact.active_course(course.id, self.created_at-1.second)[:hour]}</strong> <br /> Money: <strong>#{ApplicationController.helpers.format_price(contact.active_course(course.id, self.created_at-1.second)[:money])}</trong></div>"
      return arr.join("")
    elsif !from_hour.nil?
      arr = []
      JSON.parse(from_hour).each do |r|
        arr << CourseType.find(r[0].split("-")[0]).short_name+"-"+Subject.find(r[0].split("-")[1]).name+": "+r[1].to_s+" hours" if r[1].to_f > 0
      end
      return "<strong>"+arr.join("<br />")+"</strong>"
    else
      ""
    end
  end
  
  def diplay_to_course
    if to_type == "course"
      if !to_course.nil?
        arr = []
        arr << "<div class=\"nowrap\"><strong>"+to_course.display_name+"</strong></div>"
        arr << "<div class=\"courses_phrases_list\">"+Course.render_courses_phrase_list(to_courses_phrases)+"</div>" if to_courses_phrases
        arr << "<br /><div>Hour: <strong>#{to_course_hour}</strong> <br /> Money: <strong>#{ApplicationController.helpers.format_price(to_course_money)}</trong></div>"
        return arr.join("")
      else
        "N/A"
      end
    else
      "N/A"
    end
  end
  
  def display_hour
    if to_type == "hour"
      hour.to_f.to_s
    else
      "N/A"
    end
  end
  
  def display_money
    if to_type == "money"
      ApplicationController.helpers.format_price(money.to_f)
    else
      "N/A"
    end
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
  
  def to_course_hour=(new)
    self[:to_course_hour] = new.to_s.gsub(/\,/, '')
  end
  
  def to_course_money=(new)
    self[:to_course_money] = new.to_s.gsub(/\,/, '')
  end
  
  def hour=(new)
    self[:hour] = new.to_s.gsub(/\,/, '')
  end
  def hour_money=(new)
    self[:hour_money] = new.to_s.gsub(/\,/, '')
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
  
  def last_payment
    all_payment_records.order("payment_date DESC, created_at DESC").first
  end
  
  def real_debt_date
    if !last_payment.nil?
      self.last_payment.debt_date
    else
      self.created_at
    end
  end
  
  def out_of_date?
    return false if paid?
    
    return real_debt_date.nil? ? false : real_debt_date < Time.now
  end
  
  def total
    admin_fee
  end
  
  def paid(from_date=nil, to_date=nil)
    total = all_payment_records
    if from_date.present?
      total = total.where("payment_records.payment_date >= ?", @from_date.beginning_of_day)
    end
    if to_date.present?
      total = total.where("payment_records.payment_date <= ? ", @to_date.end_of_day)
    end
    
    total = total.sum(:amount)
    
    return total
  end
  
  def remain(from_date=nil, to_date=nil)
    total - paid(from_date=nil, to_date=nil)
  end
  
  def paid?
    paid == total
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
  
  def update_statuses
    # payment
    self.update_attribute(:cache_payment_status, self.payment_status.join(","))
  end
  
  def display_payment_status
    line = []
    payment_status.each do |s|
      line << "<div class=\"#{s} text-center\">#{s}</div>".html_safe
    end
    
    return line.join("")
  end
  
  def update_cache_search
    return false if !self.parent_id.nil?
    
    str = []
    str << contact.display_name
    str << contact.display_name.unaccent
    str << to_contact.display_name
    str << to_contact.display_name.unaccent
    str << diplay_from_course
    str << diplay_to_course
    str << display_hour
    str << display_money
    str << total.to_s
    str << paid.to_s
    str << remain.to_s
    str << display_statuses
    str << display_payment_status
    
    update_attribute(:cache_search, str.join(" "))
  end
  
  
end
