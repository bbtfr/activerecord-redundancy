class Post < ActiveRecord::Base
  belongs_to :user

  redundancy :user, :name
  redundancy :user, :name, cache_column: :username
end
