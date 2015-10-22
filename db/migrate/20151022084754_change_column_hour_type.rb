class ChangeColumnHourType < ActiveRecord::Migration
  def up
    change_column :courses_phrases, :hour, :decimal
  end

  def down
    change_column :courses_phrases, :hour, :integer
  end
end
