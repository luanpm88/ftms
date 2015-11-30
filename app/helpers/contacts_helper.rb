module ContactsHelper
  
  def render_contacts_actions(item, size=nil, params=nil)
    size = size.nil? ? "mini" : size
    actions = '<div class="text-right but"><div class="btn-group actions">
                    <button class="btn btn-'+size+' btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      
      group_1 = 0
      if can? :approve_new, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve New', {controller: "contacts", action: "approve_new", id: item.id, tab_page: 1}, title: "#{item.display_name}: Approve New", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      if can? :approve_education_consultant, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve Education Consultant', {controller: "contacts", action: "approve_education_consultant", id: item.id, tab_page: 1}, title: "#{item.display_name}: Approve Education Consultant", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      if can? :approve_update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve Update', {controller: "contacts", action: "approve_update", id: item.id, tab_page: 1}, title: "#{item.display_name}: Approve Update", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      if can? :approve_delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve Delete', {controller: "contacts", action: "approve_delete", id: item.id, tab_page: 1}, title: "#{item.display_name}: Approve Delete", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      if params.present? and params[:type] == "merged"
        #actions += '<a confirm-message="Remove from this related group?" href="<%= remove_related_contact_contacts_path(id: @contact.id, remove_id: c.id) %>" class="btn btn-small btn-warning remove_related_contact_link pull-right">This is not the same contact!</a>'
        actions += '<li>'+ActionController::Base.helpers.link_to('Not related contact!', {controller: "contacts", action: "remove_related_contact", id: item.id, remove_id: item.id, tab_page: 1, redirect: "ajax"}, title: "Not related contact!", class: "approve_link")+'</li>'
      end
      
      
      actions += '<li class="divider"></li>' if group_1 > 0
      
      
      group_2 = 0
      if can? :add_course, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Add Course/Stock', {controller: "course_registers", action: "new", contact_id: item.id, tab_page: 1}, psrc: course_registers_path(tab_page: 1), title: "#{item.display_name}: Course/Stock Registration", class: "tab_page")+'</li>'
        group_2 += 1
      end
      
      if can? :transfer_hour, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Defer/Transfer Hour', {controller: "transfers", action: "transfer_hour", contact_id: item.id, tab_page: 1}, title: "#{item.display_name}: Transfer Hour", class: "tab_page")+'</li>'
        group_2 += 1
      end
      
      actions += '<li class="divider"></li>' if group_2 > 0
      
      #if can? :read, Activity
      #  actions += '<li>'+ActionController::Base.helpers.link_to('Activity Log', {controller: "contacts", action: "edit", id: item.id, tab_page: 1, tab: "activity"}, title: "#{item.display_name}: Activity Log", class: "tab_page")+'</li>'        
      #end
      
      if can? :delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Delete', {controller: "contacts", action: "delete", id: item.id, tab_page: 1, tab: "activity"}, title: "#{item.display_name}: Delete", class: "approve_link")+'</li>'        
      end
      
      if can? :undo_delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Undo Delete', {controller: "contacts", action: "undo_delete", id: item.id, tab_page: 1}, title: "#{item.display_name}: Undo Delete", class: "approve_link")+'</li>'
      end
      
      actions += '<li class="divider"></li>'
      
      if can? :print, item
        actions += '<li>'+ActionController::Base.helpers.link_to('<i class="icon-print"></i> Print Info'.html_safe, {controller: "contacts", action: "print", id: item.id}, target: "_blank")+'</li>'
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
  def render_contact_tags_selecter(item)
      actions = "<div class=\"contact_tag_box\" rel=\""+item.id.to_s+"\">"
    
      actions += '<div class="" rel="'+item.id.to_s+'"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle tag_button " data-toggle="dropdown" title="">Tags ('+item.contact_tags.count.to_s+') <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      item.contact_tags.each do |tag|
        actions += '<li type="remove" rel="'+item.id.to_s+'" tag_id="'+tag.id.to_s+'" class="contact_tag_item '+tag.name.downcase.gsub(" ","_")+'">'+ActionController::Base.helpers.link_to((tag.name+" <i class=\"icon-minus\"></i>").html_safe, "#", title: "Remove Tag: "+tag.description)+' </li>'        
      end
      
      actions += '</ul></div></div>'
      
      actions += '<div class="" rel="'+item.id.to_s+'"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle tag_button " data-toggle="dropdown" title="">Add Tag <i class="icon-plus"></i> <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      ContactTag.active_contact_tags.each do |tag|
        if !item.contact_tags.include?(tag)
          actions += '<li type="add" rel="'+item.id.to_s+'" tag_id="'+tag.id.to_s+'" class="contact_tag_item '+tag.name.downcase.gsub(" ","_")+'">'+ActionController::Base.helpers.link_to((tag.name+" <i class=\"icon-plus\"></i>").html_safe, "#", title: "Add Tag: "+tag.description)+'</li>'        
        end
      end
      
      actions += '</ul></div></div></div>'
      
      return actions.html_safe
  end
  
  def render_history_actions(item)
    return "" if item.revisions.empty?
    
      actions = '<div class="text-right but"><div class="btn-group actions">
                    <button class="btn btn-big btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown"><i class="icon-time"></i> Histories <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      item.revisions.order("created_at DESC").each do |d|
        actions += '<li>'+ActionController::Base.helpers.link_to("#{d.created_at.strftime("%d-%b-%Y %I:%M %p")}", {controller: "contacts", action: "edit", id: d.id, tab_page: 1}, title: "[#{d.created_at.strftime("%d-%b-%Y %I:%M %p")}] #{d.display_name}", class: "tab_page")+'</li>'        
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
end
