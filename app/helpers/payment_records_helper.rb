module PaymentRecordsHelper
  def render_payment_record_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      if can? :company_pay_remain, item
        actions += '<li>'+ActionController::Base.helpers.link_to("Pay", {controller: "payment_records", action: "company_pay", id: item.id, tab_page: 1}, title: "Pay", class: "tab_page")+'</li>'        
      end
      
      if item.company.nil?
        if can? :print, item
          actions += '<li>'+ActionController::Base.helpers.link_to("<i class=\"icon icon-print\"></i> Receipt [#{item.payment_date.strftime("%d-%b-%Y")}]".html_safe, {controller: "payment_records", action: "show", id: item.id, tab_page: 1}, title: "Receipt [#{item.payment_date.strftime("%d-%b-%Y")}]", class: "tab_page")+'</li>'        
        end
      else
        item.company_records.each do |pr|
          if can? :print, pr
            actions += '<li>'+ActionController::Base.helpers.link_to("<i class=\"icon icon-print\"></i> Receipt [#{pr.payment_date.strftime("%d-%b-%Y")}]".html_safe, {controller: "payment_records", action: "show", id: pr.id, tab_page: 1}, title: "Receipt [#{pr.payment_date.strftime("%d-%b-%Y")}]", class: "tab_page")+'</li>'        
          end
        end
      end
      
      if can? :trash, item
        actions += '<li>'+ActionController::Base.helpers.link_to("<i class=\"icon icon-trash\"></i> Delete".html_safe, {controller: "payment_records", action: "trash", id: item.id, tab_page: 1})+'</li>'  
      end
        
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
  
  def render_contacts_course_actions(item, size=nil)
    size = size.nil? ? "mini" : size
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-'+size+' btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'
      
      #group_1 = 0
      
      if can? :company_pay_remain, item
        actions += '<li>'+ActionController::Base.helpers.link_to("Pay", {controller: "payment_records", action: "company_pay", id: item.id, tab_page: 1}, title: "Pay", class: "tab_page")+'</li>'        
      end
      
      #actions += '<li class="divider"></li>' if group_1 > 0
       
      item.all_payment_records.each do |pr|
        if can? :print, pr
          actions += '<li>'+ActionController::Base.helpers.link_to("<i class=\"icon icon-print\"></i> Receipt [#{pr.payment_date.strftime("%d-%b-%Y")}]".html_safe, {controller: "payment_records", action: "show", id: pr.id, tab_page: 1}, title: "#{item.contact.display_name}: Receipt [#{pr.payment_date.strftime("%d-%b-%Y")}]", class: "tab_page")+'</li>'
        end
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
end
