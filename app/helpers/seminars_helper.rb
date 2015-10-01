module SeminarsHelper
  def render_seminar_actions(item, size=nil)
      size = size.nil? ? "mini" : size
      actions = '<div class="text-right but"><div class="btn-group actions">
                    <button class="btn btn-'+size+' btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      group_1 = 0
      
      if can? :approve_new, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve New', {controller: "seminars", action: "approve_new", id: item.id, tab_page: 1}, title: "#{item.name}: Approve New", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      if can? :approve_update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve Update', {controller: "seminars", action: "approve_update", id: item.id, tab_page: 1}, title: "#{item.name}: Approve Update", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      if can? :approve_delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve Delete', {controller: "seminars", action: "approve_delete", id: item.id, tab_page: 1}, title: "#{item.name}: Approve Delete", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      actions += '<li class="divider"></li>' if group_1 > 0
      
      if can? :import_list, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Import List', {controller: "seminars", action: "import_list", id: item.id, tab_page: 1}, psrc: seminars_path(tab_page: 1), title: item.name+": Import List", class: "tab_page")+'</li>'        
      end
      
      if can? :update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Edit', {controller: "seminars", action: "edit", id: item.id, tab_page: 1}, psrc: seminars_path(tab_page: 1), title: item.name, class: "tab_page")+'</li>'        
      end
      
      if can? :delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Delete', {controller: "seminars", action: "delete", id: item.id, tab_page: 1}, title: "#{item.name}: Delete", class: "tab_page")+'</li>'        
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
  def render_seminar_history_actions(item)
    return "" if item.revisions.empty?
    
      actions = '<div class="text-right but"><div class="btn-group actions">
                    <button class="btn btn-big btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Histories <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      item.revisions.order("created_at DESC").each do |d|
        actions += '<li>'+ActionController::Base.helpers.link_to("#{d.created_at.strftime("%d-%b-%Y %I:%M %p")}", {controller: "seminars", action: "edit", id: d.id, tab_page: 1}, title: "[#{d.created_at.strftime("%d-%b-%Y %I:%M %p")}] #{d.name}", class: "tab_page")+'</li>'        
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
end
