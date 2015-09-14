module ActivitiesHelper
  def render_activity_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      if can? :destroy, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Delete', {controller: "activities", action: "destroy", id: item.id}, class: "activity_destroy")+'</li>'        
      end 
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
end
