module CoursesHelper
  def render_course_actions(item, size=nil)
    size = size.nil? ? "mini" : size
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-'+size+' btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      #if can? :read, Contact
      #  actions += '<li>'+item.student_list_link+'</li>'        
      #end
      
      if can? :update, item
        actions += '<li>'+item.course_link("Edit", courses_path(tab_page: 1))+'</li>'        
      end
      
      if can? :destroy, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Destroy', {controller: "courses", action: "destroy", id: item.id}, method: :delete, data: { confirm: 'Are you sure?' })+'</li>'        
      end 
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
  def render_student_courses_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
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
end
