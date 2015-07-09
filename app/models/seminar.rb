class Seminar < ActiveRecord::Base
  include PgSearch
  
  validates :name, presence: true, :uniqueness => true
  validates :user_id, presence: true
  
  belongs_to :user
  
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
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 5
    @records.each do |item|
      item = [
              item.seminar_link,
              item.description,
              '<div class="text-center">'+item.contact_count_link+"</div>",
              '<div class="text-center">'+item.start_at.strftime("%d-%b-%Y %I:%M %p")+"</div>",
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
  
end
