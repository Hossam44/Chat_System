class CreateApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :applications, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
      t.string :name
      t.string :token
      t.integer :chats_count, default: 0
      t.timestamps
    end

    add_index :applications, :token, unique: true
  end
end
