class User < ActiveRecord::Base
  has_many :posts
  belongs_to :account

  cache_column :account, :email

  def raw_posts_count
    posts.count
  end

  def raw_posts_star
    posts.average(:star)
  end
end
