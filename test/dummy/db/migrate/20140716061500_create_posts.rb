class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :user, index: true
      t.string :user_name
      t.string :username

      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
