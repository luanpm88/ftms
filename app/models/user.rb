class User < ActiveRecord::Base
  include PgSearch
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  mount_uploader :image, AvatarUploader
  
  has_many :contacts
  
  has_many :assignments, :dependent => :destroy
  has_many :roles, :through => :assignments
  
  has_many :notifications, :dependent => :destroy, :foreign_key => "user_id"
  
  has_many :course_types
  has_many :subjects
  has_many :students, class_name: "Contact", :foreign_key => "account_manager_id"
  has_many :activities
  has_many :manage_activities, class_name: "Activity", :foreign_key => "account_manager_id"
  
  belongs_to :user, class_name: "User"
  
  #validates :first_name, presence: true
  #validates :last_name, presence: true
  validates :email, :presence => true, :uniqueness => true
  
  def active_for_authentication?
    # Uncomment the below debug statement to view the properties of the returned self model values.
    # logger.debug self.to_yaml

    super && status == 1
  end
  
  def self.main_users
    self.order("name")
  end
  
  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, :to => :ability
  
  def has_role?(role_sym)
    roles.any? { |r| r.name == role_sym }
  end
  
  def higher?(role)
    User.role_name_to_level(role) < self.level
  end
  
  def lower?(role)
    User.role_name_to_level(role) > self.level
  end
    
  def level
    roles.each do |r|
      if self.has_role?("admin")
        return User.role_name_to_level("admin")
      elsif self.has_role?("manager")
        return User.role_name_to_level("manager")
      elsif self.has_role?("education_consultant")
        return User.role_name_to_level("education_consultant")
      elsif self.has_role?("sales_admin")
        return User.role_name_to_level("sales_admin")
      elsif self.has_role?("user")
        return User.role_name_to_level("user")
      else
        return User.role_name_to_level("none")
      end      
    end
  end
  
  def self.role_name_to_level(role)
    if role == "admin"
      return 5
    elsif role == "manager"
      return 4
    elsif role == "education_consultant"
      return 3
    elsif role == "sales_admin"
      return 2
    elsif role == "user"
      return 1
    else
      return 0
    end
  end
  
  #def name
  #  if !first_name.nil?
  #    first_name + " " + last_name
  #  else
  #    email.gsub(/@(.+)/,'')
  #  end
  #end
  
  def short_name
    #if !first_name.nil?
    #  first_name + " " + last_name.split(" ").first
    #else
    #  email.gsub(/@(.+)/,'')
    #end
    name
  end
  
  def add_role(role)
    if self.has_role?(role.name)
      return false
    else
      self.roles << role
    end
  end
  
  def work_time_by_month(month, year)
    return (Checkinout.get_work_time_by_month(self, month, year)/3600).round(2).to_s
  end
  
  def addition_time(month, year)
    return ((Checkinout.get_work_time_by_month(self, month, year)/3600).round(2)-Checkinout.default_hours_per_month)
  end
  
  def addition_time_formatted(month, year)
    add_time = self.addition_time(month, year).round(2)
    if add_time < 0
      return "<span class='red'>"+add_time.to_s+"</span>"
    else
      return "<span class='green'>"+add_time.to_s+"</span>"
    end    
  end
  
  def checkinouts_by_month(month, year)
    time_string = year.to_s+"-"+month.to_s
    checks = []
    (1..31).each do |i|
      time = Time.zone.parse(time_string+"-"+i.to_s)
      if time.strftime("%m").to_i == month && time.wday != 0
        esxit = Checkinout.where(user_id: self.ATT_No, check_date: time.to_date)
        if esxit.count > 0
          checks << esxit.first        
        end
      end      
    end
    return checks
  end
  
  def avatar_path(version = nil)
    if self.image_url.nil?
      return "public/img/avatar.jpg"
    elsif !version.nil?
      return self.image_url(version)
    else
      return self.image_url
    end
  end
  
  def avatar(version = nil)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.url_for(controller: "users", action: "avatar", id: self.id, type: version)
  end
  
  def self.current_user
    Thread.current[:current_user]
  end
  
  pg_search_scope :search,
                against: [:name, :first_name, :last_name],                
                using: {
                    tsearch: {
                      dictionary: 'english',
                      any_word: true,
                      prefix: true
                    }
                }
  
  def self.full_text_search(q)
    result = self.order("name")
    result = result.search(q) if q.present?
    result = result.limit(50).map {|model| {:id => model.id, :text => model.name} }
    
    return result
  end
  
  def notification_unread_count
    notifications.where(viewed: 0).count
  end
  
  def notification_top
    notifications.where(viewed: 0).order("created_at DESC").limit(20)
  end
  
  def self.backup_system(params)
    System.backup(params)
  end
  
  def display_statuses
    s = status == 1 ? "active" : "deleted"
    result = ["<span title=\"\" class=\"badge user-role badge-info contact-status #{s}\">#{s}</span>"]
    result.join(" ").html_safe
  end

                
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.all
    
    if params["status"].present?
      @records = @records.where(status: params["status"])
    end
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "users.name"
      when "3"
        order = "users.created_at"
      else
        order = "users.first_name, users.last_name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "users.name"
    end
    
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 6
    @records.each do |item|
      item = [
              link_helper.link_to("<img class=\"avatar-big\" width='60' src='#{item.avatar(:square)}' />".html_safe, {controller: "users", action: "show", id: item.id}, class: "fancybox.ajax fancybox_link main-title"),
              '<div class="text-left main-title">'+item.name+"</div>"+item.quick_info, #link_helper.link_to(item.name, {controller: "users", action: "edit", id: item.id, tab_page: 1}, title: "#{item.name}", class: "main-title tab_page")+item.quick_info,
              '<div class="text-center">'+item.roles_name+"</div>",
              '<div class="text-center">'+item.created_at.strftime("%Y-%m-%d")+"</div>",
              '<div class="text-center">'+item.display_staff_col+"</div>",
              '<div class="text-center">'+item.display_statuses+"</div>",
              '',
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
  
  def display_staff_col
    user.nil? ? "" : user.staff_col
  end
  
  def roles_name
    names = []
    roles.order("name").each do |r|
      names << "<span class=\"badge user-role badge-info #{r.name}\">#{r.name}</span>"
    end
    return names.join(" ").html_safe
  end
  
  def quick_info
    info = email
    info += "<br />Mobile: #{mobile}" if mobile.present?
    
    return info.html_safe
  end
  
  def activity_log(from_date, to_date)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    history = []
    
    # Note Log
    
    
    return history.sort {|a,b| b[:date] <=> a[:date]}
  end
  
  def staff_col
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.link_to("<img class=\"round-ava\" src=\"#{self.avatar(:square)}\" width=\"35\" /><br /><span class=\"user-name\" />#{self.short_name}</span>".html_safe, {controller: "users", action: "show", id: self.id}, title: self.name, class: "fancybox.ajax fancybox_link")
  end
  
  def user_link(title=nil)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    title = title.nil? ? name : title
    
    link_helper.link_to(title, {controller: "users", action: "edit", id: id, tab_page: 1}, class: "tab_page", title: name)
  end
  
  def self.restore_system(params)
    rails_env = params[:environment]
    bk_dir = Setting.get("backup_dir")
    database = YAML.load_file('config/database.yml')[rails_env]["database"]
    
    `mkdir tmp` if !File.directory?("tmp")
    `mkdir tmp/backup` if !File.directory?("tmp/backup")
    
    file_upload = params[:upload]
    
    # SAVE TO TMP
    name =  file_upload['datafile'].original_filename
    directory = "tmp/backup"
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(file_upload['datafile'].read) }
    
    # CHECK PACKAGE
    `rm -rf tmp/backup#{bk_dir} && unzip #{path} -d tmp/backup/`
    
    if File.directory?("tmp/backup#{bk_dir}/#{name.gsub(".zip","")}/uploads") && params[:file].present?
      `rm -rf uploads && mkdir uploads && cp -a tmp/backup#{bk_dir}/#{name.gsub(".zip","")}/uploads/. uploads/`
    end
    
    if File.exist?("tmp/backup#{bk_dir}/#{name.gsub(".zip","")}/data.dump") && params[:database].present?
      `RAILS_ENV=#{rails_env} rake mytask:drop_all_table && RAILS_ENV=#{rails_env} rake db:migrate && psql #{database} < tmp/backup#{bk_dir}/#{name.gsub(".zip","")}/data.dump`
    end
    
    `rm -rf tmp/backup#{bk_dir} && rm #{path}`
    
  end
  
  # "Book"
  # "BookData"
  # "Companies"
  ###SAVED############################# "Counsultant"
  # "Course"
  ###SAVED############################# "CourseType"
  ############EMPTY#################### "CusDetail"
  # "Delivery"
  # "Invoice"
  # "InvoiceDetail"
  # "LinkStudent"
  # "NoteDetail"
  ### "Student"
  ############EMPTY#################### "Student_temp"
  ###SAVED############################# "Subject"
  ############EMPTY#################### "Ucrs"
  ############NO NEEDED################ "UserLevel"
  ############NO NEEDED################ "UserRole"
  ############EMPTY#################### "Venue"
  # "Tags"
  def self.import_from_old_sustem(file)
    dir = "tmp"
    file_name =  file.original_filename
    file_path = File.join(dir, file_name)
    File.open(file_path, "wb") { |f| f.write(file.read) }
    
    database = Mdb.open(file_path)
    result = {contacts: [], course_types: [], subjects: [], subjects_tmp: [], users: []}
    
    #### STUDENT
    #database[:Student].each do |row|
    #  contact = Contact.new
    #  contact.tmp_StudentID = row[:StudentID]
    #  contact.name = row[:StudentName]
    #  contact.birthday = row[:StudentBirth].to_date
    #  contact.address = row[:StudentHomeAdd]
    #  contact.email = row[:StudentEmail1] if row[:StudentEmail1].present?
    #  contact.email_2 = row[:StudentEmail2]
    #  contact.mobile = row[:StudentHandPhone] if row[:StudentHandPhone].present?
    #  contact.mobile_2 = row[:StudentOffPhone]
    #  contact.phone = row[:StudentHomePhone]
    #  contact.fax = row[:StudentFax]
    #  contact.sex = row[:StudentTitle] == "2" ? "female" : "male"
    #  
    #                    
    #  result[:contacts] << contact
    #end
    #
    ### COURSE TYPE ### SAVED ### 
    CourseType.destroy_all
    database[:CourseType].each do |row|
      item = CourseType.new
      item.tmp_CourseTypeID = row[:CourseTypeID]
      item.name = row[:CourseTypeName]
      item.short_name = row[:CourseTypeShortName].nil? ? row[:CourseTypeName] : row[:CourseTypeShortName]
      item.user = User.first
      item.save
      item.add_status("active")
      item.save_draft(User.first)
    
      result[:course_types] << item
    end
    
    # SUBJECT ### SAVED ### 
    Subject.destroy_all
    database[:Subject].each do |row|
      item = Subject.new
      item.tmp_SubjectID = row[:SubjectID]
      
      if !row[:SubjectID].split(row[:CourseID])[1].nil?
        subject_name = User.remove_head_draft(row[:SubjectID].split(row[:CourseID])[1])
        item.name = subject_name
        
        # find course type
        ct = CourseType.where(short_name: row[:SubjectID].split(row[:CourseID])[0]).first
        if !ct.nil?
          # find exist subject
          s = Subject.where("LOWER(name) = ?",subject_name.downcase).first
          
          if !s.nil?
            s.course_types << ct if !s.course_types.include?(ct)
            #s.save
          else
            item.course_types << ct
            item.save
            item.add_status("active")
            item.save_draft(User.first)
          end
          
        end
      end
      
      
      result[:subjects] << item
      result[:subjects_tmp] << row
    end
    
    ### USER
    User.where.not(tmp_ConsultantID: nil).destroy_all
    database[:COUNSULTANT].each_with_index do |row,index|
      item = User.new(:email => "unknown#{index}@ftmsglobal.edu.vn", :password => "aA456321@", :password_confirmation => "aA456321@")
      item.tmp_ConsultantID = row[:ConsultantID]
      #item.first_name = row[:ConsultantName].split(" ").last
      #item.last_name = row[:ConsultantName].split(" ")
      item.name = row[:ConsultantName].strip
    
      item.roles << Role.where(name: "user").first
      # item.roles << Role.where(name: "education_consultant").first
      
      item.save
      
    
      result[:users] << item
    end
    
    
    return result
  end
  
  def self.remove_head_draft(s)
    count = 1
    r = s
    s.each_char do |c|
      if /[[:alnum:]]/.match(c).nil?
        r = s[count..-1]
      else
        break
      end
      count += 1
    end
    return r.strip
  end
  
  def self.get_cima_report(year, month, course_types)
    courses = Course.all_courses
                      .where(course_type_id: course_types)
                      .where(for_exam_year: year)
                      .where(for_exam_month: month)
                      
    subjects = Subject.active_subjects.includes(:course_types).where(course_types: {id: course_types})
    
    conds = []
    courses.each do |c|
      conds << "contacts.cache_courses LIKE '%[#{c.id.to_s},%'"
    end
    students = !conds.empty? ? Contact.main_contacts.where(conds.join(" OR ")).order("name") : []
                                    
    report = []
    students.each do |student|
      has_course = false
      
      row = {}
      row["student"] = student
      row["subjects"] = []
      subjects.each do |subject|
        s_row = {}
        s_row["subject"] = subject
        
        arr = []
        student.active_courses_with_phrases.each do |r|
          arr << r[:course].name if courses.include?(r[:course]) && !r[:course].upfront && course_types.include?(r[:course].course_type_id.to_s) && r[:course].subject.id == subject.id && !r[:course].no_report_contacts.include?(student)
        end
        #ccs = student.active_contacts_courses.where(report: true).includes(:course).where(courses: {subject_id: subject.id})
        s_row["count"] = arr.join("\n") if !arr.empty?
        
        row["subjects"] << s_row
        
        has_course = true if !arr.empty?
      end
      report << row if has_course
    end

    return {data: report, subjects: subjects}
  end
  
  def self.get_acca_report(year, month, course_types)
    courses = Course.all_courses
                      .where(course_type_id: course_types)
                      .where(for_exam_year: year)
                      .where(for_exam_month: month)
                      
    subjects = Subject.active_subjects.includes(:course_types).where(course_types: {id: course_types})
        
    conds = []
    courses.each do |c|
      conds << "contacts.cache_courses LIKE '%[#{c.id.to_s},%'"
    end
    students = !conds.empty? ? Contact.main_contacts.where(conds.join(" OR ")).order("name") : []
                                    
    report = []
    students.each do |student|
      has_course = false
      
      row = {}
      row["student"] = student
      row["subjects"] = []
      subjects.each do |subject|
        s_row = {}
        s_row["subject"] = subject
        
        arr = []
        student.active_courses_with_phrases.each do |r|
          arr << r[:course].name if courses.include?(r[:course]) && !r[:course].upfront && course_types.include?(r[:course].course_type_id.to_s) && r[:course].subject.id == subject.id && !r[:course].no_report_contacts.include?(student)
        end
        #ccs = student.active_contacts_courses.where(report: true).includes(:course).where(courses: {subject_id: subject.id})
        s_row["count"] = arr.join("\n") if !arr.empty?
        
        row["subjects"] << s_row if s_row["count"].present?
        
        has_course = true if !arr.empty?
      end
      report << row if has_course
    end
                      
    return {data: report, subjects: subjects}
  end

  def self.import_from_old_system(file)
    dir = "tmp"
    file_name =  file.original_filename
    file_path = File.join(dir, file_name)
    File.open(file_path, "wb") { |f| f.write(file.read) }
    
    database = Mdb.open(file_path)
    
    OldBook.import_old_book(database)
    OldBookDatum.import_old_book_data(database)
    OldCompany.import_old_company(database)
    OldConsultant.import_old_consultant(database)
    OldCourse.import_old_course(database)
    OldCourseType.import_old_course_type(database)
    OldDelivery.import_old_delivery(database)
    OldInvoice.import_old_invoice(database)
    OldInvoiceDetail.import_old_invoice_detail(database)
    OldLinkStudent.import_old_link_student(database)
    OldNoteDetail.import_old_note_detail(database)
    OldStudent.import_old_student(database)
    OldSubject.import_old_subject(database)
    OldTag.import_old_tag(database)
    OldUserLevel.import_old_user_level(database)
    OldUserRole.import_old_user_role(database)
    
    # import consultant
    self.import_from_old_consultant
    
    # import contact
    Contact.import_contact_from_old_student
    
    # update company
    Contact.update_company_info_from_old_system
    
    return true
  end

  def self.import_from_old_consultant
    ### USER
    OldConsultant.all.each_with_index do |row,index|
      if User.where(tmp_ConsultantID: row.consultant_id).empty?
        item = User.new(:email => "unknown#{index}@ftmsglobal.edu.vn", :password => "aA456321@", :password_confirmation => "aA456321@")
        item.tmp_ConsultantID = row.consultant_id
        #item.first_name = row[:ConsultantName].split(" ").last
        #item.last_name = row[:ConsultantName].split(" ")
        item.name = row.consultant_name.strip
      
        item.roles << Role.where(name: "user").first
        # item.roles << Role.where(name: "education_consultant").first
        uu = User.where(:email => "admin@ftmsglobal.edu.vn").first
        uu = User.first if uu.nil?
        item.user_id = uu.id
        
        item.save
        
      end
    end
  end
  
  def self.status_options
    [
      ["Active","1"],
      ["Deleted","0"],
      ["All",""]      
    ]
  end
  
  def self.statistics(users, from_date, to_date)
    from_date = from_date.beginning_of_day
    to_date = to_date.end_of_day
    user_ids = users.map(&:id)
    
    course_types = CourseType.main_course_types.order("short_name")
    course_types << CourseType.new(id: -1, short_name: "Defer/Transfer")
    course_type_ids = course_types.map(&:id)
      
    # prepaire array
    users_statistics = {}
    users.each do |u|
      row = {}
      row[:user] = u
      row[:note] = 0
      row[:paper] = 0
      row[:inquiry] = 0
      row[:student] = 0
      row[:course_type] = nil
      row[:sales] = 0.0
      row[:receivable] = 0.0
      row[:details] = {}
      course_types.each do |ct|
        row_2 = {
                  course_type: ct,
                  paper: 0,
                  inquiry: 0,
                  student: 0,
                  sales: 0.0,
                  receivable: 0.0,
                  receivable_contacts: []
                }
        row[:details][ct.id] = row_2
      end
      users_statistics[u.id] = row
    end
    
    # sales
    total = 0.0
    @records = PaymentRecord.includes(:course_register => :contact)
                          .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status NOT LIKE ?", "%[deleted]%")
                          .where(status: 1)
                          .where(course_registers: {account_manager_id: user_ids})
                          .where("payment_records.payment_date >= ? AND payment_records.payment_date <= ? ", from_date, to_date).uniq
    
    @records.each do |pr|
      pr.payment_record_details.each do |prd|
        if !prd.contacts_course.nil?
          users_statistics[pr.course_register.account_manager_id][:details][prd.contacts_course.course.course_type_id][:sales] += prd.real_amount if users_statistics[pr.course_register.account_manager_id][:details][prd.contacts_course.course.course_type_id].present?
          users_statistics[pr.course_register.account_manager_id][:sales] += prd.real_amount
        elsif !prd.books_contact.nil?
          users_statistics[pr.course_register.account_manager_id][:details][prd.books_contact.book.course_type_id][:sales] += prd.real_amount if users_statistics[pr.course_register.account_manager_id][:details][prd.books_contact.book.course_type_id].present?
          users_statistics[pr.course_register.account_manager_id][:sales] += prd.real_amount
        end
      end
    end
    
    # transfer sales
    @records = PaymentRecord.includes(:transfer => :contact)
                          .where(transfers: {parent_id: nil}).where("transfers.status IS NOT NULL AND transfers.status NOT LIKE ?", "%[deleted]%")
                          .where(status: 1)
                          .where(contacts: {account_manager_id: user_ids})
                          .where("payment_records.payment_date >= ? AND payment_records.payment_date <= ? ", from_date, to_date).uniq
    @records.each do |pr|
        users_statistics[pr.contact.account_manager_id][:details][-1][:sales] += pr.amount if users_statistics[pr.contact.account_manager_id][:details][-1].present?
        users_statistics[pr.contact.account_manager_id][:sales] += pr.amount
    end
    
    
    ## company sales
    @records = PaymentRecord.where(status: 1)
                          .where(account_manager_id: user_ids)
                          .where("payment_records.payment_date >= ? AND payment_records.payment_date <= ? ", from_date, to_date)
    @records.each do |pr|
      pr.payment_record_details.each do |prd|
        users_statistics[pr.contact.account_manager_id][:details][prd.course_type_id][:sales] += prd.real_amount if users_statistics[pr.contact.account_manager_id][:details][prd.course_type_id].present?
        users_statistics[pr.contact.account_manager_id][:sales] += prd.real_amount
      end
    end
    
    
    
    
    # receivable
              #contacts courses
              contacts_courses = ContactsCourse.includes(:course_register, :course => :course_type)
                                                .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status NOT LIKE ?", "%[deleted]%")
                                                .where(course_types: {id: course_type_ids})
                                                .where(course_registers: {account_manager_id: user_ids})
                                                .where("course_registers.created_at >= ? AND course_registers.created_at <= ? ", from_date, to_date)
              
              contacts_courses.each do |cc|                
                if !cc.course_register.paid?(to_date.end_of_day)
                  if users_statistics[cc.course_register.account_manager_id][:details][cc.course.course_type_id].present?
                    users_statistics[cc.course_register.account_manager_id][:details][cc.course.course_type_id][:receivable] += cc.remain(from_date, to_date)
                    users_statistics[cc.course_register.account_manager_id][:details][cc.course.course_type_id][:receivable_contacts] << cc.contact
                  end
                  users_statistics[cc.course_register.account_manager_id][:receivable] += cc.remain(from_date, to_date)
                end
              end
              
              
              
              #books courses
              books_contacts = BooksContact.includes(:course_register, :book => :course_type)
                                                .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status NOT LIKE ?", "%[deleted]%")
                                                .where(course_types: {id: course_type_ids})
                                                .where(course_registers: {account_manager_id: user_ids})
                                                .where("course_registers.created_at >= ? AND course_registers.created_at <= ? ", from_date, to_date)
              
              books_contacts.each do |cc|                
                if !cc.course_register.paid?(to_date.end_of_day)
                  if users_statistics[cc.course_register.account_manager_id][:details][cc.book.course_type_id].present?
                    users_statistics[cc.course_register.account_manager_id][:details][cc.book.course_type_id][:receivable] += cc.remain_amount(from_date, to_date)
                    users_statistics[cc.course_register.account_manager_id][:details][cc.book.course_type_id][:receivable_contacts] << cc.contact
                  end
                  users_statistics[cc.course_register.account_manager_id][:receivable] += cc.remain_amount(from_date, to_date)
                end
              end
              

                #transfers
                transfers = Transfer.includes(:contact).where(parent_id: nil).where("transfers.status IS NOT NULL AND transfers.status NOT LIKE ?", "%[deleted]%")
                                                  .where(contacts: {account_manager_id: user_ids})
                                                  .where("transfers.created_at >= ? AND transfers.created_at <= ? ", from_date, to_date)
                                       
                transfers.each do |tsf|
                  if tsf.remain(from_date, to_date) != 0.0 
                    if users_statistics[tsf.contact.account_manager_id][:details][cc.course.course_type_id].present?
                      users_statistics[tsf.contact.account_manager_id][:details][-1][:receivable] += tsf.remain(from_date, to_date)
                      users_statistics[tsf.contact.account_manager_id][:details][-1][:receivable_contacts] << tsf.contact
                    end
                    users_statistics[tsf.contact.account_manager_id][:receivable] += cc.remain(from_date, to_date)
                  end
                end
                
    # Inquiry # Student
        @contacts = Contact.main_contacts.includes(:contact_types, :course_types)
                            .where(creator_id: user_ids)
                            .where(is_individual: true)
                            .where("contacts.created_at >= ? AND contacts.created_at <= ? ", from_date, to_date)
        
        @contacts.each do |c|
          course_types.each do |ct|
              transform = 0            
              if c.course_types.include?(ct) && c.contact_types.include?(ContactType.inquiry)
                users_statistics[c.creator_id][:details][ct.id][:inquiry] += 1
                users_statistics[c.creator_id][:inquiry] += 1
                
                # find transform revision
                transform_revision_count = c.revisions.includes(:contact_types)
                                                      .where(contact_types: {id: ContactType.student.id})
                                                      .where("contacts.created_at >= ? AND contacts.created_at <= ? ", from_date, to_date)
                                                      .count
                if transform_revision_count > 0
                  transform = 1
                end
              end
              if c.contact_types.include?(ContactType.inquiry) && c.course_types.empty?
                users_statistics[c.creator_id][:inquiry] += 1
              end
              
              if c.cache_course_type_ids.present? && c.cache_course_type_ids.include?("[#{ct.id}]") && c.contact_types.include?(ContactType.student)          
                users_statistics[c.creator_id][:details][ct.id][:student] += 1
                student_total += 1
              end
              
              users_statistics[c.creator_id][:details][ct.id][:inquiry] -= transform
              users_statistics[c.creator_id][:inquiry] -= transform
              users_statistics[c.creator_id][:details][ct.id][:student] += transform
              users_statistics[c.creator_id][:student] += transform
          end
        end

        
        
        # Paper
        paper = 0
        @papers = ContactsCourse.includes(:course_register, :contact, :course => :course_type)
                            .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status NOT LIKE ?", "%[deleted]%")
                            .where(course_registers: {account_manager_id: user_ids})
                            .where(course_types: {id: course_type_ids})
                            .where("course_registers.created_at >= ? AND course_registers.created_at <= ? ", from_date, to_date)
        
        @papers.each do |cc|
          users_statistics[cc.course_register.account_manager_id][:details][cc.course.course_type_id][:paper] += 1
          users_statistics[cc.course_register.account_manager_id][:paper] += 1
        end
        
        
        users.each do |u|
          users_statistics[u.id][:note] = u.manage_activities
                                            .where("activities.created_at >= ? AND activities.created_at <= ? ", from_date, to_date)
                                            .count
        end

        
        all_total = {note: 0,paper: 0,inquiry: 0,student: 0,sales: 0.0,receivable: 0.0}
        users_statistics.each do |u|
          all_total[:note] += u[1][:note]
          all_total[:paper] += u[1][:paper]
          all_total[:inquiry] += u[1][:inquiry]
          all_total[:student] += u[1][:student]
          all_total[:sales] += u[1][:sales]
          all_total[:receivable] += u[1][:receivable]
        end
        
    
    return {data: users_statistics, total: all_total}
  end
  
end
