class PhrasesSubject < ActiveRecord::Base
  belongs_to :subject
  belongs_to :phrase
end
