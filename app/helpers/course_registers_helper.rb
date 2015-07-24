module CourseRegistersHelper
  def render_course_register_actions(item, size=nil)
    size = size.nil? ? "mini" : size
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-'+size+' btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      if can? :read, Course
        actions += '<li>'+ActionController::Base.helpers.link_to('View Detail', {controller: "course_registers", action: "show", id: item.id, tab_page: 1}, title: "Course Register Detail: #{item.contact.display_name}", class: "tab_page")+'</li>'
      end
      #
      #if can? :course_register, item
      #  actions += '<li>'+ActionController::Base.helpers.link_to('Add Course', {controller: "course_registers", action: "new", contact_id: item.id, tab_page: 1}, title: "#{item.display_name}: Course Register", class: "tab_page")+'</li>'        
      #end
      
      
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
end
