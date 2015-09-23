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
    self.joins("LEFT JOIN course_types as course_types_2 ON course_types_2.id=course_types_subjects.course_type_id")
        .joins("LEFT JOIN subjects as subjects_2 ON subjects_2.id=course_types_subjects.subject_id")
        .where("course_types_2.parent_id IS NULL").where("course_types_2.status IS NOT NULL AND course_types_2.status LIKE ?", "%[active]%")
        .where("subjects_2.parent_id IS NULL").where("subjects_2.status IS NOT NULL AND subjects_2.status LIKE ?", "%[active]%")
        .search(q).limit(50).map {|model| {:id => model.display_id, :text => model.display_name} }
  end
  
  def display_id
    "#{course_type_id}_#{subject_id}"
  end
  
  def display_name
    "#{course_type.short_name}-#{subject.name}"
  end
  
end
