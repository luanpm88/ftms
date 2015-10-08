class OldCompany < ActiveRecord::Base

	belongs_to :old_link_student, foreign_key: 'company_id', primary_key: 'company_id'
    

	def self.import_old_company(database)
		OldCompany.destroy_all
		database[:Companies].each do |row|
			company = OldCompany.new
			company.company_id = row[:CompanyID]
			company.company_name = row[:CompanyName]
			company.company_address = row[:CompanyAddress]
			company.company_manager = row[:CompanyManager]
			company.company_off_phone = row[:CompanyOffPhone]
			company.company_fax = row[:CompanyFax]
			company.company_manager_hphone = row[:CompanyManagerHPhone]
			company.company_email = row[:CompanyEmail]
			company.save
		end
	end

end