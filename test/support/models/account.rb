class Account < ActiveRecord::Base
  has_one :user
  
  redundancy :user, :name
end
