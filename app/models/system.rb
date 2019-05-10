require "google_drive"

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
    environment = (params[:environment].present? ? params[:environment] : "production")
    bk_dir = Setting.get("backup_dir")
    root_dir = params[:dir].present? ? params[:dir] : ""
    database = YAML.load_file(root_dir+'config/database.yml')[environment]["database"]
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
    backup_cmd += "pg_dump #{database} >> #{bk_dir}/#{dir}/data.dump && " if params[:database].present?
    backup_cmd += "cp -a #{root_dir} #{bk_dir}/#{dir}/ && " if !params[:file].nil? && File.directory?("#{root_dir}uploads")
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
    latest_backup_file = "no file"
    (Dir.glob("#{bk_dir}/*").sort{|a,b| b <=> a}).each do |f|
      if f.include?(".zip")
        latest_backup_file = f
        break
      end
    end
    if !dropbox_list.include?(latest_backup_file.split("/").last)
      # upload backup
      puts "uploading..."
      uploading = `#{root_dir}dropbox_uploader.sh upload #{latest_backup_file} /`
      puts "#{latest_backup_file.split("/").last} uploaded!"

      # remove over 10 backup old
      puts "remove old backup..."

      dropbox_list = `#{root_dir}dropbox_uploader.sh list`
      dropbox_files = []
      dropbox_list.split("\n [F]").each do |s|
        dropbox_files << s.split(" ").last.gsub("\n","") if s.include?(".zip")
      end
      dropbox_files = dropbox_files.sort{|a,b| b <=> a}
      dropbox_files.each_with_index do |f,index|
        if index > revision_max-1
          `#{root_dir}dropbox_uploader.sh delete #{f}`
          puts "#{f} deleted!"
        end
      end

      puts "Done!"
    end
  end

  # google drive
  def self.upload_backup_to_google_drive(params)
    bk_dir = Setting.get("backup_dir")
    root_dir = params[:dir].present? ? params[:dir] : ""
    revision_max = Setting.get("dropbox_backup_revision_count").strip.to_i
    backup_folder_name = 'ftms_hcm'

    latest_backup_file = nil
    (Dir.glob("#{bk_dir}/*").sort{|a,b| b <=> a}).each do |f|
      if f.include?(".zip")
        latest_backup_file = f
        break
      end
    end
    return if latest_backup_file.nil?
    file_name = latest_backup_file.split("/").last
    puts "Uploading... " + latest_backup_file

    # Connect
    session = GoogleDrive::Session.from_config(params[:token])

    folder = session.collection_by_title(backup_folder_name)
    if !folder.present?
      folder = session.root_collection.create_subcollection(backup_folder_name)
    end

    files = folder.files

    # Check if already upload
    if files.find { |file| file.title == file_name }
      puts "file exists!"
      return
    end

    # upload file
    folder.upload_from_file(latest_backup_file, file_name, convert: false)

    # Delete last file if revision_max
    files = folder.files
    count = files.count
    files.each_with_index do |file,index|
      if index >= revision_max
        puts "Deleting old backup... #{file.title}"
        file.delete(true)
      end
    end

    puts "done"
  end
end
