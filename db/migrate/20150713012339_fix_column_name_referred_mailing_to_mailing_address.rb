class FixColumnNameReferredMailingToMailingAddress < ActiveRecord::Migration
  def change
    rename_column :contacts, :preferred_mailing, :mailing_address
  end
end
