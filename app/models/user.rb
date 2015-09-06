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
  
  #validates :first_name, presence: true
  #validates :last_name, presence: true
  validates :email, :presence => true, :uniqueness => true
  
  
  
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
    self.search(q).limit(50).map {|model| {:id => model.id, :text => model.name} }
  end
  
  def notification_unread_count
    notifications.where(viewed: 0).count
  end
  
  def notification_top
    notifications.where(viewed: 0).order("created_at DESC").limit(20)
  end
  
  def self.backup_system(params)
    dir = Time.now.strftime("%Y_%m_%d_%H%M%S")
    dir += "_db" if !params[:database].nil?
    dir += "_source" if !params[:file].nil?
    
    `mkdir backup` if !File.directory?("backup")
    `mkdir backup/#{dir}`
    
    backup_cmd = ""
    backup_cmd += "pg_dump -a ftms_#{params[:environment]} >> backup/#{dir}/data.dump && " if params[:database].present? && params[:environment].present?
    backup_cmd += "cp -a uploads backup/#{dir}/ && " if !params[:file].nil?
    backup_cmd += "zip -r backup/#{dir}.zip backup/#{dir} && "
    backup_cmd += "rm -rf backup/#{dir}"
    
    `#{backup_cmd} &`
    
    if !File.directory?(dir)
      `rm -rf backup/#{dir}`
    end
    
    
  end

                
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.all
    
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
    
    actions_col = 4
    @records.each do |item|
      item = [
              link_helper.link_to("<img class=\"avatar-big\" width='60' src='#{item.avatar(:square)}' />".html_safe, {controller: "users", action: "show", id: item.id}, class: "fancybox.ajax fancybox_link main-title"),
              link_helper.link_to(item.name, {controller: "users", action: "edit", id: item.id, tab_page: 1}, title: "#{item.name}", class: "main-title tab_page")+item.quick_info,
              '<div class="text-center">'+item.roles_name+"</div>",
              '<div class="text-center">'+item.created_at.strftime("%Y-%m-%d")+"</div>", 
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
    `rm -rf tmp/backup/backup && unzip #{path} -d tmp/backup/`
    
    if File.directory?("tmp/backup/backup/#{name.gsub(".zip","")}/uploads") && params[:file].present?
      `rm -rf uploads && mkdir uploads && cp -a tmp/backup/backup/#{name.gsub(".zip","")}/uploads/. uploads/`
    end
    
    if File.exist?("tmp/backup/backup/#{name.gsub(".zip","")}/data.dump") && params[:database].present? && params[:environment].present?
      `rake mytask:drop_all_table && rake db:migrate && psql ftms_#{params[:environment]} < tmp/backup/backup/#{name.gsub(".zip","")}/data.dump`
    end
    
    `rm -rf tmp/backup/backup && rm #{path}`
    
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
    #Contact.destroy_all
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
            s.save
          else
            item.course_types << ct
            item.save
          end
          
        end
        
        item.add_status("active")
        item.save_draft(User.first)
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
  
  def self.get_online_report(type, year, month, course_types)
    courses = Course.all_courses
                      .where(course_type_id: course_types)
                      .where(for_exam_year: year)
                      .where(for_exam_month: month)
                      
    subjects = Subject.all_subjects.includes(:course_types).where(course_types: {id: course_types})
        
    students = Contact.main_contacts.includes(:contacts_courses)
                                    .where(contacts_courses: {course_id: courses.select{|c| c.id}})
                                    
    report = []
    students.each do |student|
      row = {}
      row["student"] = student
      row["subjects"] = []
      subjects.each do |subject|
        s_row = {}
        s_row["subject"] = subject
        s_row["count"] = student.all_contacts_courses.where(report: true).includes(:course).where(courses: {subject_id: subject.id}).count
        
        row["subjects"] << s_row
      end
      report << row
    end
                      
    return {data: report, subjects: subjects}
  end
  
end
