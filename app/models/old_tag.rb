class OldTag < ActiveRecord::Base

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
		tags = self.order("tag_name")
		tags = tags.where("LOWER(old_tags.tag_name) LIKE ?", "%#{params[:q].strip.downcase}%") if params[:q].present?
		tags = tags.limit(50)
		tags = (tags.map {|c| c.tag_name}).uniq
		tags = tags.map {|model| {:id => model, :text => model} }
	end

end
