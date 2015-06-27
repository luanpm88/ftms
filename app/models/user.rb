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
  
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, :presence => true, :uniqueness => true
  
  
  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, :to => :ability
  
  def has_role?(role_sym)
    roles.any? { |r| r.name == role_sym }
  end
  
  def name
    if !first_name.nil?
      first_name + " " + last_name
    else
      email.gsub(/@(.+)/,'')
    end
  end
  
  def short_name
    if !first_name.nil?
      first_name + " " + last_name.split(" ").first
    else
      email.gsub(/@(.+)/,'')
    end
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
                against: [:first_name, :last_name],                
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
    backup_cmd += "pg_dump -a hkerp_#{params[:environment]} >> backup/#{dir}/data.dump && " if params[:database].present? && params[:environment].present?
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
        order = "users.first_name, users.last_name"
      when "3"
        order = "users.created_at"      
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "users.first_name, users.last_name"
    end
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 4
    @records.each do |item|
      item = [
              link_helper.link_to("<img class=\"avatar-big\" width='60' src='#{item.avatar(:square)}' />".html_safe, {controller: "users", action: "show", id: item.id}, class: "fancybox.ajax fancybox_link main-title"),
              link_helper.link_to(item.name, {controller: "users", action: "show", id: item.id}, class: "fancybox.ajax fancybox_link main-title")+item.quick_info,
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
      names << "<span class=\"badge badge-info #{r.name}\">#{r.name}</span>"
    end
    return names.join("<br />").html_safe
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
    
    import_icon = '<i class="icon-download-alt"></i> '.html_safe
    export_icon = '<i class="icon-external-link"></i> '.html_safe
    
    return history.sort {|a,b| b[:date] <=> a[:date]}
  end
  
  def staff_col
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    link_helper.link_to("<img class=\"round-ava\" src=\"#{self.avatar(:square)}\" width=\"35\" /><br /><span class=\"user-name\" />#{self.short_name}</span>".html_safe, {controller: "users", action: "show", id: self.id}, title: self.name, class: "fancybox.ajax fancybox_link")
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
      `rake mytask:drop_all_table && rake db:migrate && psql hkerp_#{params[:environment]} < tmp/backup/backup/#{name.gsub(".zip","")}/data.dump`
    end
    
    `rm -rf tmp/backup/backup && rm #{path}`
    
  end
  
end
