class Account < ActiveRecord::Base
  has_one :user
  has_one :session, through: :user
  has_many :posts, through: :user

  cache_column :user, :name
end
