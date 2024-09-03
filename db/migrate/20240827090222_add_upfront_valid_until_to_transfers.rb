class AddUpfrontValidUntilToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :upfront_valid_until, :datetime
  end
end
