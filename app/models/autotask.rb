class Autotask < ActiveRecord::Base
  validates :name, presence: true, :uniqueness => true
  
  has_many :autotask_details
  
  def self.run
    self.all.each do |t|
      if t.autotask_details.last.nil? || Time.now - t.autotask_details.last.created_at > t.time_interval
        t.process
      end
    end
  end
  
  def process    
      case self.name
      when "book_out_of_date"
          books = Book.main_books
          count = 0
          books.each do |o|
            if o.check_out_of_date
              count += 1
            end
          end          
          self.autotask_details.create(item_count: count)
      else
      end
  end
end
