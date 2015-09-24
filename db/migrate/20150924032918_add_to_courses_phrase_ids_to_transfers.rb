class AddToCoursesPhraseIdsToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :to_courses_phrase_ids, :text
  end
end
