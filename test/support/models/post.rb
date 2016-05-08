class Post < ActiveRecord::Base
  belongs_to :user
  has_one :account, through: :user

  cache_column :account, :email

  cache_column :user, :name
  cache_column :user, :name, cache_column: :username

  cache_method :user, :posts_count
  cache_method :user, :posts_star
end
