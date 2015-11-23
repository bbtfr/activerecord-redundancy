class Post < ActiveRecord::Base
  belongs_to :user

  cache_column :user, :name
  cache_column :user, :name, cache_column: :username

  cache_method :user, :posts_count
  cache_method :user, :posts_star
end
