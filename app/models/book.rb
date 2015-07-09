class Book < ActiveRecord::Base
  include PgSearch
  
  validates :name, presence: true, :uniqueness => true
  validates :user_id, presence: true
  
  belongs_to :user
  belongs_to :parent, :class_name => "Book"
  has_many :volumns, :foreign_key => "parent_id", :class_name => "Book"
  
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
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.main_books
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "books.name"
      when "3"
        order = "books.publisher"
      when "4"
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
    
    actions_col = 6
    @records.each do |item|
      item = [
              item.book_link(item.display_cover(:thumb)),
              item.book_link,
              item.display_volumns,
              '<div class="text-left">'+item.publisher.to_s+"</div>",
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
end
