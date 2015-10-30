class System < ActiveRecord::Base
  def self.columns
    @columns ||= [];
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default,
      sql_type.to_s, null)
  end

  # Override the save method to prevent exceptions.
  def save(validate = true)
    validate ? valid? : true
  end
  
  def self.backup(params)
    bk_dir = Setting.get("backup_dir")
    root_dir = params[:dir].present? ? params[:dir] : ""
    database = YAML.load_file(root_dir+'config/database.yml')["production"]["database"]
    revision_max = Setting.get("backup_revision_count").strip.to_i
    
    # remove over 100 backup old
    @files = Dir.glob("#{bk_dir}/*").sort{|a,b| b <=> a}
    @files.each_with_index do |f,index|
      if index > revision_max-1
        `rm -rf #{f}`
      end      
    end
    
    dir = Time.now.strftime("%Y_%m_%d_%H%M%S")
    dir += "_#{database}"
    dir += "_db" if !params[:database].nil?
    dir += "_source" if !params[:file].nil? 
    
    
    #`mkdir backup` if !File.directory?("backup")
    #`mkdir #{bk_dir}/#{dir}`
    
    backup_cmd = "mkdir #{bk_dir}/#{dir} && "
    backup_cmd += "pg_dump -a #{database} >> #{bk_dir}/#{dir}/data.dump && " if params[:database].present?
    backup_cmd += "cp -a #{root_dir}uploads #{bk_dir}/#{dir}/ && " if !params[:file].nil? && File.directory?("#{root_dir}uploads")
    backup_cmd += "zip -r #{bk_dir}/#{dir}.zip #{bk_dir}/#{dir} && "
    backup_cmd += "rm -rf #{bk_dir}/#{dir}"
    
    puts backup_cmd
    
    `#{backup_cmd} &`
    
    if !File.directory?(dir)
      `rm -rf #{bk_dir}/#{dir}`
    end
  end
  
  def self.upload_backup_to_dropbox(params)
    bk_dir = Setting.get("backup_dir")
    root_dir = params[:dir].present? ? params[:dir] : ""
    revision_max = Setting.get("dropbox_backup_revision_count").strip.to_i
    
    dropbox_list = `#{root_dir}dropbox_uploader.sh list`
    latest_backup_file = (Dir.glob("#{bk_dir}/*").sort{|a,b| b <=> a})[0]
    if !dropbox_list.include?(latest_backup_file.split("/").last)
      # upload backup
      uploading = `#{root_dir}dropbox_uploader.sh upload #{latest_backup_file} /`
      puts "uploaded..."
      
      # remove over 10 backup old
      puts "remove old backup..."
      
      dropbox_list = `#{root_dir}dropbox_uploader.sh list`
      dropbox_files = []
      dropbox_list.split("\n [F] 0 ").each do |s|
        dropbox_files << s.gsub("\n","") if s.include?(".zip")
      end
      dropbox_files = dropbox_files.sort{|a,b| b <=> a}
      dropbox_files.each_with_index do |f,index|
        if index > revision_max-1
          `#{root_dir}dropbox_uploader.sh delete #{f}`
        end
      end
      
      puts "Done!"
    end
  end
end