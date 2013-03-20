class CreateConfigKeys < ActiveRecord::Migration
  def change
    create_table :config_keys do |t|
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
