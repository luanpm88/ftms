module TransfersHelper
  
  def render_transfer_actions(item, size=nil)
    size = size.nil? ? "mini" : size
    actions = '<div class="text-right but"><div class="btn-group actions">
                    <button class="btn btn-'+size+' btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      
      group_1 = 0
      
      if can? :approve_new, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve New', {controller: "transfers", action: "approve_new", id: item.id, tab_page: 1}, title: "#{item.contact.name}: Transfer Approve New", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      if can? :approve_update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve Update', {controller: "transfers", action: "approve_update", id: item.id, tab_page: 1}, title: "#{item.contact.name}: Transfer Approve Update", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      if can? :approve_delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve Delete', {controller: "transfers", action: "approve_delete", id: item.id, tab_page: 1}, title: "#{item.contact.name}: Transfer Approve Delete", class: "approve_link")+'</li>'
        group_1 += 1
      end
      
      
      
      actions += '<li class="divider"></li>' if group_1 > 0
      
      
      group_2 = 0
      if can? :pay, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Pay Admin Fee', {controller: "transfers", action: "pay", id: item.id, tab_page: 1}, title: "Pay Admin Fee: #{item.contact.display_name}", class: "tab_page")+'</li>'
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
      
      #actions += '<li class="divider"></li>' if group_3 > 0
      
      if can? :update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Vew/Edit', {controller: "transfers", action: "edit", id: item.id, tab_page: 1}, psrc: subjects_path(tab_page: 1), title: "Defer/Transfer: #{item.contact.display_name}", class: "tab_page")+'</li>'        
      end
      #
      #if can? :destroy, item
      #  actions += '<li>'+ActionController::Base.helpers.link_to('Destroy', {controller: "subjects", action: "destroy", id: item.id}, method: :delete, data: { confirm: 'Are you sure?' })+'</li>'        
      #end
      
      if can? :delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Delete', {controller: "transfers", action: "delete", id: item.id, tab_page: 1}, title: "Transfer: Delete", class: "approve_link")+'</li>'        
      end
      
      if can? :undo_delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Undo Delete', {controller: "transfers", action: "undo_delete", id: item.id, tab_page: 1}, title: "#{item.contact.name}: Transfer Undo Delete", class: "approve_link")+'</li>'
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
  def render_transfer_history_actions(item)
    return "" if item.revisions.empty?
    
      actions = '<div class="text-right but"><div class="btn-group actions">
                    <button class="btn btn-big btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown"><i class="icon-time"></i> Histories <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      item.revisions.order("created_at DESC").each do |d|
        actions += '<li>'+ActionController::Base.helpers.link_to("#{d.created_at.strftime("%d-%b-%Y %I:%M %p")}", {controller: "transfers", action: "edit", id: d.id, tab_page: 1}, title: "[#{d.created_at.strftime("%d-%b-%Y %I:%M %p")}] Defer/Transfer: #{item.contact.display_name}", class: "tab_page")+'</li>'        
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
end
