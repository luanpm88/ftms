class AddTmpStudentIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :tmp_StudentID, :text
  end
end
