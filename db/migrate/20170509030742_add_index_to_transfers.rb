class AddIndexToTransfers < ActiveRecord::Migration
  def change
    add_index :transfers, :courses_phrase_ids
    add_index :transfers, :to_courses_phrase_ids
    add_index :transfers, :to_contact_id
    add_index :transfers, :contact_id
  end
end
