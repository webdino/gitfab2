class CreateBlackLists < ActiveRecord::Migration[5.2]
  def change
    create_table :black_lists, comment: "アクセスランキングブラックリスト" do |t|
      t.references :project, type: :integer, foreign_key: true, null: false, comment: "ブラックリスト対象プロジェクト"
      t.references :user, type: :integer, foreign_key: true, null: false, comment: "登録した管理者"
      t.text :reason, null: false, comment: "理由"

      t.timestamps
    end
  end
end
