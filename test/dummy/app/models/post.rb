class Post < ActiveRecord::Base
  belongs_to :user

  redundancy :user, :name
end
