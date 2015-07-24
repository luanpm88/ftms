class Book < ActiveRecord::Base
  include PgSearch
  
  validates :name, presence: true, :uniqueness => true
  validates :user_id, presence: true
  
  belongs_to :user
  belongs_to :parent, :class_name => "Book"

  has_many :volumns, :foreign_key => "parent_id", :class_name => "Book"
  
  has_many :book_prices
  has_many :books_contacts
  
  mount_uploader :image, BookUploader
  
  pg_search_scope :search,
                against: [:name, :publisher],
                associated_against: {
                  parent: [:name]
                },
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
  
  def self.main_books
    self.where(parent_id: nil)
  end
  
  def cover_path(version = nil)
    if self.image_url.nil?
      return "public/img/avatar.jpg"
    elsif !version.nil?
      return self.image_url(version)
    else
      return self.image_url
    end
  end
  
  def cover(version = nil)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.url_for(controller: "books", action: "cover", id: self.id, type: version)
  end
  
  def self.filter(params, user)
    @records = self.main_books
    @records = @records.where("books.course_type_ids LIKE ? OR books.course_type_ids LIKE ? OR books.course_type_ids LIKE ? OR books.course_type_ids LIKE ? ", "%[#{params["program_id"]},%", "%,#{params["program_id"]},%", "%,#{params["program_id"]}]%", "%[#{params["program_id"]}]%") if params["program_id"].present?
    @records = @records.where("books.subject_ids LIKE ? OR books.subject_ids LIKE ? OR books.subject_ids LIKE ? OR books.subject_ids LIKE ? ", "%[#{params["subject_id"]},%", "%,#{params["subject_id"]},%", "%,#{params["subject_id"]}]%", "%[#{params["subject_id"]}]%") if params["subject_id"].present?
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    return @records
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = Book.filter(params, user)  
    
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "books.name"
      when "5"
        order = "books.publisher"
      when "7"
        order = "books.created_at"
      else
        order = "books.name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "books.created_at"
    end
    
    
    
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 9
    @records.each do |item|
      item = [
              item.cover_link,
              item.book_link,
              item.display_volumns,
              '<div class="text-center">'+item.course_types.map(&:short_name).join(", ")+"</div>",
              '<div class="text-center">'+item.subjects.map(&:name).join(", ")+"</div>",
              '<div class="text-left">'+item.publisher.to_s+"</div>",
              '<div class="text-center">'+item.display_prices+"</div>",
              '<div class="text-center">'+item.created_at.strftime("%d-%b-%Y")+"</div>", 
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
  
  def self.student_books(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @student = Contact.find(params[:student])
    
    @records =  self.filter(params, user)
    
    @records = @records.includes(:books_contacts => :course_register)
    @records = @records.where(books_contacts: {contact_id: @student.id})
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "books.name"
      when "5"
        order = "books.publisher"
      when "7"
        order = "books.created_at"
      else
        order = "books.name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "books.created_at"
    end
    
    
    
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 9
    @records.each do |item|
      item = [
              item.cover_link,
              item.book_link,
              item.display_volumns,
              '<div class="text-center">'+item.course_types.map(&:short_name).join(", ")+"</div>",
              '<div class="text-center">'+item.subjects.map(&:name).join(", ")+"</div>",
              '<div class="text-left">'+item.publisher.to_s+"</div>",
              '<div class="text-center">'+item.display_prices+"</div>",
              '<div class="text-center">'+item.created_at.strftime("%d-%b-%Y")+"</div>", 
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
  
  def cover_link
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.link_to(display_cover(:thumb), cover, class: "fancybox.image fancybox", title: name)
  end
  

  
  def display_volumns
    vs = []
    volumns.each do |b|
      vs << "<div class=\"volumn_line\">#{b.name}</div>"
    end
    
    return vs.join(" ").html_safe
  end
  
  def display_cover(version = nil)
    self.image_url.nil? ? "<i class=\"icon-picture icon-nopic-60\"></i>".html_safe : "<img width='60' src='#{cover(version)}' />".html_safe
  end
  
  def book_link(title=nil)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    title = title.nil? ? name : title
    
    link_helper.link_to(title, {controller: "books", action: "edit", id: id, tab_page: 1}, class: "tab_page", title: name)
  end
  
  def book_price
    book_prices.order("created_at DESC").first
  end
  
  def prices
    if book_price.nil?
      return []
    else
      return JSON.parse(book_price.prices)
    end   
  end
  
  def display_prices
    a = prices.map {|p| ApplicationController.helpers.format_price(p)}
    return a.join("<br />")
  end
  
  def update_price(new_price)
    if book_price.nil?
      new_price.save
    else
      if book_price.prices != new_price.prices
        new_price.save
      end      
    end
  end  
  
  def course_type_ids=(new)
    arr = new.split(",").map {|s| s.to_i}
    self[:course_type_ids] = arr.to_json
  end
  
  def course_type_ids_json
    json = course_types.map {|t| {id: t.id.to_s, text: t.short_name}}
    json.to_json
  end
  
  def course_types
    arr = course_type_ids.nil? ? [] : JSON.parse(course_type_ids)
    
    return CourseType.where(id: arr)
  end
  
  def subject_ids=(new)
    arr = new.split(",").map {|s| s.to_i}
    self[:subject_ids] = arr.to_json
  end
  
  def subject_ids_json
    json = subjects.map {|t| {id: t.id.to_s, text: t.name}}
    json.to_json
  end
  
  def subjects
    arr = subject_ids.nil? ? [] : JSON.parse(subject_ids)
    
    return Subject.where(id: arr)
  end
  
end
