class CreateOldConsultants < ActiveRecord::Migration
  def change
    create_table :old_consultants do |t|
      t.text :consultant_id 
      t.text :consultant_name

      t.timestamps null: false
    end
  end
end
