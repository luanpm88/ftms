class ContactsController < ApplicationController
  helper :headshot
  
  include ContactsHelper
  
  load_and_authorize_resource
  before_action :set_contact, only: [:print, :part_info, :remove_related_contact, :delete, :course_register, :ajax_quick_info, :ajax_tag_box, :ajax_edit, :ajax_update, :show, :edit, :update, :destroy, :ajax_destroy, :ajax_show, :ajax_list_agent, :ajax_list_supplier_agent]

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
    @contact.email_2 = params[:email_2s]
    @contact.mobile_2 = params[:mobile_2s]
    
    
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
        #if params[:contact_tag].present?
        #  @contact.update_tag(@contact_tag, current_user)
        #end        
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
    
    #if params[:contact_tag].present?
    #  @contact_tag = ContactTag.find(params[:contact_tag])
    #end
    
    if params[:avatar_method] == "camera" && params[:headshot_url].present?
          filename = params[:headshot_url].split("/").last
          @contact.image = File.open("public/headshots/"+filename)
          @contact.save
    end
    
    if params[:avatar_method] == "upload" && params[:remove_avatar].present?
      @contact.remove_image!
      @contact.save
    end
    
    s_params = contact_params
    s_params[:course_type_ids] = contact_params[:course_type_ids][0].split(",") if contact_params[:course_type_ids].present?
    s_params[:lecturer_course_type_ids] = contact_params[:lecturer_course_type_ids][0].split(",") if contact_params[:lecturer_course_type_ids].present?
    
    #base
    @contact.update_bases(params[:bases])
    @contact.email_2 = params[:email_2s]
    @contact.mobile_2 = params[:mobile_2s]
    
    # remove tag if empty
    if !s_params[:contact_tag_ids].present?
      @contact.contact_tags = []
    end
    
    
    respond_to do |format|
      if @contact.update(s_params)
        #if params[:contact_tag].present?
        #  @contact.update_tag(@contact_tag, current_user)
        #end        
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
        
        format.html { render "/contacts/deleted", layout: nil }
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

  def merge_contacts_datatable
    
    result = Contact.merge_contacts_datatable(params, current_user, session)
    
    result[:items].each_with_index do |item, index|
      actions = render_contacts_actions(item,nil,params)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end

  def merge_contacts
    # Contact.find_related_contacts
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
    # params[:type] = params[:type].present? ? params[:type] : "thumb3x"
    send_file @contact.logo_path(params[:type]), :disposition => 'inline'
  end
  
  def update_tag
    contact_tag = ContactTag.find(params[:tag_id])
    if params[:type] == "add"
      @contact.contact_tags << contact_tag if !@contact.contact_tags.include?(contact_tag)
    else
      n_tags = []
      @contact.contact_tags.each do |tag|
        n_tags << tag if contact_tag != tag
      end
      @contact.update_attribute(:contact_tag_ids, n_tags.map(&:id))
    end
    @contact.save
    @contact.update_cache_search
    
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
      @contacts = Contact.main_contacts #.where.not(id: @contact.draft_for)
      
      @contacts = @contacts.where.not(id: params[:id].strip) if params[:id].present?
      
      if params[:type] == "mobile"
        @contacts = @contacts.where("LOWER(#{params[:type]}) = ?", Contact.format_mobile(params[:value]).strip.downcase)
      else
        @contacts = @contacts.where("LOWER(#{params[:type]}) = ?", params[:value].strip.downcase)
      end
      
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
      format.html { render "/contacts/deleted", layout: nil }
      format.json { render action: 'show', status: :created, location: @subject }
    end
  end
  
  def undo_delete
    authorize! :undo_delete, @contact
    
    @contact.undo_delete(current_user)
    
    respond_to do |format|
      format.html { render "/contacts/undo_delete", layout: nil }
      format.json { render action: 'show', status: :created, location: @contact }
    end
  end
  
  def approve_all
    authorize! :approve_all, Contact
    
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
    
    @contacts.each do |c|
      c.approve_delete(current_user) if current_user.can?(:approve_delete, c)
      c.approve_new(current_user) if current_user.can?(:approve_new, c)
      c.approve_update(current_user) if current_user.can?(:approve_update, c)
      c.approve_education_consultant(current_user) if current_user.can?(:approve_education_consultant, c)
    end
    
    respond_to do |format|
      format.html { render "/course_registers/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @course_register }
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
  
  def remove_related_contact
    group = @contact.group
    group.remove_contact(Contact.find(params[:remove_id]))
    if params[:redirect] == "ajax"
      render text: "Contact was removed from related contacts"
    else
      respond_to do |format|
        @tab = {url: {controller: "contacts", action: "edit", id: @contact.id, tab_page: 1, tab: "old_info"}, title: @contact.display_name+" #"+@contact.id.to_s}
        format.html { render "/home/close_tab", layout: nil }
      end
    end      
  end
  
  def undo_remove_related_contact
    group = @contact.group
    group.restore_contact(Contact.find(params[:remove_id]))
    respond_to do |format|
      @tab = {url: {controller: "contacts", action: "edit", id: @contact.id, tab_page: 1, tab: "old_info"}, title: @contact.display_name+" #"+@contact.id.to_s}
      format.html { render "/home/close_tab", layout: nil }
    end
  end
  
  def not_related_contacts
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
    
    Contact.add_no_related_contacts(@contacts)
    
    render text: "Done! Contacts were checked as not the same contact."
  end
  
  def part_info
    render json: {
      col_1: '<div class="text-left"><strong>'+@contact.contact_link+"</strong></div>"+'<div class="text-left">'+@contact.html_info_line.html_safe+@contact.referrer_link+"</div>"+@contact.picture_link,
      col_2: '<div class="text-left">'+@contact.course_types_name_col+"</div>",
      col_3: '<div class="text-center">'+@contact.course_count_link+@contact.display_transferred_courses_phrases(params[:courses])+"</div>",
      col_4: '<div class="text-center contact_tag_box" rel="'+@contact.id.to_s+'">'+ContactsController.helpers.render_contact_tags_selecter(@contact)+"</div>",
      col_5: '<div class="text-center">'+@contact.created_at.strftime("%d-%b-%Y")+"<br /><strong>by:</strong><br />"+@contact.user.staff_col+"</div>",
      col_6: '<div class="text-center">'+@contact.account_manager_col+"</div>",
      col_7: '<div class="text-center">'+@contact.display_statuses+@contact.display_bases("<br />")+"</div>"
    }
  end
  
  def do_merge
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
    
    Contact.merge_contacts(@contacts)
    
    render text: "Contacts ware successfully merged.!"
  end
  
  def print
    #render layout: nil
    render  :pdf => "delivery_"+@contact.name.unaccent.gsub(" ","_"),
            :template => 'contacts/print.html.erb',
            :layout => nil,
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:bases, :mailing_address, :preferred_mailing, :account_manager_id, :base_id, :base_password, :invoice_required, :invoice_info_id, :payment_type, :preferred_mailing, :birthday, :sex, :referrer_id, :is_individual, :mobile_2, :first_name, :last_name, :image, :city_id, :website, :name, :phone, :mobile, :fax, :email, :address, :tax_code, :note, :account_number, :bank, :contact_type_id, :email_2 => [], :parent_ids => [], :agent_ids => [], :company_ids => [], :contact_type_ids => [], :course_type_ids => [], :lecturer_course_type_ids => [], :contact_tag_ids => [])
    end
end
