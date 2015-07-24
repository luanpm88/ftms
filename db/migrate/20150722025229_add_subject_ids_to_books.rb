class AddSubjectIdsToBooks < ActiveRecord::Migration
  def change
    add_column :books, :subject_ids, :text
  end
end
