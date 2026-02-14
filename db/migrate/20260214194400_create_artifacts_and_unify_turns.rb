class CreateArtifactsAndUnifyTurns < ActiveRecord::Migration[8.1]
  def change
    create_table :artifacts, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.string :mime_type, null: false, default: "text/plain"
      t.timestamps
    end

    create_table :turns, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.references :parent, type: :uuid, null: false, polymorphic: true
      t.references :creator, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :artifact, type: :uuid, foreign_key: true
      t.string :role, null: false
      t.integer :position
      t.text :content, null: false, default: ""
      t.string :status, null: false, default: "pending"
      t.string :tool_name
      t.text :tool_input
      t.text :tool_output
      t.boolean :streaming, null: false, default: false
      t.timestamps
    end

    add_index :turns, [ :parent_type, :parent_id, :position ], unique: true

    drop_table :agent_session_turns
    drop_table :chat_messages
  end
end
