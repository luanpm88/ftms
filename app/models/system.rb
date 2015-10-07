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
    bk_dir = "/media/sdb1/ftms-backup"
    
    # remove over 100 backup old
    @files = Dir.glob("#{bk_dir}/*").sort{|a,b| b <=> a}
    @files.each_with_index do |f,index|
      if index > 10
        `rm -rf #{f}`
      end      
    end
    
    dir = Time.now.strftime("%Y_%m_%d_%H%M%S")
    dir += "_db" if !params[:database].nil?
    dir += "_source" if !params[:file].nil?
    
    
    
    #`mkdir backup` if !File.directory?("backup")
    #`mkdir #{bk_dir}/#{dir}`
    
    backup_cmd = "mkdir #{bk_dir}/#{dir} && "
    backup_cmd += "pg_dump -a ftms_#{params[:environment]} >> #{bk_dir}/#{dir}/data.dump && " if params[:database].present? && params[:environment].present?
    backup_cmd += "cp -a uploads #{bk_dir}/#{dir}/ && " if !params[:file].nil? && File.directory?("uploads")
    backup_cmd += "zip -r #{bk_dir}/#{dir}.zip #{bk_dir}/#{dir} && "
    backup_cmd += "rm -rf #{bk_dir}/#{dir}"
    
    puts backup_cmd
    
    `#{backup_cmd} &`
    
    if !File.directory?(dir)
      `rm -rf #{bk_dir}/#{dir}`
    end
  end
end