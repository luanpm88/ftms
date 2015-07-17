module ContactsHelper
  
  def render_contacts_actions(item, size=nil)
    size = size.nil? ? "mini" : size
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-'+size+' btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      #if can? :read, Course
      #  actions += '<li>'+item.course_list_link+'</li>'        
      #end
      
      if can? :course_register, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Add Course', {controller: "course_registers", action: "new", contact_id: item.id, tab_page: 1}, title: "#{item.display_name}: Course Register", class: "tab_page")+'</li>'        
      end
      
      
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
  def render_contact_tags_selecter(item)
    actions = '<div class="" rel="'+item.id.to_s+'"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle tag_button '+item.contact_tag.name.downcase.gsub(" ","_")+'" data-toggle="dropdown" title="'+item.contact_tag.description+'">'+item.contact_tag.name+' <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      ContactTag.all.each do |tag|
        actions += '<li rel="'+item.id.to_s+'" tag_id="'+tag.id.to_s+'" class="contact_tag_item '+tag.name.downcase.gsub(" ","_")+'">'+ActionController::Base.helpers.link_to(tag.name, "#", title: tag.description)+'</li>'        
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
end
