class CreateNamespaces < ActiveRecord::Migration
  def change
    create_table :namespaces do |t|
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
