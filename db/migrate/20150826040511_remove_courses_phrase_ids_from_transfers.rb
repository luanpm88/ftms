class RemoveCoursesPhraseIdsFromTransfers < ActiveRecord::Migration
  def change
    remove_column :transfers, :courses_phrase_ids
  end
end
