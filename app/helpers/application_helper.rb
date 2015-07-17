module ApplicationHelper
  def format_price(number, vn = false, round = false, precision = nil)
    prec = (number.to_f.round == number.to_f) ? 0 : 2
    prec = 0 if round
    
    if !precision.nil?
      prec = precision
    end
    
    
    if vn
      number_to_currency(number, precision: prec, separator: ",", unit: '', delimiter: ".")
    else
      number_to_currency(number, precision: prec, separator: ".", unit: '', delimiter: ",")
    end
  end
  
  def get_months_between_time(from_date, to_date)
	months = []

	(from_date.year..to_date.year).each do |y|
	  mo_start = (from_date.year == y) ? from_date.month : 1
	  mo_end = (to_date.year == y) ? to_date.month : 12
   
	  (mo_start..mo_end).each do |m|  
		months << "#{y.to_s}-#{m.to_s}-01".to_date
	  end
	end
	
	return months
  end
  
  def render_users_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      if can? :update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Edit', {controller: "users", action: "edit", id: item.id, tab_page: 1}, psrc: users_path(tab_page: 1), title: "Edit: #{item.name}", class: "tab_page")+'</li>'        
      end
      if can? :activity_log, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Activity Logs', {controller: "users", action: "activity_log", id: item.id, tab_page: 1}, title: "Activity Logs: #{item.name}", class: "tab_page")+'</li>'        
      end
      if can? :destroy, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Destroy', {controller: "users", action: "destroy", id: item.id}, method: :delete, data: { confirm: 'Are you sure?' })+'</li>'        
      end 
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
  def check_ajax_button(checked, url)	
    "<a href=\"#{url}\" class=\"check-radio ajax-check-radio\"><i class=\"#{checked.to_s} icon-#{(checked ? "check" : "check-empty")}\"></i></a>"
  end
end
