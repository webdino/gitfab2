class CreateNamespaces < ActiveRecord::Migration
  def change
    create_table :namespaces do |t|
      t.belongs_to :owner, index: true
      t.string :name, index: true

      t.timestamps
    end
  end
end
