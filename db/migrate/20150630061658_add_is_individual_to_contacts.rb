class AddIsIndividualToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :is_individual, :boolean, default: true
  end
end
