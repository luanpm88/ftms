class AddHourToCoursesPhrases < ActiveRecord::Migration
  def change
    add_column :courses_phrases, :hour, :integer
  end
end
