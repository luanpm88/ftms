class AddCoursesPhraseIdsToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :courses_phrase_ids, :text
  end
end
