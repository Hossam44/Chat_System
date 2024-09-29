class CreateChats < ActiveRecord::Migration[5.2]
  def change
    create_table :chats, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
      t.integer :number
      t.integer :messages_count, default: 0
      t.bigint :application_id
      t.timestamps
    end

    add_index :chats, [:application_id, :number], unique: true, name: 'index_chats_on_application_id_and_number'
    add_index :chats, :application_id

    add_foreign_key :chats, :applications
  end
end
