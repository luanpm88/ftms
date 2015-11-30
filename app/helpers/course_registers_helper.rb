module CourseRegistersHelper
  def render_course_register_actions(item, size=nil)
    size = size.nil? ? "mini" : size
    actions = '<div class="text-right but"><div class="btn-group actions">
                    <button class="btn btn-'+size+' btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      group_1 = 0
      
      if can? :approve_new, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve New', {controller: "course_registers", action: "approve_new", id: item.id, tab_page: 1}, title: "#{item.contact.display_name}: Register Approve New", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      if can? :approve_update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve Update', {controller: "course_registers", action: "approve_update", id: item.id, tab_page: 1}, title: "#{item.contact.display_name}: Register Approve Update", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      if can? :approve_delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve Delete', {controller: "course_registers", action: "approve_delete", id: item.id, tab_page: 1}, title: "#{item.contact.display_name}: Register Approve Delete", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      
      
      actions += '<li class="divider"></li>' if group_1 > 0
      
      group_2 = 0
      if can? :pay_registration, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Pay', {controller: "payment_records", action: "new", course_register_id: item.id, tab_page: 1}, psrc: course_registers_path(tab_page: 1), title: "Pay: #{item.contact.display_name}", class: "tab_page")+'</li>'
        group_2 += 1
      end
      
      if can? :deliver_stock, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Materials Delivery', {controller: "deliveries", action: "new", course_register_id: item.id, tab_page: 1}, psrc: course_registers_path(tab_page: 1), title: "Deliver Stock: #{item.contact.display_name}", class: "tab_page")+'</li>'
        group_2 += 1
      end
      
      actions += '<li class="divider"></li>' if group_2 > 0
      
      
       
      group_2 = 0
      if can? :delivery_print, item
            actions += '<li>'+ActionController::Base.helpers.link_to("<i class=\"icon icon-print\"></i> Deliery [#{item.created_at.strftime("%d-%b-%Y")}]".html_safe, {controller: "course_registers", action: "delivery_print", id: item.id}, title: "Deliery [#{item.created_at.strftime("%d-%b-%Y")}]", target: "_blank")+'</li>'
            group_2 += 1
      end
      
      actions += '<li class="divider"></li>' if group_2 > 0
      
      group_3 = 0
      item.all_payment_records.each do |pr|
        if can? :print, pr
          actions += '<li>'+ActionController::Base.helpers.link_to("<i class=\"icon icon-print\"></i> Receipt [#{pr.payment_date.strftime("%d-%b-%Y")}]".html_safe, {controller: "payment_records", action: "show", id: pr.id, tab_page: 1}, title: "#{item.contact.display_name}: Receipt [#{pr.payment_date.strftime("%d-%b-%Y")}]", class: "tab_page")+'</li>'
          group_3 += 1
        end
      end
      
      actions += '<li class="divider"></li>' if group_3 > 0
      
      if can? :read, item
        actions += '<li>'+ActionController::Base.helpers.link_to('View Detail', {controller: "course_registers", action: "show", id: item.id, tab_page: 1}, title: "Course/Stock Registration: #{item.contact.display_name}", class: "tab_page")+'</li>'
      end
      
      if can? :read, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Edit', {controller: "course_registers", action: "edit", id: item.id, tab_page: 1}, title: "Edit Course Register: #{item.contact.display_name}", class: "tab_page")+'</li>'
      end
      
      if can? :delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Delete', {controller: "course_registers", action: "delete", id: item.id, tab_page: 1}, title: "Course Register: Delete", class: "approve_link")+'</li>'        
      end
      
      if can? :undo_delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Undo Delete', {controller: "course_registers", action: "undo_delete", id: item.id, tab_page: 1}, title: "#{item.contact.display_name}: Undo Delete", class: "approve_link")+'</li>'
      end
      
      #
      #if can? :course_register, item
      #  actions += '<li>'+ActionController::Base.helpers.link_to('Add Course', {controller: "course_registers", action: "new", contact_id: item.id, tab_page: 1}, title: "#{item.display_name}: Course Register", class: "tab_page")+'</li>'        
      #end
      
      
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
  def render_course_register_history_actions(item)
    return "" if item.revisions.empty?
    
      actions = '<div class="text-right but"><div class="btn-group actions">
                    <button class="btn btn-big btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown"><i class="icon-time"></i> Histories <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      item.revisions.order("created_at DESC").each do |d|
        actions += '<li>'+ActionController::Base.helpers.link_to("#{d.created_at.strftime("%d-%b-%Y %I:%M %p")}", {controller: "course_registers", action: "show", id: d.id, tab_page: 1}, title: "[#{d.created_at.strftime("%d-%b-%Y %I:%M %p")}] Course/Stock Registration: #{item.contact.display_name}", class: "tab_page")+'</li>'        
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
end
