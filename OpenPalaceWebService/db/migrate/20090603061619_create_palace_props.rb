class CreatePalaceProps < ActiveRecord::Migration
  def self.up
    create_table :palace_props, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column :guid, :string, :limit => 36
      t.column :name, :string, :limit => 128
      t.column :width, :integer, :limit => 4
      t.column :height, :integer, :limit => 4
      t.column :offset_x, :integer, :limit => 4
      t.column :offset_y, :integer, :limit => 4
      t.column :legacy_id, :integer
      t.column :legacy_crc, 'integer unsigned'
      t.column :originating_palace, :string
      t.column :flag_head, :boolean, :default => false
      t.column :flag_ghost, :boolean, :default => false
      t.column :flag_rare, :boolean, :default => false
      t.column :flag_animate, :boolean, :default => false
      t.column :flag_palindrome, :boolean, :default => false
      t.column :flag_bounce, :boolean, :default => false
      t.timestamps
    end
    add_index :palace_props, :guid
    add_index :palace_props, :legacy_id
    add_index :palace_props, :legacy_crc
    add_index :palace_props, :originating_palace
  end

  def self.down
    remove_index :palace_props, :originating_palace
    remove_index :palace_props, :legacy_crc
    remove_index :palace_props, :legacy_id
    remove_index :palace_props, :guid
    drop_table :palace_props
  end
end
