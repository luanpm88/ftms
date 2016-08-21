class UsersController < ApplicationController
  include ApplicationHelper
  
  load_and_authorize_resource
  
  before_action :set_user, only: [:delete, :avatar, :show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
    
    respond_to do |format|
      format.html { render layout: "content" if params[:tab_page].present? }
      format.json {
        render json: User.full_text_search(params[:q])
      }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if params[:tab_page].present?
      render layout: "content"
    else
      render layout: "none"
    end
  end

  # GET /users/new
  def new
    
    @user = User.new
  end

  # GET /users/1/edit
  def edit

    render layout: "content" if params[:tab_page].present?
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.user_id = current_user.id
    
    respond_to do |format|
      if @user.save
        @tab = {url: {controller: "users", action: "edit", id: @user.id, tab_page: 1}, title: @user.name+" #"+@user.id.to_s}
        format.html { render "/home/close_tab", layout: nil }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    new_params = user_params
    
    if new_params["password"].empty?      
      new_params.delete("password")
      new_params.delete("password_confirmation")
    end
    
    if params[:remove_avatar].present?
      @user.remove_image!
      @user.save
    end
    
    respond_to do |format|
      if @user.update(new_params)
        @tab = {url: {controller: "users", action: "edit", id: @user.id, tab_page: 1}, title: @user.name+" #"+@user.id.to_s}
        format.html { render "/home/close_tab", layout: nil }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    authorize! :manage, User
    
    # @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url(tab_page: 1) }
      format.json { head :no_content }
    end
  end
  
  def delete
    @user.update_attribute(:status, 0)
    respond_to do |format|
      format.html { redirect_to users_url(tab_page: 1) }
      format.json { head :no_content }
    end
  end
  
  def backup
    @database = YAML.load_file('config/database.yml')["production"]["database"]
    
    if params[:backup]
      User.backup_system(params)
    end
    
    @files = (Dir.glob("#{Setting.get("backup_dir")}/*").map{|f| f.gsub("#{Setting.get("backup_dir")}/","")}).sort{|a,b| b <=> a}
    
    render layout: "content" if params[:tab_page].present?
    # render layout = nil
  end
  
  def restore
    @database = YAML.load_file('config/database.yml')["production"]["database"]
    
    if params[:restore]
      puts "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
      User.restore_system(params)
    end
    render layout: "content" if params[:tab_page].present?
  end
  
  def download_backup
    bk_dir = Setting.get("backup_dir")
    send_file bk_dir + "/"+params[:filename].gsub(bk_dir + "/",""), :type=>"application/zip"
  end
  
  def delete_backup
    `rm #{bk_dir + "/"+params[:filename].gsub(bk_dir + "/","")}`
    respond_to do |format|
      format.html { redirect_to backup_users_path(tab_page: params[:tab_page]) }
      format.json { head :no_content }
    end
  end
  
  def avatar
    # params[:type] = params[:type].present? ? params[:type] : "thumb2x"
    send_file @user.avatar_path(params[:type]), :disposition => 'inline'
  end
  
  def datatable
    result = User.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_users_actions(item,current_user)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def activity_log   
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end
    
    @user = params[:id].present? ? User.find(params[:id]) : current_user
    
    authorize! :activity_log, @user
    
    @history = @user.activity_log(@from_date, @to_date)
    
    render layout: "content" if params[:tab_page].present?
  end
  
  def statistic
    #@date = Date.today
    #if params[:filter]
    #  @date = @date.change(:year => params[:filter]["intake(1i)"].to_i, month: params[:filter]["intake(2i)"].to_i)
    #end
    
    @logs = ""
    
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end
        
    @statistics = []
    @users = User.where(status: 1).order("users.first_name, users.last_name")
    
    params[:users] = [current_user.id] if current_user.lower?("manager")
    @users = @users.where(id: params[:users]) if params[:users].present?
    
    current_id = nil
    
    @result = []
    @all_total = {note_total: 0, group_total: 0, inquiry_total: 0, student_total: 0, paper_total: 0, receivable_total: 0}
    @users.each do |u|
      row = {statistics: []}
      group_total = 0.0
      inquiry_total = 0
      student_total = 0
      paper_total = 0
      receivable_total = 0.00
      
      
      @course_types = CourseType.main_course_types.order("short_name")
      @course_types << CourseType.new(id: -1, short_name: "Defer/Transfer")
      @course_types.each do |ct|
        #@statistics << {user: u, course_type: ct}
        
        # sales
        total = 0.0
        @records = PaymentRecord.includes(:course_register => :contact)
                              .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status NOT LIKE ?", "%[deleted]%")
                              .where(status: 1)
                              .where(course_registers: {account_manager_id: u.id}) #.where(course_types: {id: ct.id}) #.sum(:price)                              
                              .where("payment_records.payment_date >= ? AND payment_records.payment_date <= ? ", @from_date.beginning_of_day, @to_date.end_of_day).uniq
        
        @records.each do |pr|
          pr.payment_record_details.each do |prd|
            if !prd.contacts_course.nil? && prd.contacts_course.course.course_type_id == ct.id
              total += prd.real_amount
              group_total += prd.real_amount
            elsif !prd.books_contact.nil? && prd.books_contact.book.course_type_id == ct.id
              total += prd.real_amount
              group_total += prd.real_amount
            end
          end
        end
        
        # transfer sales
        @records = PaymentRecord.includes(:transfer => :contact)
                              .where(transfers: {parent_id: nil}).where("transfers.status IS NOT NULL AND transfers.status NOT LIKE ?", "%[deleted]%")
                              .where(status: 1)
                              .where(contacts: {account_manager_id: u.id}) #.where(course_types: {id: ct.id}) #.sum(:price)                              
                              .where("payment_records.payment_date >= ? AND payment_records.payment_date <= ? ", @from_date.beginning_of_day, @to_date.end_of_day).uniq
        @records.each do |pr|
            if ct.id == -1
              total += pr.amount
              group_total += pr.amount            
            end
        end
        
        
        ## company sales
        @records = PaymentRecord.where(status: 1)
                              .where(account_manager_id: u.id)
                              .where("payment_records.payment_date >= ? AND payment_records.payment_date <= ? ", @from_date.beginning_of_day, @to_date.end_of_day)
        @records.each do |pr|
          pr.payment_record_details.each do |prd|
            if prd.course_type_id == ct.id
              total += prd.real_amount
              group_total += prd.real_amount
            end
          end
        end
        
        
        
        # receivable
              receivable = 0
              receivable_contacts = []
              
              #contacts courses
              contacts_courses = ContactsCourse.includes(:course_register, :course => :course_type)
                                                .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status NOT LIKE ?", "%[deleted]%")
                                                .where(course_types: {id: ct.id})
                                                .where(course_registers: {account_manager_id: u.id})
                                                .where("course_registers.created_at >= ? AND course_registers.created_at <= ? ", @from_date.beginning_of_day, @to_date.end_of_day)
              
              contacts_courses.each do |cc|                
                if !cc.course_register.paid?(@to_date.end_of_day)
                  receivable += cc.remain(@from_date, @to_date)
                  @logs += cc.id.to_s+"sssss"
                  receivable_contacts << cc.contact
                end
              end
              
              
              
              #books courses
              books_contacts = BooksContact.includes(:course_register, :book => :course_type)
                                                .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status NOT LIKE ?", "%[deleted]%")
                                                .where(course_types: {id: ct.id})
                                                .where(course_registers: {account_manager_id: u.id})
                                                .where("course_registers.created_at >= ? AND course_registers.created_at <= ? ", @from_date.beginning_of_day, @to_date.end_of_day)
              
              books_contacts.each do |cc|                
                if !cc.course_register.paid?(@to_date.end_of_day)
                  receivable += cc.remain_amount(@from_date, @to_date)
                  receivable_contacts << cc.contact
                  @logs += cc.id.to_s+"sssss"
                end
              end
              
              if ct.id == -1
                #transfers
                transfers = Transfer.includes(:contact).where(parent_id: nil).where("transfers.status IS NOT NULL AND transfers.status NOT LIKE ?", "%[deleted]%")
                                                  .where(contacts: {account_manager_id: u.id})
                                                  .where("transfers.created_at >= ? AND transfers.created_at <= ? ", @from_date.beginning_of_day, @to_date.end_of_day)
                                       
                transfers.each do |tsf|
                  if tsf.remain(@from_date, @to_date) != 0.0 
                    receivable += tsf.remain(@from_date, @to_date)
                    receivable_contacts << tsf.contact
                    @logs += tsf.id.to_s+"sssss" 
                  end
                end
              end
                
      
              receivable_total += receivable
        
        
        # Inquiry # Student
        inquiry = 0
        student = 0
        @contacts = Contact.main_contacts.includes(:contact_types, :course_types)
                            .where(creator_id: u.id)
                            .where(is_individual: true)
                            .where("contacts.created_at >= ? AND contacts.created_at <= ? ", @from_date.beginning_of_day, @to_date.end_of_day)
        
        @contacts.each do |c|
          transform = 0
          
          if c.course_types.include?(ct) && c.contact_types.include?(ContactType.inquiry)
            inquiry += 1
            inquiry_total += 1
            
            # find transform revision
            transform_revision_count = c.revisions.includes(:contact_types)
                                                  .where(contact_types: {id: ContactType.student.id})
                                                  .where("contacts.created_at >= ? AND contacts.created_at <= ? ", @from_date.beginning_of_day, @to_date.end_of_day)
                                                  .count
            if transform_revision_count > 0
              transform = 1
            end
          end
          if c.contact_types.include?(ContactType.inquiry) && c.course_types.empty?
            inquiry_total += 1
          end
          
          if c.cache_course_type_ids.present? && c.cache_course_type_ids.include?("[#{ct.id}]") && c.contact_types.include?(ContactType.student)          
            student += 1
            student_total += 1
          end
          #if !c.cache_course_type_ids.present? && c.contact_types.include?(ContactType.student)  
          #  student_total += 1
          #end
          
          inquiry -= transform
          inquiry_total -= transform
          student += transform
          student_total += transform
          
        end

        
        
        # Paper
        paper = 0
        @papers = ContactsCourse.includes(:course_register, :contact, :course => :course_type)
                            .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status NOT LIKE ?", "%[deleted]%")
                            .where(course_registers: {account_manager_id: u.id})
                            .where(course_types: {id: ct.id})
                            .where("course_registers.created_at >= ? AND course_registers.created_at <= ? ", @from_date.beginning_of_day, @to_date.end_of_day)

        paper = @papers.count
        paper_total += @papers.count
        
        
        
        row[:statistics] << {user: u, course_type: ct, paper: paper, inquiry: inquiry, student: student, total: total, receivable: receivable, receivable_contacts: receivable_contacts} if total > 0.0 || receivable > 0.0 || paper > 0 || inquiry > 0 || student > 0

      end
      
      note_count = u.manage_activities
                    .where("activities.created_at >= ? AND activities.created_at <= ? ", @from_date.beginning_of_day, @to_date.end_of_day)
                    .count
      
      
      row[:note] = note_count
      row[:user] = u
      row[:paper] = paper_total
      row[:inquiry] = inquiry_total
      row[:student] = student_total
      row[:course_type] = nil
      row[:total] = group_total
      row[:receivable] = receivable_total
      @result << row
      
      # all_total = {group_total: 0, inquiry_total: 0, student_total: 0, paper_total: 0, receivable_total: 0}
      @all_total[:note_total] += note_count
      @all_total[:group_total] += group_total
      @all_total[:inquiry_total] += inquiry_total
      @all_total[:student_total] += student_total
      @all_total[:paper_total] += paper_total
      @all_total[:receivable_total] += receivable_total
      
    end
    
    
    
    respond_to do |format|
        format.html 
        format.xls {render "users/statistics.xls.erb"}
        format.pdf {
          render  :pdf => "sales_statistics_"+Time.now.strftime("%d_%b_%Y"),
            :template => 'users/statistics.pdf.erb',
            :layout => nil,
            :orientation => 'Landscape',
            :footer => {
               :center => "",
               :left => "",
               :right => "",               
               :page_size => "A4",
               :margin  => {:top    => 0, # default 10 (mm)
                          :bottom => 0,
                          :left   => 0,
                          :right  => 0},
            }
        }
    end
    
  end
  
  def statistics_enhanced
    if params[:report_period].present?
      @report_period = ReportPeriod.find(params[:report_period])
      @from_date = @report_period.start_at.to_date.beginning_of_day
      @to_date =  @report_period.end_at.to_date.end_of_day
    elsif params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date.beginning_of_day
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end
    
    @users = []
    
    if params[:calculate].present?
      @users = User.where(status: 1).order("users.first_name, users.last_name")     
      params[:users] = [current_user.id] if current_user.lower?("manager")
      @users = @users.where(id: params[:users]) if params[:users].present?
    end
    
    @result = User.statistics(@users, @from_date, @to_date)
    
    File.open('statistics_'+current_user.id.to_s+'.tmp', 'w') {|f| f.write(YAML.dump(@result)) }
    
    respond_to do |format|
        format.html 
        format.xls {render "users/statistics_enhanced.xls.erb"}
        format.pdf {
          render  :pdf => "users_statistics_"+Time.now.strftime("%d_%b_%Y"),
            :template => 'users/statistics_enhanced.pdf.erb',
            :layout => nil,
            :orientation => 'Landscape',
            :footer => {
               :center => "",
               :left => "",
               :right => "",               
               :page_size => "A4",
               :margin  => {:top    => 0, # default 10 (mm)
                          :bottom => 0,
                          :left   => 0,
                          :right  => 0},
            }
        }
    end
  end
  
  def download_statistics
    if params[:report_period].present?
      @report_period = ReportPeriod.find(params[:report_period])
      @from_date = @report_period.start_at.to_date.beginning_of_day
      @to_date =  @report_period.end_at.to_date.end_of_day
    elsif params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end
    
    @result = YAML.load(File.read('statistics_'+current_user.id.to_s+'.tmp'))
    
    respond_to do |format|
        format.html 
        format.xls {render "users/statistics_enhanced.xls.erb"}
        format.pdf {
          render  :pdf => "users_statistics_"+Time.now.strftime("%d_%b_%Y"),
            :template => 'users/statistics_enhanced.pdf.erb',
            :layout => nil,
            :orientation => 'Landscape',
            :footer => {
               :center => "",
               :left => "",
               :right => "",               
               :page_size => "A4",
               :margin  => {:top    => 0, # default 10 (mm)
                          :bottom => 0,
                          :left   => 0,
                          :right  => 0},
            }
        }
    end
  end
  
  def import_from_old_system
    if params[:import]
      System.backup({database: true, file: true})
      
      @result = User.import_from_old_system(params['upload']['datafile'])
    end
  end
  
  def online_report
    if params[:export]
      if params[:type] == "cima"
        @report = User.get_cima_report(params[:year], params[:month], params[:course_types])
        
        respond_to do |format|
          format.html
          format.xls {render "users/online_report_cima"}
        end
      else
        @report = User.get_acca_report(params[:year], params[:month], params[:course_types])
        
        respond_to do |format|
          format.html
          format.xls {render "users/online_report_acca"}
        end
      end
    end    
  end
  
  def system_setting
    if params[:settings].present?
      params[:settings].each do |row|
        Setting.set(row[0], row[1])
      end
    end    
  end
  
  def user_guide
    send_file "ftms_user_guide.pdf"
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:tmp_ConsultantID, :name, :mobile, :email, :first_name, :last_name, :ATT_No, :image, :password, :password_confirmation, :role_ids => [])
    end
end
