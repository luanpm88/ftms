module ReportPeriodsHelper
  def render_course_actions(item, size=nil)
    size = size.nil? ? "mini" : size
    actions = '<div class="text-right but"><div class="btn-group actions">
                    <button class="btn btn-'+size+' btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      if can? :update, item
        actions += '<li>'+ActionController::Base.helpers.link_to("Edit", edit_report_period_path(item, tab_page: 1), class: "tab_page", title: "#{item.name}")+'</li>'        
      end
      
      if can? :delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Delete', {controller: "report_periods", action: "delete", id: item.id, tab_page: 1}, title: "#{item.name}: Delete", class: "approve_link")+'</li>'        
      end
      
      if can? :undo_delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Undo Delete', {controller: "report_periods", action: "undo_delete", id: item.id, tab_page: 1}, title: "#{item.name}: Undo Delete", class: "approve_link")+'</li>'
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
end
