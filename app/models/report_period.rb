class ReportPeriod < ActiveRecord::Base
  include PgSearch
  
  has_many :sales_targets
  has_many :users, through: :sales_targets, source: :staff
  
  pg_search_scope :search,
                  against: [:name],                
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
  
  def self.active_report_periods
    self.where(status: "active")
  end
  
  def self.full_text_search(params)
    records = self.active_report_periods    
    records = records.where("LOWER(report_periods.name) LIKE ?", "%#{params[:q].mb_chars.strip.downcase}%") if params[:q].present?
    records.order("name").limit(50).map {|model| {:id => model.id, :text => model.display_name} }
  end
  
  def self.filter(params, user)
    @records = self.all
    
    if params["status"].present?
      @records = @records.where("report_periods.status LIKE '%#{params["status"]}%'")  
    end
    
    @records = @records.search(params["search"]["value"]) if params["search"].present? && !params["search"]["value"].empty?
    
    return @records
  end
  
  def self.datatable(params, user)
    @records = self.filter(params, user)
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "0"
        order = "report_periods.name"
      when "1"
        order = "report_periods.start_at"
      when "2"
        order = "report_periods.end_at"
      else
        order = "report_periods.start_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "report_periods.start_at DESC"
    end
    
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 4
    @records.each do |item|
      item = [
              item.name,
              item.start_at.strftime("%d-%b-%Y"),
              item.end_at.strftime("%d-%b-%Y"),
              item.display_statuses,
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
  
  def display_statuses
    result = ["<span title=\"\" class=\"badge user-role badge-info contact-status #{status}\">#{status}</span>"]
    result.join(" ").html_safe
  end
  
  def display_name
    "#{name} (#{start_at.strftime("%d-%b-%Y")} to #{end_at.strftime("%d-%b-%Y")})"
  end
  
  def self.status_options
    [
      ["Active","active"],
      ["Deleted","deleted"]
    ]
  end
  
end
