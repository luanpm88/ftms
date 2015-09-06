class AddParentIdToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :parent_id, :integer
  end
end
