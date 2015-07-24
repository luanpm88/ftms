class AddMailingAddressToCourseRegister < ActiveRecord::Migration
  def change
    add_column :course_registers, :mailing_address, :string
  end
end
