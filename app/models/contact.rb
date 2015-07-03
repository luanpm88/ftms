class Contact < ActiveRecord::Base
  mount_uploader :image, LogoUploader
  
  include PgSearch
  
  validates :address, presence: true
  validates :email, presence: true
  validates :mobile, presence: true, if: :is_individual?
  validates :name, presence: true, :if => :is_not_individual?
  validates :first_name, presence: true, if: :is_individual?
  validates :last_name, presence: true, if: :is_individual?
  validates :birthday, presence: true, if: :is_individual?
  validates :sex, presence: true, if: :is_individual?
  
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

  belongs_to :city
  has_one :state, :through => :city
  
  has_and_belongs_to_many :contact_types
  
  has_and_belongs_to_many :contact_tags
  has_many :contact_tags_contacts, :dependent => :destroy
  
  belongs_to :tag, :class_name => "ContactTagsContact", :foreign_key => "tag_id"
  
  after_validation :update_cache
  
  def is_not_individual?
    !is_individual
  end
  def is_individual?
    is_individual
  end
  
  def 
  
  def first_name=(str)
    self[:first_name] = str.strip
  end
  def last_name=(str)
    self[:last_name] = str.strip
  end
  def name=(str)
    self[:name] = str.strip
  end
  def not_exist
    exist = []
    if is_individual
      exist += Contact.where("contacts.id != #{self.id} AND LOWER(first_name) = ? AND LOWER(last_name) = ? AND birthday = ?", first_name.downcase, last_name.downcase, birthday) if first_name.present? && last_name.present?
    else
      exist += Contact.where("contacts.id != #{self.id} AND LOWER(name) = ?", name.downcase) if name.present?
    end
    
    if exist.length > 0
      cs = []
      exist.each do |c|
        cs << c.contact_link
      end
      errors.add(:base, "There are/is contact(s) with the same information: #{cs.join(";")}".html_safe)
    end
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    @records = self.main_contacts
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "contacts.first_name #{params["order"]["0"]["dir"]}, contacts.last_name #{params["order"]["0"]["dir"]}"
      else
        order = "contacts.first_name"
      end
      order += " "+params["order"]["0"]["dir"] if params["order"]["0"]["column"] == 3
    else
      order = "contacts.first_name, contacts.last_name"
    end
    @records = @records.order(order) if !order.nil?
    
    @records = @records.where_by_types(params[:types].split(",")) if params[:types].present?
    @records = @records.where("contacts.is_individual IN (#{params[:individual_statuses]})") if params[:individual_statuses].present?
    @records = @records.where("contacts.referrer_id IN (#{params[:companies]})") if params[:companies].present?
    if params[:tags].present?
      @records = @records.joins(:tag)
      @records = @records.where("contact_tags_contacts.contact_tag_id IN (#{params[:tags].join(",")})")
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
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 7
    @records.each do |item|
      item = [
              link_helper.link_to(item.display_picture(:thumb), {controller: "contacts", action: "edit", id: item.id, tab_page: 1}, class: "main-title tab_page", title: item.display_name),
              '<div class="text-left nowrap">'+item.contact_link+"</div>",
              '<div class="text-left">'+item.html_info_line.html_safe+"</div>",
              '<div class="text-center nowrap">'+item.city_name+"</div>",
              '<div class="text-left">'+item.referrer_link+"</div>",
              '<div class="text-center contact_tag_box" rel="'+item.id.to_s+'">'+ContactsController.helpers.render_contact_tags_selecter(item)+"</div>",
              '<div class="text-center">'+item.user.staff_col+"</div>",
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
  
  def referrer_link
    referrer.nil? ? "" : '<i class="icon-building"></i> '+referrer.contact_link
  end
  
  def contact_link
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.link_to(display_name, {controller: "contacts", action: "edit", id: id, tab_page: 1}, class: "tab_page", title: display_name)
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
  
  def self.main_contacts
    self.all
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
    line += "<p class=\"address_info_line nowrap\">" + address + "</p>" if !address.nil? && !address.empty?
    line += "<i class=\"icon-envelope\"></i> " + email + "<br />" if !email.nil? && !email.empty?
    
    if is_individual
      line += "<i class=\"icon-phone\"></i> " + mobile + "<br /> " if !mobile.nil? && !mobile.empty?       
    else
      line += "<i class=\"icon-phone\"></i> " + phone + "<br />" if !phone.nil? && !phone.empty?
      line += "<i class=\"icon-print\"></i> " + fax + "<br />" if !fax.nil? && !fax.empty?
      line += "<strong>Tax code:</strong> " + tax_code + "<br />" if !tax_code.nil? && !tax_code.empty?
    end
    
      
        
    
      
    
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
                against: [:name, :address, :website, :phone, :mobile, :fax, :email, :tax_code, :note, :account_number, :bank],
                associated_against: {
                  city: [:name],
                  state: [:name],
                  agents: [:name]
                },
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def self.full_text_search(params)
    records = self.all
    if params[:is_individual].present? && params[:is_individual] == "false"
      records = records.where(is_individual: false)
    end    
    records.search(params[:q]).limit(50).map {|model| {:id => model.id, :text => model.display_name} }
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
  
  def display_name
    sirname = sex == "female" ? "[Ms]" : "[Mr]"
    is_individual ? (first_name+" "+last_name+" "+sirname).html_safe : short_name
  end
  
  def display_picture(version = nil)
    self.image_url.nil? ? "<i class=\"icon-picture icon-nopic-60\"></i>".html_safe : "<img width='60' src='#{logo(version)}' />".html_safe
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
  
end
