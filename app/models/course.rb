class Course < ActiveRecord::Base
  include PgSearch
  
  validates :course_type, :presence => true
  validates :subject_id, :presence => true
  
  validate :course_exist
  
  belongs_to :user
  belongs_to :course_type
  belongs_to :subject
  
  belongs_to :lecturer, :class_name => "Contact"
  
  has_and_belongs_to_many :contacts
  has_many :contacts_courses
  
  has_many :courses_phrases
  has_and_belongs_to_many :phrases
  
  pg_search_scope :search,
                  against: [:description],
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
    self.order("courses.intake DESC").search(q).limit(50).map {|model| {:id => model.id, :text => model.display_name} }
  end
  
  def course_exist
    exist = Course.where("course_type_id = ? AND subject_id = ? AND EXTRACT(YEAR FROM courses.intake) = ? AND EXTRACT(MONTH FROM courses.intake) = ?",
                          self.course_type_id, self.subject_id, self.intake.year, self.intake.month
                        )
    
    if self.id.nil? && exist.length > 0
      errors.add(:base, "Course exists")
    end
    
  end
  
  def self.filters(params, user)
    @records = self.joins(:course_type,:subject)
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    @records = @records.where("EXTRACT(YEAR FROM courses.intake) = ? ", params["intake_year"]) if params["intake_year"].present?
    @records = @records.where("EXTRACT(MONTH FROM courses.intake) = ? ", params["intake_month"]) if params["intake_month"].present?
    @records = @records.where("courses.course_type_id IN (#{params["course_types"].join(",")})") if params["course_types"].present?
    @records = @records.where("courses.subject_id IN (#{params["subjects"].join(",")})") if params["subjects"].present?
    
    if params["students"].present?
      @records = @records.joins(:contacts)
      @records = @records.where("contacts.id IN (#{params["students"]})") if params["students"].present?
    end
    
    if params["lecturers"].present?
      @records = @records.where("courses.lecturer_id IN (#{params["lecturers"]})") if params["lecturers"].present?
    end
    
    return @records
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records =  self.filters(params, user)
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "0"
        order = "courses.intake #{params["order"]["0"]["dir"]}, course_types.short_name, subjects.name"
      when "1"
        order = "course_types.short_name #{params["order"]["0"]["dir"]}, subjects.name"
      when "4"
        order = "courses.created_at"
      else
        order = "courses.created_at"
      end
      order += " "+params["order"]["0"]["dir"] if !["0","1"].include?(params["order"]["0"]["column"])
    else
      order = "courses.intake DESC"
    end
    
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 7
    @records.each do |item|
      item = [
              '<div class="text-left nowrap">'+item.display_intake+"</div>",
              '<div class="text-left nowrap">'+item.program_paper_name+"</div>",
              '<div class="text-left">'+item.courses_phrase_list+"</div>",
              '<div class="text-center">'+item.student_count_link+"</div>",
              '<div class="text-center nowrap">'+item.display_lecturer+"</div>",
              '<div class="text-center">'+item.created_at.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-center">'+item.user.staff_col+"</div>",
              "", 
            ]
      data << item
      
    end
    
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    return {result: result, items: @records, actions_col: actions_col}
    
  end
  
  
  
  def self.student_courses(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @student = Contact.find(params[:students])
    
    @records =  self.filters(params, user)
    
    @records = @records.includes(:contacts_courses => :course_register)
    @records = @records.where(contacts_courses: {contact_id: @student.id})
    
    
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "0"
        order = "courses.intake #{params["order"]["0"]["dir"]}, course_types.short_name, subjects.name"
      when "1"
        order = "course_types.short_name #{params["order"]["0"]["dir"]}, subjects.name"
      when "3"
        order = "course_registers.created_date"
      else
        order = "course_registers.created_date"
      end
      order += " "+params["order"]["0"]["dir"] if !["0","1"].include?(params["order"]["0"]["column"])
    else
      order = "course_registers.created_date DESC"
    end
    
    @records = @records.order(order) if !order.nil?
    
    #@records = @records.group_by(&:course)
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    

    actions_col = 5

    @records.each do |item|
      itemz = [
              '<div class="text-left nowrap">'+item.display_intake+"</div>",
              '<div class="text-left nowrap">'+item.program_paper_name+"</div>",              
              '<div class="text-left">'+item.courses_phrase_list_by_sudent(@student)+"</div>",
              '<div class="text-center nowrap">'+item.display_lecturer+"</div>",
              '<div class="text-center">'+item.contacts_course(@student).created_at.strftime("%d-%b-%Y")+"</div>",              
              "", 
            ]
      

        data << itemz
    end
    
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    return {result: result, items: @records, actions_col: actions_col}
    
  end
  
  def courses_phrase_list
    arr = []
    courses_phrases.each do |p|
      arr << "#{p.phrase.name} [#{p.start_at.strftime("%d-%b-%Y")}]"
    end
    arr.join("<br />").html_safe
  end
  
  def courses_phrase_list_by_sudent(student)
    arr = []
    courses_phrases_by_sudent(student).each do |p|
      arr << "#{p.phrase.name} [#{p.start_at.strftime("%d-%b-%Y")}]"
    end
    arr.join("<br />").html_safe
  end
  
  def courses_phrases_by_sudent(student)
    cc = contacts_course(student)
    if !cc.nil?
      return CoursesPhrase.where(id: (JSON.parse(contacts_course(student).courses_phrase_ids)))
    else
      return []
    end
  end
  
  def contacts_course(student)
    contacts_courses.where(contact_id: student.id).first
  end
  
  def course_register(student)
    CourseRegister.find(contacts_course(student).course_register_id)
  end
  
  
  def display_name
    display_intake.to_s+"-"+program_paper_name.to_s
  end
  
  def display_lecturer
    !lecturer.nil? ? lecturer.contact_link : ""
  end
  
  def name
    intake.strftime("%b")+"-"+intake.year.to_s+"-"+course_type.short_name+"-"+subject.name
  end
  
  def display_intake
    intake.strftime("%b")+"-"+intake.year.to_s
  end
  
  def update_program_paper(sid)
    return false if sid.nil?
    
    ct = CourseType.find(sid.split("_")[0])
    sj = Subject.find(sid.split("_")[1])
    
    if !ct.nil? && !sj.nil?
      self.course_type = ct
      self.subject = sj
    end
    
  end
  
  def program_paper_id
    "#{course_type.id}_#{subject.id}" if course_type.present? && subject.present?
  end
  
  def program_paper_name
    "#{course_type.short_name}-#{subject.name}" if course_type.present? && subject.present?
  end
  
  def student_list_link(title=nil)
    title = title.nil? ? "Student List (#{contacts.count.to_s})" : title
    ActionController::Base.helpers.link_to(title, {controller: "courses", action: "edit", id: id, tab_page: 1, tab: "student"}, title: "#{display_name}: Student List", class: "tab_page")
  end
  
  def student_count_link
    student_list_link("["+contacts.count.to_s+"]")
  end
  
  def course_link(title=nil, psrc=nil)
    title = title.nil? ? name : title
    ActionController::Base.helpers.link_to(title, {controller: "courses", action: "edit", id: id, tab_page: 1}, psrc: psrc, title: name, class: "tab_page")
  end
  
  def update_courses_phrases(params)
    courses_phrases.destroy_all
    params.each do |row|
      if row[1]["phrase_id"].present?
        courses_phrases.create(phrase_id: row[1]["phrase_id"],
                        start_at: row[1]["start_at"]
                      )
      end
    end
  end
  
end
