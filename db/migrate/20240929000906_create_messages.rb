class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
      t.string :body
      t.integer :number
      t.bigint :chat_id
      t.timestamps
    end

    add_index :messages, [:chat_id, :number], unique: true, name: 'index_messages_on_chat_id_and_number'
    add_index :messages, :chat_id

    add_foreign_key :messages, :chats
  end
end
