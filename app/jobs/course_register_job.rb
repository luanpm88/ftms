class CourseRegisterJob < ActiveJob::Base
  queue_as :default

  def perform(status, id)
    c = CourseRegister.find(id)
    
    # Do something later
    case status
    when 'update_statuses'      
      c.do_update_statuses
      puts "#{status}: #{id}"
    
    when 'update_cache_search'
      c.do_update_cache_search
      puts "#{status}: #{id}" 
    else
      puts "it was something else"
    end
  end
end
