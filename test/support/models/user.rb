class User < ActiveRecord::Base
  belongs_to :account
  has_one :session
  has_many :posts

  cache_column :account, :email

  def raw_posts_count
    posts.count
  end

  def raw_posts_star
    posts.average(:star)
  end
end
