class AddCountColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :states_count, :integer, null: false, default: 0
    up_only do
      execute(<<~SQL)
        UPDATE projects
        INNER JOIN (
          SELECT project_id, COUNT(id) cards_count
          FROM cards
          WHERE type = 'Card::State'
          GROUP BY project_id
        ) t2
        ON projects.id = t2.project_id
        SET states_count = t2.cards_count
      SQL
    end

    add_column :projects, :usages_count, :integer, null: false, default: 0
    up_only do
      execute(<<~SQL)
        UPDATE projects
        INNER JOIN (
          SELECT project_id, COUNT(id) cards_count
          FROM cards
          WHERE type = 'Card::Usage'
          GROUP BY project_id
        ) t2
        ON projects.id = t2.project_id
        SET usages_count = t2.cards_count
      SQL
    end

    add_column :projects, :note_cards_count, :integer, null: false, default: 0
    up_only do
      execute(<<~SQL)
        UPDATE projects
        INNER JOIN (
          SELECT project_id, COUNT(id) cards_count
          FROM cards
          WHERE type = 'Card::NoteCard'
          GROUP BY project_id
        ) t2
        ON projects.id = t2.project_id
        SET note_cards_count = t2.cards_count
      SQL
    end

    add_column :cards, :comments_count, :integer, null: false, default: 0
    up_only do
      execute(<<~SQL)
        UPDATE cards
        INNER JOIN (
          SELECT card_id, COUNT(id) comment_count
          FROM card_comments
          GROUP BY card_id
        ) t2
        ON cards.id = t2.card_id
        SET cards.comments_count = t2.comment_count
      SQL
    end
  end
end
