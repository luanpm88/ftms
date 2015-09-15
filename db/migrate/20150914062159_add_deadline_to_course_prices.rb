class AddDeadlineToCoursePrices < ActiveRecord::Migration
  def change
    add_column :course_prices, :deadline, :datetime
  end
end
