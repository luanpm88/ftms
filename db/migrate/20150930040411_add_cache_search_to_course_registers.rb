class AddCacheSearchToCourseRegisters < ActiveRecord::Migration
  def change
    add_column :course_registers, :cache_search, :text
  end
end
