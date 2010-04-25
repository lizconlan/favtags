class DropJobsTable < ActiveRecord::Migration
  def self.up
    drop_table :jobs
  end

  def self.down
    create_table :jobs do |t|
      t.string  :worker_class
      t.string  :worker_method
      
      t.text    :args
      t.text    :result

      t.integer :priority

      t.integer :progress
      t.string  :state
      
      t.integer :lock_version, :default => 0
      
      t.timestamp :start_at
      t.timestamp :started_at
      t.timestamps
    end

    add_index :jobs, :state
    add_index :jobs, :start_at
    add_index :jobs, :priority
  end
end
