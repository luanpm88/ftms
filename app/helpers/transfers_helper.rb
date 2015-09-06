module TransfersHelper
  
  def render_transfer_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      
      group_1 = 0
      
      if can? :approve_new, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve New', {controller: "transfers", action: "approve_new", id: item.id, tab_page: 1}, title: "#{item.contact.name}: Transfer Approve New", class: "tab_page")+'</li>'
        group_1 += 1
      end
      
      if can? :approve_update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve Update', {controller: "transfers", action: "approve_update", id: item.id, tab_page: 1}, title: "#{item.contact.name}: Transfer Approve Update", class: "tab_page")+'</li>'
        group_1 += 1
      end
      
      if can? :approve_delete, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Approve Delete', {controller: "transfers", action: "approve_delete", id: item.id, tab_page: 1}, title: "#{item.contact.name}: Transfer Approve Delete", class: "tab_page")+'</li>'
        group_1 += 1
      end
      
      actions += '<li class="divider"></li>' if group_1 > 0
      
      
      #if can? :update, item
      #  actions += '<li>'+ActionController::Base.helpers.link_to('Edit', {controller: "subjects", action: "edit", id: item.id, tab_page: 1}, psrc: subjects_path(tab_page: 1), title: "Edit: #{item.name}", class: "tab_page")+'</li>'        
      #end
      #
      #if can? :destroy, item
      #  actions += '<li>'+ActionController::Base.helpers.link_to('Destroy', {controller: "subjects", action: "destroy", id: item.id}, method: :delete, data: { confirm: 'Are you sure?' })+'</li>'        
      #end 
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
end
