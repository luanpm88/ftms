class ContactTag < ActiveRecord::Base
  include PgSearch
  validates :name, presence: true, :uniqueness => true
  
  has_and_belongs_to_many :contacts
  
  pg_search_scope :search,
                against: [:name, :description],                
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def self.full_text_search(q)    
    self.search(q).limit(50).map {|model| {:id => model.id, :text => model.name} }
  end
end
