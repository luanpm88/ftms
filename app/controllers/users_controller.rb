class UsersController < ApplicationController
  include ApplicationHelper
  
  load_and_authorize_resource
  
  before_action :set_user, only: [:avatar, :show, :edit, :update, :destroy]

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
    authorize! :manage, User
    
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    authorize! :manage, User
    
    render layout: "content" if params[:tab_page].present?
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    
    respond_to do |format|
      if @user.save
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : users_path, notice: 'User was successfully created.' }
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
    
    respond_to do |format|
      if @user.update(new_params)
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : users_path, notice: 'User was successfully updated.' }
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
    
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url(tab_page: 1) }
      format.json { head :no_content }
    end
  end
  
  def backup
    if params[:backup]
      User.backup_system(params)
    end
    
    @files = Dir.glob("backup/*").sort{|a,b| b <=> a}
    
    render layout: "content" if params[:tab_page].present?
    # render layout = nil
  end
  
  def restore
    if params[:restore]
      User.restore_system(params)
    end
    render layout: "content" if params[:tab_page].present?
  end
  
  def download_backup
    send_file "backup/"+params[:filename].gsub("backup/",""), :type=>"application/zip"
  end
  
  def delete_backup
    `rm #{"backup/"+params[:filename].gsub("backup/","")}`
    respond_to do |format|
      format.html { redirect_to backup_users_path(tab_page: params[:tab_page]) }
      format.json { head :no_content }
    end
  end
  
  def avatar
    send_file @user.avatar_path(params[:type]), :disposition => 'inline'
  end
  
  def datatable
    result = User.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_users_actions(item)
      
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
    
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end
        
    @statistics = []
    @users = User.order("users.first_name, users.last_name")
    @users = @users.where(id: params[:users]) if params[:users].present?
    
    current_id = nil
    
    @result = []
    @users.each do |u|
      row = {statistics: []}
      group_total = 0.0
      inquiry_total = 0
      student_total = 0
      paper_total = 0
      receivable_total = 0.00
      
      
      @course_types = CourseType.main_course_types.order("short_name")
      @course_types.each do |ct|
        #@statistics << {user: u, course_type: ct}
        
        # sales
        total = 0.0
        @records = PaymentRecord.includes(:course_register => :contact)
                              .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status LIKE ?", "%[active]%")
                              .where(status: 1)
                              .where(course_registers: {account_manager_id: u.id}) #.where(course_types: {id: ct.id}) #.sum(:price)                              
                              .where("payment_records.payment_date >= ? AND payment_records.payment_date <= ? ", @from_date.beginning_of_day, @to_date.end_of_day)
        
        @records.each do |pr|
          pr.payment_record_details.each do |prd|
            if prd.contacts_course.course.course_type_id == ct.id
              total += prd.amount
              group_total += prd.amount
            end
          end
        end
        
        @records = PaymentRecord.includes(:course_register => :contact)
                              .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status LIKE ?", "%[active]%")
                              .where(status: 1)
                              .where(course_registers: {account_manager_id: u.id}) #.where(course_types: {id: ct.id}) #.sum(:price)                              
                              .where("payment_records.payment_date >= ? AND payment_records.payment_date <= ? ", @from_date.beginning_of_day, @to_date.end_of_day)
        
        @records.each do |pr|
          pr.payment_record_details.each do |prd|
            if prd.contacts_course.course.course_type_id == ct.id
              total += prd.amount
              group_total += prd.amount
            end
          end
        end
        
        
        # receivable
        receivable = 0
        contacts_courses = ContactsCourse.includes(:course_register, :course => :course_type)
                                          .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status LIKE ?", "%[active]%")
                                          .where(course_types: {id: ct.id})
                                          .where(course_registers: {account_manager_id: u.id})
                                          .where("course_registers.created_at >= ? AND course_registers.created_at <= ? ", @from_date.beginning_of_day, @to_date.end_of_day)
        
        contacts_courses.each do |cc|
          receivable += cc.remain(@from_date, @to_date) if !cc.course_register.paid?(@to_date.end_of_day)
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
          if c.cache_course_type_ids.present? && c.cache_course_type_ids.include?("[#{ct.id}]") && c.contact_types.include?(ContactType.student)          
            student += 1
            student_total += 1
          end
          
          inquiry -= transform
          inquiry_total -= transform
          student += transform
          student_total += transform
          
        end

        
        
        # Paper
        paper = 0
        @papers = ContactsCourse.includes(:course_register, :contact, :course => :course_type)
                            .where(course_registers: {parent_id: nil}).where("course_registers.status IS NOT NULL AND course_registers.status LIKE ?", "%[active]%")
                            .where(course_registers: {account_manager_id: u.id})
                            .where(course_types: {id: ct.id})
                            .where("course_registers.created_at >= ? AND course_registers.created_at <= ? ", @from_date.beginning_of_day, @to_date.end_of_day)

        paper = @papers.count
        paper_total += @papers.count
        
        
        
        row[:statistics] << {user: u, course_type: ct, paper: paper, inquiry: inquiry, student: student, total: total, receivable: receivable} if total > 0.0 || receivable > 0.0 || paper > 0 || inquiry > 0 || student > 0

      end
      
      note_count = u.activities
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
    end
    
    if params[:pdf].present?
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
    end
    
    
  end
  
  def import_from_old_system
    if params[:import]
      @result = User.import_from_old_sustem(params['upload']['datafile'])
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
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :mobile, :email, :first_name, :last_name, :ATT_No, :image, :password, :password_confirmation, :role_ids => [])
    end
end
