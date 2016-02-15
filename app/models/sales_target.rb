class SalesTarget < ActiveRecord::Base
  
  validate :not_exist
  
  belongs_to :staff, class_name: "User"
  belongs_to :report_period
  
  include PgSearch
  
  pg_search_scope :search,
                  against: [:staff_id],                
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
  
  def not_exist
    if self.status == "active" and !SalesTarget.active_sales_targets.where(status: "active").where(staff_id: self.staff_id).where(report_period_id: self.report_period_id).empty?
      errors.add(:base, "Target does exist! Please choose another period or staff.".html_safe)
    end
  end
  
  def amount=(new)
    self[:amount] = new.to_s.gsub(/\,/, '')
  end
  
  def self.active_sales_targets
    self.where(status: "active")
  end
  
  def self.full_text_search(params)
    records = self.active_report_periods
    records = records.where("LOWER(report_periods.name) LIKE ?", "%#{params[:q].mb_chars.strip.downcase}%") if params[:q].present?
    records.order("name").limit(50).map {|model| {:id => model.id, :text => model.name} }
  end
  
  def self.filter(params, user)
    @records = self.all
    
    if params["staff"].present?
      @records = @records.where("sales_targets.staff_id IN (#{params["staff"]})") if params["staff"].present?
    end
    if params["report_period"].present?
      @records = @records.where("sales_targets.report_period_id IN (#{params["report_period"]})") if params["report_period"].present?
    end
    if params["status"].present?
      @records = @records.joins(:report_period)      
      if params["status"] == "active"
        @records = @records.where("sales_targets.status LIKE '%#{params["status"]}%'")
        @records = @records.where("report_periods.status LIKE '%#{params["status"]}%'")
      else
        @records = @records.where("report_periods.status LIKE '%#{params["status"]}%' OR sales_targets.status LIKE '%#{params["status"]}%'")
      end      
    end
    
    @records = @records.search(params["search"]["value"]) if params["search"].present? && !params["search"]["value"].empty?
    
    return @records
  end
  
  def self.datatable(params, user)
    @records = self.filter(params, user).joins(:report_period, :staff)
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "0"
        order = "users.name"
      when "1"
        order = "report_periods.start_at"
      when "2"
        order = "sales_targets.amount"
      else
        order = "sales_targets.created_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "sales_targets.created_at DESC"
    end
    
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 5
    @records.each do |item|
      item = [
              item.staff.name,
              item.report_period.display_name,
              ApplicationController.helpers.format_price_round(item.amount),
              item.created_at.strftime("%d-%b-%Y"),
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
    s = (report_period.status == "active" and self.status == "active") ? "active" : "deleted"
    result = ["<span title=\"\" class=\"badge user-role badge-info contact-status #{s}\">#{s}</span>"]
    result.join(" ").html_safe
  end
  
  def self.status_options
    [
      ["Active","active"],
      ["Deleted","deleted"]
    ]
  end
  
end
