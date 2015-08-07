module BooksHelper
  def render_book_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      if can? :create, StockUpdate
        actions += '<li>'+ActionController::Base.helpers.link_to('Import/Export', {controller: "stock_updates", action: "new", book_id: item.id, tab_page: 1}, psrc: books_path(tab_page: 1), title: "#{item.name}: Import/Export", class: "tab_page")+'</li>'        
      end
      
      if can? :update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Edit', {controller: "books", action: "edit", id: item.id, tab_page: 1}, psrc: books_path(tab_page: 1), title: item.name, class: "tab_page")+'</li>'        
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
  def render_student_book_actions(item, student)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      delivery_details = item.delivery_details.joins(:delivery => :course_register).where(course_registers: {contact_id: student.id})
      
      if can? :delivery_print, CourseRegister
        delivery_details.each do |dd|
          d = dd.delivery
          if can? :print, 
            actions += '<li>'+ActionController::Base.helpers.link_to("<i class=\"icon icon-print\"></i> Deliery [#{d.delivery_date.strftime("%d-%b-%Y")}]".html_safe, {controller: "deliveries", action: "show", id: d.id, tab_page: 1}, title: "#{d.course_register.contact.display_name}: Deliery [#{d.delivery_date.strftime("%d-%b-%Y")}]", class: "tab_page")+'</li>'
          end
        end
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
end
