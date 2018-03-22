class CreateProjectTempLinks < ActiveRecord::Migration
  def change
    create_table :project_temp_links do |t|
      t.integer :project_id
      t.string :url_hash, :limit => 50
    end
  end
end
