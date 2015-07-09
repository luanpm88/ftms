class ContactsSeminar < ActiveRecord::Base
  belongs_to :contact
  belongs_to :seminar
end
