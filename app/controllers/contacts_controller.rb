class ContactsController < ApplicationController
  helper :headshot
  
  include ContactsHelper
  
  load_and_authorize_resource
  before_action :set_contact, only: [:related_info_box, :delete, :course_register, :ajax_quick_info, :ajax_tag_box, :ajax_edit, :ajax_update, :show, :edit, :update, :destroy, :ajax_destroy, :ajax_show, :ajax_list_agent, :ajax_list_supplier_agent]

  # GET /contacts
  # GET /contacts.json
  def index
    @types = [] #[ContactType.student.id.to_s,ContactType.inquiry.id.to_s,ContactType.lecturer.id.to_s]
    @individual_statuses = ["true"]
    
    if params[:course_id]
      @course = Course.find(params[:course_id])
    end
    
    if params[:seminar_id]
      @seminar = Seminar.find(params[:seminar_id])
    end
    
    if params[:company_id]
      @company = Contact.find(params[:company_id])
    end
    
    
    respond_to do |format|
      format.html
      format.json {
        render json: Contact.full_text_search(params)
      }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
    if params[:tab_page].present?
      render layout: "content"
    else
      render layout: "none"
    end
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
    #@contact.account_manager = current_user
    
    if !params[:is_individual].nil? && params[:is_individual] == "false"
      @contact.is_individual = false
    end
    
    if (!params[:contact_type_id].nil?)
      @contact.contact_types << ContactType.find_by_id(params[:contact_type_id])
    else
      @contact.contact_types << ContactType.inquiry
    end
    
    if (!params[:company_id].nil?)
      @contact.companies << Contact.find_by_id(params[:company_id])
    end
    
    if params[:tab_page].present?
      render layout: "content"
    end
  end

  # GET /contacts/1/edit
  def edit
    @student = @contact
    @activity = Activity.new(contact_id: @contact.id)
    
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = nil
      @to_date =  DateTime.now
    end
  end

  # POST /contacts
  # POST /contacts.json
  def create
    s_params = contact_params
    s_params[:course_type_ids] = contact_params[:course_type_ids][0].split(",") if contact_params[:course_type_ids].present?
    s_params[:lecturer_course_type_ids] = contact_params[:lecturer_course_type_ids][0].split(",") if contact_params[:lecturer_course_type_ids].present?
    
    @contact = Contact.new(s_params)
    @contact.user_id = current_user.id
    
    
    
    #base
    @contact.update_bases(params[:bases])    
    
    if params[:contact_tag].present?
      @contact_tag = ContactTag.find(params[:contact_tag])
    end
    
    if params[:avatar_method] == "camera" && params[:headshot_url].present?
          filename = params[:headshot_url].split("/").last
          @contact.image = File.open("public/headshots/"+filename)
    end
    

    respond_to do |format|
      if @contact.save
        if params[:contact_tag].present?
          @contact.update_tag(@contact_tag, current_user)
        end        
        @contact.update_status("create", current_user)        
        @contact.save_draft(current_user)
        @contact.update_info

        format.html { redirect_to params[:tab_page].present? ? {action: "edit", id: @contact.id,tab_page: 1} : contacts_url, notice: 'Contact was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contact }
      else
        @activity = Activity.new(contact_id: @contact.id)
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    @student = @contact
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = nil
      @to_date =  DateTime.now
    end
    
    if params[:contact_tag].present?
      @contact_tag = ContactTag.find(params[:contact_tag])
    end
    
    if params[:avatar_method] == "camera" && params[:headshot_url].present?
          filename = params[:headshot_url].split("/").last
          @contact.image = File.open("public/headshots/"+filename)
          @contact.save
    end
    
    if params[:avatar_method] == "upload" && !contact_params[:image].present?
      @contact.remove_image!
      @contact.save
    end
    
    s_params = contact_params
    s_params[:course_type_ids] = contact_params[:course_type_ids][0].split(",") if contact_params[:course_type_ids].present?
    s_params[:lecturer_course_type_ids] = contact_params[:lecturer_course_type_ids][0].split(",") if contact_params[:lecturer_course_type_ids].present?
    
    #base
    @contact.update_bases(params[:bases])
    
    respond_to do |format|
      if @contact.update(s_params)
        if params[:contact_tag].present?
          @contact.update_tag(@contact_tag, current_user)
        end        
        @contact.update_status("update", current_user)
        
        @contact.save_draft(current_user)
        
        @contact.update_info
        
        format.html { redirect_to params[:tab_page].present? ? {action: "edit",id: @contact.id,tab_page: 1} : contacts_url, notice: 'Contact was successfully updated.' }
        format.json { head :no_content }
      else
        @activity = Activity.new(contact_id: @contact.id)
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def delete
    
    respond_to do |format|
      if @contact.delete
        @contact.save_draft(current_user)
        
        format.html { redirect_to params[:tab_page].present? ? {action: "edit",id: @contact.id,tab_page: 1} : contacts_url, notice: 'Contact was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url }
      format.json { head :no_content }
    end
  end
  
  def import    
    @result = Contact.import(params[:file])
  end
  
  def ajax_new    
    @contact = Contact.new
    
    if (!params[:type_id].nil?)
      @contact.contact_types << ContactType.find_by_id(params[:type_id])
    end
    if (!params[:company_id].nil?)
      @contact.companies << Contact.find_by_id(params[:company_id])
    end
    
    render :layout => nil
  end
  
  def ajax_edit
    
    render :layout => nil
  end
  
  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def ajax_update
    params[:contact][:contact_type_ids] ||= []
    
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { render action: 'ajax_show', :layout => nil, :id => @contact.id }
        format.json { head :no_content }
      else
        format.html { render action: 'ajax_edit' }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def ajax_create
    @contact = Contact.new(contact_params)
    @contact.user_id = current_user.id

    respond_to do |format|
      if @contact.save
        format.html { render action: 'ajax_show', :layout => nil, :id => @contact.id }
        format.json { head :no_content }
      else
        format.html { render action: 'ajax_new', :layout => nil }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /contacts/1
  def ajax_destroy
    @contact.destroy
    
    render :nothing => true
  end
  
    
  # GET /orders/1
  # GET /orders/1.json
  def ajax_show
    @contact.address = @contact.full_address
    render :json => @contact.to_json
  end
  
  def ajax_list_agent
    render :layout => nil
  end
  
  def ajax_list_supplier_agent
    render :layout => nil
  end
  
  def datatable
    result = Contact.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_contacts_actions(item)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def course_students
    result = Contact.course_students(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_contacts_actions(item)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def seminar_students
    result = Contact.seminar_students(params, current_user)
    
    #result[:items].each_with_index do |item, index|
    #  actions = render_contacts_actions(item)
    #  
    #  result[:result]["data"][index][result[:actions_col]] = actions
    #end
    
    render json: result[:result]
  end
  
  def logo
    send_file @contact.logo_path(params[:type]), :disposition => 'inline'
  end
  
  def update_tag
    contact_tag = ContactTag.find(params[:tag_id])
    @contact.update_tag(contact_tag, current_user)
    
    render layout: nil
  end
  
  def ajax_quick_info
    
    render layout: nil
  end
  
  def course_register
    
  end
  
  def export_list
    if params[:ids].present?
      if !params[:check_all_page].nil?
        params[:intake_year] = params["filter"]["intake(1i)"] if params["filter"].present?
        params[:intake_month] = params["filter"]["intake(2i)"] if params["filter"].present?
        
        if params[:is_individual] == "false"
          params[:contact_types] = nil
        end        
        
        @contacts = Contact.filters(params, current_user)
      else
        @contacts = Contact.where(id: params[:ids])
      end
      
      
      respond_to do |format|
        format.html
        format.xls
      end
    end      
  end
  
  def related_info_box
    @contacts = nil
    
    if params[:value].strip.present? && params[:type].strip.present?
      @contacts = Contact.main_contacts.where.not(id: @contact.draft_for)
      
      @contacts = @contacts.where.not(id: params[:id].strip) if params[:id].present?
      
      @contacts = @contacts.where("LOWER(#{params[:type]}) = ?", params[:value].strip.downcase)
      
    end
    
    render layout: nil
  end
  
  def approve_new
    authorize! :approve_new, @contact
    
    @contact.approve_new(current_user)
    
    respond_to do |format|
      format.html { render "/contacts/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @subject }
    end
  end
  
  def approve_education_consultant
    authorize! :approve_education_consultant, @contact
    
    @contact.approve_education_consultant(current_user)    
    
    respond_to do |format|
      format.html { render "/contacts/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @subject }
    end
  end
  
  def approve_update
    authorize! :approve_update, @contact
    
    @contact.approve_update(current_user)
    
    respond_to do |format|
      format.html { render "/contacts/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @subject }
    end
  end
  
  def approve_delete
    authorize! :approve_delete, @contact
    
    @contact.approve_delete(current_user)
    
    respond_to do |format|
      format.html { render "/contacts/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @subject }
    end
  end
  
  def approved
    render layout: "content"
  end
  
  def field_history
    @drafts = @contact.field_history(params[:type])
    
    render layout: nil
  end
  
  def export_mobiles
    if params[:ids].present?
      if !params[:check_all_page].nil?
        params[:intake_year] = params["filter"]["intake(1i)"] if params["filter"].present?
        params[:intake_month] = params["filter"]["intake(2i)"] if params["filter"].present?
        
        if params[:is_individual] == "false"
          params[:contact_types] = nil
        end        
        
        @contacts = Contact.filters(params, current_user)
      else
        @contacts = Contact.where(id: params[:ids])
      end
    end      
    render layout: "content"
  end
  
  def export_emails
    if params[:ids].present?
      if !params[:check_all_page].nil?
        params[:intake_year] = params["filter"]["intake(1i)"] if params["filter"].present?
        params[:intake_month] = params["filter"]["intake(2i)"] if params["filter"].present?
        
        if params[:is_individual] == "false"
          params[:contact_types] = nil
        end        
        
        @contacts = Contact.filters(params, current_user)
      else
        @contacts = Contact.where(id: params[:ids])
      end
    end      
    render layout: "content"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:bases, :mailing_address, :preferred_mailing, :account_manager_id, :base_id, :base_password, :invoice_required, :invoice_info_id, :payment_type, :preferred_mailing, :birthday, :sex, :referrer_id, :is_individual, :mobile_2, :email_2, :first_name, :last_name, :image, :city_id, :website, :name, :phone, :mobile, :fax, :email, :address, :tax_code, :note, :account_number, :bank, :contact_type_id, :parent_ids => [], :agent_ids => [], :company_ids => [], :contact_type_ids => [], :course_type_ids => [], :lecturer_course_type_ids => [])
    end
end
