class AddUpfrontToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :upfront, :boolean
  end
end
