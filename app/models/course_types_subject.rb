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
    self.joins(:course_type, :subject)
        .where(course_types: {parent_id: nil}).where("course_types.status IS NOT NULL AND course_types.status LIKE ?", "%[active]%")
        .where(subjects: {parent_id: nil}).where("subjects.status IS NOT NULL AND subjects.status LIKE ?", "%[active]%")
        .map {|model| {:id => model.display_id, :text => model.display_name} } #.search(q).limit(50)
  end
  
  def display_id
    "#{course_type_id}_#{subject_id}"
  end
  
  def display_name
    "#{course_type.short_name}-#{subject.name}"
  end
  
end
