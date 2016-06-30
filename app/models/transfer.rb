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
  after_create :enable_report
  
  
  pg_search_scope :search,
                  against: [:money, :cache_search],
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
                  
  def enable_report
    self.to_course.remove_no_report_contact(self.to_contact) if !self.to_course.nil?
  end
  
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
    
    if params["user"].present?
      @records = @records.where("transfers.user_id = ?", params["user"])
    end
    
    #@records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    @records = @records.where("LOWER(transfers.cache_search) LIKE ?", "%#{params["search"]["value"].strip.downcase}%") if params["search"].present? && !params["search"]["value"].empty?
    
    return @records
  end
  
  def self.datatable(params, user)
    @records = self.filter(params, user)
    
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "8"
        order = "transfers.created_at"
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
    
    actions_col = 10
    
    
    @records.each do |item|
      ############### BEGIN REVISION #########################
      # update approved status
      if params[:status].present? && params[:status] == "approved"
        item.remove_annoucing_users([user])
      end
      ############### END REVISION #########################
      
      # sign = params["contact"].present? && params["contact"].to_i == item.transferred_contact.id ? "+" : ""
      item = [
              "<div item_id=\"#{item.id.to_s}\" class=\"main_part_info checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
              '<div class="text-center">'+item.contact.contact_link+"</div>",
              '<div class="text-center">'+item.to_contact.contact_link+"</div>",              
              '<div class="text-left">'+item.diplay_from_course+"</div>",
              '<div class="text-left">'+item.diplay_to_course+"</div>",
              '<div class="text-center">'+item.display_hour+"</div>",
              '<div class="text-right">'+item.display_money+"</div>",
              '<div class="text-right"><label class="col_label top0">Total:</label>'+ApplicationController.helpers.format_price_round(item.total)+"<label class=\"col_label top0\">Paid:</label>"+ApplicationController.helpers.format_price_round(item.paid)+"<label class=\"col_label top0\">Receivable:</label>"+ApplicationController.helpers.format_price_round(item.remain)+"</div>",
              #'<div class="text-right">'+ApplicationController.helpers.format_price(item.admin_fee.to_f)+"</div>",              
              '<div class="text-center">'+item.created_at.strftime("%d-%b-%Y <br/> %I:%M %p").html_safe+"<br /><strong>by:</strong><br />"+item.user.staff_col+"<br /><strong>EC:</strong><br />"+item.contact.staff_col+"</div>",
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
    return CoursesPhrase.where(id: ids).joins(:phrase).order("phrases.name, courses_phrases.start_at")
  end
  
  def to_courses_phrases
    return [] if to_courses_phrase_ids.nil?
    ids = self.to_courses_phrase_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
    return CoursesPhrase.where(id: ids)
  end
  
  def ordered_courses_phrases
    courses_phrases
  end
  
  def diplay_from_course(short=false)
    if !course.nil?
      active_course = contact.active_course(course.id, self.created_at-1.second)
      return "" if active_course.nil?
      
      full_course_subfix = (self.full_course == true && course.upfront != true) ? " <span class=\"active\">[full]</span>" : ""
      
      arr = []
      arr << "<div class=\"nowrap\"><strong>"+course.display_name+full_course_subfix+"</strong></div>"
      arr << "<div class=\"courses_phrases_list\">"+Course.render_courses_phrase_list(ordered_courses_phrases)+"</div>" if courses_phrases
      
      hour = active_course[:hour]
      money = active_course[:money]
      
      if !active_course[:course].upfront && hour.to_f > 0
        per_hour = money/hour
        tmp_cps = active_course[:courses_phrases]
        tmp_cps.each do |cp|
          if !self.courses_phrases.include?(cp)
            hour -= cp.hour
            money -= per_hour*cp.hour
          end
        end
      end
      
      if !short
        arr << "<br /><div>Hour: <strong>#{hour}</strong> <br /> Money: <strong>#{ApplicationController.helpers.format_price_round(money)}</trong></div>"
        
        arr << "<br /><div style=\"font-weight: normal\">Note: #{note}</div>" if note.present?
      end
      
        
      return arr.join("")
    
    elsif !from_hour.nil?
      hours = {}
      JSON.parse(from_hour).each do |r|
        tr = Transfer.find(r[0])
        hour_id = tr.course.course_type_id.to_s+"-"+tr.course.subject_id.to_s
        hours[hour_id] = hours[hour_id].nil? ? r[1].to_f : hours[hour_id] + r[1].to_f
      end
      
      arr = []
      hours.each do |r|
        arr << "<strong>"+CourseType.find(r[0].split("-")[0]).short_name+"-"+Subject.find(r[0].split("-")[1]).name+": "+r[1].to_s+" hours</strong>" if r[1].to_f > 0
      end
      
      if !short
        arr << "<br /><div>Note: #{note}</div>" if note.present?
      end
      
      return arr.join("<br />")

    else
      ""
    end
  end
  
  def diplay_to_course
    if to_type == "course"
      if !to_course.nil?
        full_course_subfix = (self.to_full_course == true && to_course.upfront != true) ? " <span class=\"active\">[full]</span>" : ""
        
        arr = []
        arr << "<div class=\"nowrap\"><strong>"+to_course.display_name+full_course_subfix+"</strong></div>"
        arr << "<div class=\"courses_phrases_list\">"+Course.render_courses_phrase_list(to_courses_phrases)+"</div>" if to_courses_phrases
        arr << "<br /><div>Hour: <strong>#{to_course_hour}</strong> <br /> Money: <strong>#{ApplicationController.helpers.format_price_round(to_course_money)}</trong></div>"
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
      str = ApplicationController.helpers.format_price_round(money.to_f)
      if money_credit.to_f > 0
        str += "<br /><br /><label class=\"col_label top0 text-nowrap\">#{contact.name}:</label>".html_safe+ ApplicationController.helpers.format_price_round(money_credit.to_f)
      end
      return str
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
  def money_credit=(new)
    self[:money_credit] = new.to_s.gsub(/\,/, '')
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
      
      # remote note log
      note_logs.each do |a|
        a.destroy
      end      
      
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
  
  def note_logs
    Activity.where(item_code: "transfer_#{self.id.to_s}")
  end
  
  def check_statuses
    if !statuses.include?("deleted") && !statuses.include?("delete_pending") && !statuses.include?("update_pending") && !statuses.include?("new_pending")
      add_status("active")
      
      contact.update_info
      to_contact.update_info
      
      self.note_logs.destroy_all
      self.send_note_log
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
    
    contact.update_info if contact.present?
    to_contact.update_info if to_contact.present?
    
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
      total = total.where("payment_records.payment_date >= ?", from_date.beginning_of_day)
    end
    if to_date.present?
      total = total.where("payment_records.payment_date <= ? ", to_date.end_of_day)
    end
    
    total = total.sum(:amount)
    
    return total
  end
  
  def remain(from_date=nil, to_date=nil)
    total - paid(from_date=nil, to_date=nil) - credit_money.to_f
  end
  
  def paid?
    paid + credit_money.to_f == total
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
    
    # update payment record
    ccs = ContactsCourse.where(contact_id: self.contact_id, course_id: self.course_id)
    ccs.each do |cc|
      cc.update_statuses
      cc.course_register.update_statuses
      cc.course_register.payment_records.each do |pr|
        pr.update_statuses
      end
    end
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
  
  def remain_hour(ct)
    sub_hour = 0.0
    ct.active_transfers.where("transfers.from_hour LIKE ?", "%\"#{self.id.to_s}\":%").each do |t|
      hash = JSON.parse(t.from_hour)
      hash.each do |row|
        sub_hour += row[1].to_f if row[0].to_s == self.id.to_s
      end
    end
    
    return hour - sub_hour
  end
  
  def remain_money(ct)
    rate = hour_money/hour
    sub_money = 0.0
    ct.active_transfers.where("transfers.from_hour LIKE ?", "%\"#{self.id.to_s}\":%").each do |t|
      hash = JSON.parse(t.from_hour)
      hash.each do |row|
        sub_money += rate*row[1].to_f if row[0].to_s == self.id.to_s
      end
    end
    
    return hour_money - sub_money
  end
  
  def send_note_log
    from_item = ""
    if !from_hour.nil?
      hours = {}
      JSON.parse(from_hour).each do |r|
        tr = Transfer.find(r[0])
        hour_id = tr.course.course_type_id.to_s+"-"+tr.course.subject_id.to_s
        hours[hour_id] = hours[hour_id].nil? ? r[1].to_f : hours[hour_id] + r[1].to_f
      end
      
      arr = []
      hours.each do |r|
        arr << CourseType.find(r[0].split("-")[0]).short_name+"-"+Subject.find(r[0].split("-")[1]).name+": "+r[1].to_s+" hours" if r[1].to_f > 0
      end
      from_item = "<strong>"+arr.join("; ")+"</strong>"
    else
      from_item = course.name
    end
    
    to_item = ""
    if !from_hour.nil? || to_type == "money"
      to_item = ApplicationController.helpers.format_price_round(money)+" "+Setting.get("currency_code")
    elsif to_type == "course"
      to_item = to_course.name
    elsif to_type == "hour"
      to_item = hour.to_s+" hours"   
    end
    
    # for transferrer
    from_message = "Deferred/Transferred <strong>#{from_item}</strong> into <strong>#{to_item}</strong>"
    from_message += " to <strong>#{to_contact.display_name}<strong>" if to_contact != contact
    
    contact.activities.create(user_id: user.id, note: from_message, item_code: "transfer_#{self.id.to_s}")
    
    # for receiver
    if to_contact != contact
      to_message = "Received <strong>#{to_item}</strong> from <strong>#{contact.display_name}</strong> by deferring <strong>#{from_item}</strong>"
      
      to_contact.activities.create(user_id: user.id, note: to_message, item_code: "transfer_#{self.id.to_s}")
    end
    
    return from_message
  end
  
  def note_log(c)
    from_item = ""
    if !from_hour.nil?
      hours = {}
      JSON.parse(from_hour).each do |r|
        tr = Transfer.find(r[0])
        hour_id = tr.course.course_type_id.to_s+"-"+tr.course.subject_id.to_s
        hours[hour_id] = hours[hour_id].nil? ? r[1].to_f : hours[hour_id] + r[1].to_f
      end
      
      arr = []
      hours.each do |r|
        arr << CourseType.find(r[0].split("-")[0]).short_name+"-"+Subject.find(r[0].split("-")[1]).name+": "+r[1].to_s+" hours" if r[1].to_f > 0
      end
      from_item = "<strong>"+arr.join("; ")+"</strong>"
    else
      from_item = course.name
    end
    
    to_item = ""
    credit_note = ""
    if !from_hour.nil? || to_type == "money"
      to_item = ApplicationController.helpers.format_price_round(money)+" "+Setting.get("currency_code")
      credit_note = "<div>Credit note: #{ApplicationController.helpers.format_price_round(c.budget_money(self.created_at))}</div>"
    elsif to_type == "course"
      to_item = to_course.name
    elsif to_type == "hour"
      to_item = hour.to_s+" hours"   
    end
    
    # for transferrer
    from_message = "Deferred/Transferred <strong>#{from_item}</strong> into <strong>#{to_item}</strong>"
    from_message += " to <strong>#{to_contact.display_name}<strong>" if to_contact != contact
    
    # for receiver
    if to_contact != contact
      to_message = "Received <strong>#{to_item}</strong> from <strong>#{contact.display_name}</strong> by deferring <strong>#{from_item}</strong>"      
    end
    
    if c == contact
      return from_message+credit_note
    else
      return to_message+credit_note
    end
  end
  
  def can_delete?
    return true if !statuses.include?("active")
    
    if !course.nil?
      if self.to_type == "course"
        Transfer.main_transfers.where("transfers.status NOT LIKE ?","%[deleted]%").where("transfers.created_at > ?", self.created_at).where(course_id: self.to_course_id).where(contact: self.to_contact).count == 0
      elsif self.to_type == "hour"
        hour_id = self.course.course_type_id.to_s+"-"+self.course.subject_id.to_s
        self.to_contact.budget_hour[hour_id].to_f >= self.hour # && false
      elsif self.to_type == "money"
        self.to_contact.budget_money >= self.money # && false
      else
        false
      end        
    elsif !from_hour.nil?
      self.to_contact.budget_money >= self.money # && false
    else
      false
    end    
  end
  
  def all_to_courses
    result = Course.where(parent_id: nil)
    result = result.where("courses.status IS NOT NULL AND courses.status NOT LIKE ?", "%[deleted]%")
    
    if self.course.course_type_id
      result = result.where(course_type_id: self.course.course_type_id)
    end
    if self.course.subject_id
      result = result.where(subject_id: self.course.subject_id)
    end
    
    #if self.course.upfront == true
    #  result = result.where(upfront: false)
    #end
    #if self.course.upfront == false
    #  if contact == to_contact
    #    result = result.where(upfront: true)
    #  end
    #end
    
    result_arr = []
    result.each do |c|
      result_arr << c if !to_contact.learned_courses.include?(c)
    end

    return result_arr
  end
  
  def pay_by_credit
    available_money = contact.budget_money
    if self.to_type == "money"
      available_money += self.money
    end
    pay = available_money >= remain ? remain : available_money
    self.update_column(:credit_money, pay)
    self.update_statuses
    self.update_cache_search
    self.update_contact_info
  end
  
  
  
end
