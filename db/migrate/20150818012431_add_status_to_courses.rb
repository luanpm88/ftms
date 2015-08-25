class AddStatusToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :status, :text
  end
end
