class CreateChatsAndMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :chats, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.references :card, type: :uuid, null: false, foreign_key: true
      t.references :creator, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.string :title
      t.timestamps
    end

    create_table :chat_messages, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.references :chat, type: :uuid, null: false, foreign_key: true
      t.references :creator, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.string :role, null: false
      t.text :content, null: false, default: ""
      t.string :tool_name
      t.text :tool_input
      t.text :tool_output
      t.boolean :streaming, null: false, default: false
      t.timestamps
    end
  end
end
