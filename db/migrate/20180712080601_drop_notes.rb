class DropNotes < ActiveRecord::Migration[4.2]
  def up
    # Migrate notes.project_id to cards.project_id
    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE cards
      INNER JOIN notes ON cards.note_id = notes.id
      SET cards.project_id = notes.project_id
    SQL

    remove_reference :cards, :note, foreign_key: true, index: true
    drop_table :notes
  end

  def down
    create_table "notes", force: :cascade do |t|
      t.references "project"
      t.integer  "num_cards",  limit: 4, default: 0, null: false, index: true
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_reference :cards, :note, foreign_key: true, index: true
  end
end
