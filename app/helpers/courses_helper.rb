module CoursesHelper
  def render_course_actions(item, size=nil)
    size = size.nil? ? "mini" : size
    actions = '<div class="text-right but"><div class="btn-group actions">
                    <button class="btn btn-'+size+' btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      group_1 = 0
      if can? :approve_new, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve New', {controller: "courses", action: "approve_new", id: item.id, tab_page: 1}, title: "#{item.display_name}: Approve New", class: "approve_link")+'</li>'
        group_1 += 1
      end
     
      if can? :approve_update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve Update', {controller: "courses", action: "approve_update", id: item.id, tab_page: 1}, title: "#{item.display_name}: Approve Update", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      if can? :approve_delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve Delete', {controller: "courses", action: "approve_delete", id: item.id, tab_page: 1}, title: "#{item.display_name}: Approve Delete", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      
      
      actions += '<li class="divider"></li>' if group_1 > 0
      
      
      
      
      
      
      if can? :update, item
        actions += '<li>'+item.course_link("Edit", courses_path(tab_page: 1))+'</li>'        
      end
      
      if can? :delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Delete', {controller: "courses", action: "delete", id: item.id, tab_page: 1}, title: "#{item.display_name}: Delete", class: "approve_link")+'</li>'        
      end
      
      if can? :undo_delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Undo Delete', {controller: "courses", action: "undo_delete", id: item.id, tab_page: 1}, title: "#{item.display_name}: Undo Delete", class: "approve_link")+'</li>'
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
  def render_student_courses_actions(item, contact_id)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      
      group_1 = 0      

      if can? :transfer_course, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Defer/Transfer', {controller: "courses", action: "transfer_course", contact_id: contact_id, id: item.id, tab_page: 1}, title: "#{Contact.find(contact_id).name}: Defer/Transfer [#{item.display_name}]", class: "tab_page")+'</li>'
        group_1 += 1
      end
      
      actions += '<li class="divider"></li>' if group_1 > 0

      
      if can? :read, Contact
        actions += '<li>'+item.student_list_link+'</li>'        
      end
      
      if can? :update, item
        actions += '<li>'+item.course_link("View")+'</li>'        
      end
      
      if can? :destroy, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Destroy', {controller: "courses", action: "destroy", id: item.id}, method: :delete, data: { confirm: 'Are you sure?' })+'</li>'        
      end 
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
  def render_course_history_actions(item)
    return "" if item.revisions.empty?
    
      actions = '<div class="text-right but"><div class="btn-group actions">
                    <button class="btn btn-big btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown"><i class="icon-time"></i> Histories <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      item.revisions.order("created_at DESC").each do |d|
        actions += '<li>'+ActionController::Base.helpers.link_to("#{d.created_at.strftime("%d-%b-%Y %I:%M %p")}", {controller: "courses", action: "edit", id: d.id, tab_page: 1}, title: "[#{d.created_at.strftime("%d-%b-%Y %I:%M %p")}] #{d.display_name}", class: "tab_page")+'</li>'        
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
end
