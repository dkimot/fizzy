class CreateAgentSessionsAndTurns < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_sessions, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.references :card, type: :uuid, null: false, foreign_key: true
      t.references :creator, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "pending"
      t.string :prompt, null: false
      t.text :result
      t.datetime :completed_at
      t.timestamps
    end

    create_table :agent_session_turns, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.references :agent_session, type: :uuid, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :status, null: false, default: "pending"
      t.text :response
      t.string :tool_name
      t.text :tool_input
      t.text :tool_output
      t.timestamps
    end

    add_index :agent_session_turns, [ :agent_session_id, :position ], unique: true
  end
end
