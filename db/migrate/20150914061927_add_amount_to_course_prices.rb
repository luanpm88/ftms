class AddAmountToCoursePrices < ActiveRecord::Migration
  def change
    add_column :course_prices, :amount, :decimal
  end
end
