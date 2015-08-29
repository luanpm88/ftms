class AddTmpSubjectIdToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :tmp_SubjectID, :text
  end
end
