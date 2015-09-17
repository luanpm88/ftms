class AddSponsoredCompanyIdToCourseRegisters < ActiveRecord::Migration
  def change
    add_column :course_registers, :sponsored_company_id, :integer
  end
end
