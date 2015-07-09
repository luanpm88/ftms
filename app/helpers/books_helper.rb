module BooksHelper
  def render_book_actions(item)
    actions = '<div class="text-right"><div class="btn-group actions">
                    <button class="btn btn-mini btn-white btn-demo-space dropdown-toggle" data-toggle="dropdown">Actions <span class="caret"></span></button>'
      actions += '<ul class="dropdown-menu">'      
      
      if can? :new, item
        actions += '<li>'+ActionController::Base.helpers.link_to('New Volumn', {controller: "books", action: "new", parent_id: item.id, tab_page: 1}, psrc: books_path(tab_page: 1), title: "#{item.name}: New Volumn", class: "tab_page")+'</li>'        
      end
      
      if can? :update, item
        actions += '<li>'+ActionController::Base.helpers.link_to('Edit', {controller: "books", action: "edit", id: item.id, tab_page: 1}, psrc: books_path(tab_page: 1), title: item.name, class: "tab_page")+'</li>'        
      end
      
      actions += '</ul></div></div>'
      
      return actions.html_safe
  end
end
