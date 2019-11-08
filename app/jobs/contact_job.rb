class ContactJob < ActiveJob::Base
  queue_as :default

  def perform(status, id)
    c = Contact.find(id)
    
    # Do something later
    case status
    when 'update_info'
      puts "#{status}: #{id}"
      c.do_update_info
      
    else
      puts "it was something else"
    end
  end
end
