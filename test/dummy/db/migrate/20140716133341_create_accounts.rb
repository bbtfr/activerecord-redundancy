class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :user_name
      
      t.string :email

      t.timestamps
    end
  end
end
