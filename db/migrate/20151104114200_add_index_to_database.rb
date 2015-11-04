class AddIndexToDatabase < ActiveRecord::Migration
  def change
    add_index :bank_accounts, :status
    add_index :bank_accounts, :annoucing_user_ids
    
    add_index :books, :status
    add_index :books, :annoucing_user_ids
    
    add_index :contacts, :status
    add_index :contacts, :cache_search
    add_index :contacts, :email
    add_index :contacts, :mobile
    add_index :contacts, :no_related_ids
    add_index :contacts, :cache_courses
    add_index :contacts, :cache_phrases
    add_index :contacts, :bases
    add_index :contacts, :cache_subjects
    
    add_index :course_registers, :cache_search
    add_index :course_registers, :status
    add_index :course_registers, :cache_payment_status
    add_index :course_registers, :annoucing_user_ids
    
    add_index :course_types, :status
    add_index :course_types, :annoucing_user_ids
    
    add_index :contact_tags, :status
    add_index :contact_tags, :annoucing_user_ids
    
    add_index :courses, :status
    add_index :courses, :annoucing_user_ids
    
    add_index :discount_programs, :status
    add_index :discount_programs, :annoucing_user_ids
    
    add_index :phrases, :status
    add_index :phrases, :annoucing_user_ids
    
    add_index :seminars, :status
    add_index :seminars, :annoucing_user_ids
    
    add_index :stock_types, :status
    add_index :stock_types, :annoucing_user_ids
    
    add_index :subjects, :status
    add_index :subjects, :annoucing_user_ids
    
    add_index :transfers, :status
    add_index :transfers, :annoucing_user_ids
    
    add_index :transfer_details, :courses_phrase_ids
    
  end
end
