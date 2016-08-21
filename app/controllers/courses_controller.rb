class CoursesController < ApplicationController
  include CoursesHelper
  
  load_and_authorize_resource
  
  before_action :set_course, only: [:transfer_to_box, :transfer_to_course, :delete, :show, :edit, :update, :destroy] # [delete] for revision-feature
  
  def intake_options
    respond_to do |format|
      format.html { render layout: "content" if params[:tab_page].present? }
      format.json {
        render json: Course.intake_options
      }
    end
  end
  
  # GET /courses
  # GET /courses.json
  def index
    @courses = Course.all_courses
    
    if params[:student_id]
      @student = Contact.find(params[:student_id])
    end
    
    respond_to do |format|
      format.html { render layout: "content" if params[:tab_page].present? }
      format.json {
        render json: Course.full_text_search(params[:q], params)
      }
    end
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
  end

  # GET /courses/new
  def new
    @course = Course.new
    @course.intake = Time.now.beginning_of_month
    @course.for_exam_year = Time.now.year
  end

  # GET /courses/1/edit
  def edit
    @types = [ContactType.student.id.to_s]
    @individual_statuses = ["true"]
    @course.intake = Time.now.to_date if @course.upfront
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(course_params)
    @course.user = current_user    
    @course.update_program_paper(params[:program_paper])
    @course.intake = "1990-01-01".to_date if @course.upfront
    @course.lecturer = nil if @course.upfront
    
    respond_to do |format|
      if @course.save
        @course.update_courses_phrases(params[:courses_phrases]) if !params[:courses_phrases].nil?
        @course.update_course_prices(params[:course_prices]) if !params[:course_prices].nil?
        
        @course.update_status("create", current_user)        
        @course.save_draft(current_user)
        
        @course.update_cache_search
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @course, notice: 'Course was successfully created.' }
        format.json { render action: 'show', status: :created, location: @course }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1
  # PATCH/PUT /courses/1.json
  def update
    @course.assign_attributes(course_params)
    @course.update_program_paper(params[:program_paper])
    @course.intake = "1990-01-01".to_date if @course.upfront
    @course.lecturer = nil if @course.upfront
    
    respond_to do |format|
      if @course.save        
        new_added = @course.update_courses_phrases(params[:courses_phrases]) if !params[:courses_phrases].nil?
        @course.update_course_prices(params[:course_prices]) if !params[:course_prices].nil?
        
        @course.update_status("update", current_user)        
        @course.save_draft(current_user)
        
        @course.update_cache_search
        
        if new_added.present? && !new_added.empty?
          flash[:alert] = "Course was successfully updated. Course/stock registrations below need to be checked for new phrase-date added: #{new_added.join(", ")}."
          @tab = {url: {controller: "course_registers", action: "index", course_id: @course.id, full_course: false, tab_page: 1}, title: "Check Course Registrations with New Phrase-Date"}
          format.html { render "/home/close_tab", layout: nil }
          format.json { head :no_content }
        else
          format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @course, notice: 'Course was successfully updated.' }
          format.json { head :no_content }
        end        
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to courses_url(tab_page: 1) }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = Course.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_course_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def student_courses
    result = Course.student_courses(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_student_courses_actions(item[:course], params[:students])      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def courses_phrases_checkboxs
    if !params[:id].present?
      render nothing: true
    else
      @course = Course.find(params[:id])
      render layout: nil
    end
    
  end
  
  def course_price_select
    if !params[:id].present?
      render nothing: true
    else
      @course = Course.find(params[:id])
      render layout: nil
    end
  end
  
  
  ########## BEGIN REVISION ###############
  
  def approve_new
    authorize! :approve_new, @course
    
    @course.approve_new(current_user)
    
    respond_to do |format|
      format.html { render "/courses/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @subject }
    end
  end
  
  def approve_update
    authorize! :approve_update, @course
    
    @course.approve_update(current_user)
    
    respond_to do |format|
      format.html { render "/courses/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @course }
    end
  end
  
  def approve_delete
    authorize! :approve_delete, @course
    
    @course.approve_delete(current_user)
    
    respond_to do |format|
      format.html { render "/courses/deleted", layout: nil }
      format.json { render action: 'show', status: :created, location: @course }
    end
  end
  
  def undo_delete
    authorize! :undo_delete, @course
    
    @course.undo_delete(current_user)
    
    respond_to do |format|
      format.html { render "/courses/undo_delete", layout: nil }
      format.json { render action: 'show', status: :created, location: @course }
    end
  end
  
  def approved
    render layout: "content"
  end
  
  def field_history
    @drafts = @course.field_history(params[:type])
    
    render layout: nil
  end

  def delete
    
    respond_to do |format|
      if @course.delete
        @course.save_draft(current_user)
        
        format.html { render "/courses/deleted", layout: nil }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end
  
  ########## BEGIN REVISION ###############
  
  def course_phrases_form
    @course = params[:course_id].present? ? Course.find(params[:course_id]) : Course.new
    @phrases = Phrase.active_phrases.includes(:subjects).where(subjects: {id: params[:value].split("_")[1]})
    
    render layout: nil
  end
  
  def transfer_course
    @transfer = @course.transfers.new(contact_id: params[:contact_id])
    @contact = Contact.find(params[:contact_id])
    #@contacts_course = ContactsCourse.find(@transfer.contact.active_contacts_courses.where(course_id: @course.id).first.id)
    
    if @contact.pending_transfer_course_ids.include?(@course.id)
      @tab = {url: {controller: "contacts", action: "edit", id: @contact.id, tab_page: 1, tab: "transfer"}, title: @contact.display_name}
      flash[:alert] = 'Error: Previous transfer(s) for this course must be approved first.!'
      render "/home/close_tab", layout: nil
    elsif false and @contact.active_course(@course.id)[:money].to_f == 0
      @tab = {url: {controller: "contacts", action: "edit", id: @contact.id, tab_page: 1, tab: "course"}, title: @contact.display_name}
      flash[:alert] = "Error: Course's money cannot be zero. Student need to pay first.!"
      render "/home/close_tab", layout: nil
    else
      render layout: "content"
    end   
  end
  
  def course_phrases_list
    @disable = {}
    if !params[:contact_id].present?
      @courses_phrases = @course.ordered_courses_phrases
      @type = "to"
      if params[:to_contact_id].present?
        @to_contact = Contact.find(params[:to_contact_id])
        
        @courses_phrases.each do |cp|
            @disable[cp.id] = @to_contact.courses_phrase_registered?(cp)
        end
      end
      @full_course = true
    else
      # to ==>  from
      @to_contact = Contact.find(params[:contact_id])
      @courses_phrases = @to_contact.active_course(@course.id)[:courses_phrases]
      @hour = @to_contact.active_course(@course.id)[:hour]
      @money = @to_contact.active_course(@course.id)[:money]
      @remain = @to_contact.active_course(@course.id)[:remain]
      @full_course = @to_contact.active_course(@course.id)[:full_course]

      
      @type = "from"
    end
    
    render layout: nil
  end
  
  def transfer_to_box
    @contact = Contact.find(params[:contact_id])
    @to_contact = Contact.find(params[:to_contact_id])
    @transfer = @course.transfers.new
    @transfer.contact = @contact
    @transfer.to_contact = @to_contact
    @remain = @contact.active_course(@course.id)[:remain]
    
    @transfer.all_to_courses
    
    render layout: nil
  end
  
  def report_toggle
    @course = Course.find(params[:cc_id].split("-")[0])
    @contact = Contact.find(params[:cc_id].split("-")[1])
    
    if @course.no_report_contacts.include?(@contact)
      @course.remove_no_report_contact(@contact)
    else
      @course.add_no_report_contact(@contact)
    end    
    
    render layout: nil
  end
  
  def approve_all
    if params[:ids].present?
      if !params[:check_all_page].nil?
        params[:intake_year] = params["filter"]["intake(1i)"] if params["filter"].present?
        params[:intake_month] = params["filter"]["intake(2i)"] if params["filter"].present?
        
        @items = Course.filters(params, current_user)
      else
        @items = Course.where(id: params[:ids])
      end
    end
    
    @items.each do |c|
      c.approve_delete(current_user) if current_user.can?(:approve_delete, c)
      c.approve_new(current_user) if current_user.can?(:approve_new, c)
      c.approve_update(current_user) if current_user.can?(:approve_update, c)
    end
    
    respond_to do |format|
      format.html { render "/courses/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @course }
    end
  end
  
  def delete_all
    if params[:ids].present?
      if !params[:check_all_page].nil?
        params[:intake_year] = params["filter"]["intake(1i)"] if params["filter"].present?
        params[:intake_month] = params["filter"]["intake(2i)"] if params["filter"].present?
        
        @items = Course.filters(params, current_user)
      else
        @items = Course.where(id: params[:ids])
      end
    end
    
    @items.each do |c|
      if current_user.can?(:delete, c)
        c.delete
        c.save_draft(current_user)
        #c.approve_delete(current_user)
        #c.save_draft(current_user)
      end
    end
    
    respond_to do |format|
      format.html { render text: "All items were deleted!" }
      format.json { render action: 'show', status: :created, location: @course }
    end
  end
  
  def print_list
    if params[:ids].present?
      if !params[:check_all_page].nil?
        params[:intake_year] = params["filter"]["intake(1i)"] if params["filter"].present?
        params[:intake_month] = params["filter"]["intake(2i)"] if params["filter"].present?
        
        @items = Course.filters(params, current_user)
      else
        @items = Course.where(id: params[:ids])
      end
    end
    
    respond_to do |format|
      format.html {render "print_list.html.erb"}
      format.xls
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_params
      params.require(:course).permit(:upfront, :for_exam_year, :for_exam_month, :lecturer_id, :description, :user_id, :intake, :course_type_id, :course_type_ids => [])
    end
end
