module BooksContactsHelper
  def render_books_contact_actions(item, size=nil)
    size = size.nil? ? "mini" : size
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-'+size+' btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      #group_1 = 0
      
      if can? :deliver_stock, item.course_register
        actions += '<li>'+ActionController::Base.helpers.link_to('Materials Delivery', {controller: "deliveries", action: "new", course_register_id: item.course_register_id, tab_page: 1}, psrc: delivery_books_path(tab_page: 1), title: "Deliver Stock: #{item.course_register.contact.display_name}", class: "tab_page")+'</li>'
        #group_1 += 1
      end
      
      #actions += '<li class="divider"></li>' if group_1 > 0
      
      
       
      if can? :delivery_print, item.course_register
        item.all_deliveries.each do |d|
          if can? :print, d
            actions += '<li>'+ActionController::Base.helpers.link_to("<i class=\"icon icon-print\"></i> Deliery [#{d.delivery_date.strftime("%d-%b-%Y")}]".html_safe, {controller: "deliveries", action: "show", id: d.id, tab_page: 1}, title: "#{item.contact.display_name}: Deliery [#{d.delivery_date.strftime("%d-%b-%Y")}]", class: "tab_page")+'</li>'
          end
        end
      end
      
      #item.all_payment_records.each do |pr|
      #  if can? :print, pr
      #    actions += '<li>'+ActionController::Base.helpers.link_to("<i class=\"icon icon-print\"></i> Receipt [#{pr.payment_date.strftime("%d-%b-%Y")}]".html_safe, {controller: "payment_records", action: "show", id: pr.id, tab_page: 1}, title: "#{item.contact.display_name}: Receipt [#{pr.payment_date.strftime("%d-%b-%Y")}]", class: "tab_page")+'</li>'
      #  end
      #end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
end
