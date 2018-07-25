class CreateIdentities < ActiveRecord::Migration[5.2]
  def change
    create_table :identities, comment: "認証情報", options: "ROW_FORMAT=DYNAMIC" do |t|
      t.references :user, type: :integer, foreign_key: true
      t.string :provider
      t.string :uid
      t.string :email
      t.string :name
      t.string :nickname
      t.text :image

      t.timestamps
    end
  end
end
