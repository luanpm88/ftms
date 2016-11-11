class AddCanceledReasonToBooksContact < ActiveRecord::Migration
  def change
    add_column :books_contacts, :canceled_reason, :text
  end
end
