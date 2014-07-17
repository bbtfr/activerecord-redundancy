class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :account
      t.string :account_email
      
      t.string :name

      t.timestamps
    end
  end
end
