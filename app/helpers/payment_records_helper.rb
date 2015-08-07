module PaymentRecordsHelper
  def render_payment_record_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      if can? :print, item
        actions += '<li>'+ActionController::Base.helpers.link_to("<i class=\"icon icon-print\"></i> Receipt [#{item.payment_date.strftime("%d-%b-%Y")}]".html_safe, {controller: "payment_records", action: "show", id: item.id, tab_page: 1}, title: "Receipt [#{item.payment_date.strftime("%d-%b-%Y")}]", class: "tab_page")+'</li>'        
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
end
