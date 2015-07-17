module DiscountProgramsHelper
  def render_discount_program_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      if can? :update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Edit', {controller: "discount_programs", action: "edit", id: item.id, tab_page: 1}, psrc: discount_programs_path(tab_page: 1), title: "Edit: #{item.name}", class: "tab_page")+'</li>'        
      end
      
      if can? :destroy, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Destroy', {controller: "discount_programs", action: "destroy", id: item.id}, method: :delete, data: { confirm: 'Are you sure?' })+'</li>'        
      end 
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
end
