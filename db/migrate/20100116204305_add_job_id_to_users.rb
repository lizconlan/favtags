class AddJobIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :job_id, :integer
  end

  def self.down
    remove_column :users, :job_id
  end
end
