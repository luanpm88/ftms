class Seminar < ActiveRecord::Base
  include PgSearch
  
  validates :name, presence: true, :uniqueness => true
  validates :user_id, presence: true
  
  belongs_to :user
  belongs_to :course_type
  
  has_many :contacts_seminars, :dependent => :destroy
  has_and_belongs_to_many :contacts
  
  pg_search_scope :search,
                against: [:name, :description],
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def self.full_text_search(params)    
    self.search(params[:q]).limit(50).map {|model| {:id => model.id, :text => model.name} }
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.all
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
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
    
    @records = @records.where("course_type_id IN (#{params["course_types"].join(",")})") if params["course_types"].present?

    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 6
    @records.each do |item|
      item = [
              item.seminar_link,
              item.description,
              '<div class="text-center">'+item.course_type_name+"</div>",
              '<div class="text-center">'+item.contact_count_link+"</div>",
              '<div class="text-center">'+item.display_start_at+"</div>",
              '<div class="text-center">'+item.user.staff_col+"</div>",
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
    ActionController::Base.helpers.link_to(title, {controller: "seminars", action: "edit", id: id, tab_page: 1, tab: "attendance"}, title: "#{name}: Attendance List", class: "tab_page")
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
  
  def render_list(file)
    list = []
    
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      item = {name: row["Full name"], company: row["Company"], mobile: row["Mobile"], email: row["Email"], present: row["Status"]}
      item[:contacts] = similar_contacts({email: item[:email], name: item[:name]})
      list << item
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
          if row[:name].strip.downcase == contact.name.downcase && row[:email].strip.downcase == contact.email.downcase
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
      result += Contact.where("LOWER(email) = ? OR LOWER(name) = ?", data[:email].strip.downcase, data[:name].strip.downcase)
    end
    
    return result
  end
  
end
