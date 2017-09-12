class OldTag < ActiveRecord::Base

	has_many :contacts, foreign_key: 'tmp_StudentID', primary_key: 'student_id'

	def self.import_old_tag(database)
		OldTag.destroy_all
		database[:Tags].each do |row|
			tag = OldTag.new
			tag.tag_id = row[:TagID]
			tag.student_id = row[:StudentID]
			tag.tag_name = row[:TagName]
			tag.save
		end
	end

	def self.full_text_search(params)
		tags = self.select(:tag_name).order("tag_name")
		tags = tags.where("LOWER(old_tags.tag_name) LIKE ?", "%#{params[:q].strip.downcase}%") if params[:q].present?
		tags = tags.uniq.limit(50)
		tags = tags.map {|model| {:id => model.tag_name, :text => model.tag_name} }
	end

end
