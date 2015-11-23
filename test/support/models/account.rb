class Account < ActiveRecord::Base
  has_one :user

  cache_column :user, :name
end
