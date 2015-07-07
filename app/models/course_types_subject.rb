class CourseTypesSubject < ActiveRecord::Base
  include PgSearch
  
  belongs_to :course_type
  belongs_to :subject
  
  pg_search_scope :search,
                against: [],
                associated_against: {
                  course_type: [:name, :short_name],
                  subject: [:name]
                },
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def self.full_text_search(q)
    self.search(q).limit(50).map {|model| {:id => model.display_id, :text => model.display_name} }
  end
  
  def display_id
    "#{course_type_id}_#{subject_id}"
  end
  
  def display_name
    "#{course_type.short_name}-#{subject.name}"
  end
  
end
