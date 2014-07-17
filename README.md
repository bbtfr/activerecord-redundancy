Redundancy
==========

Sometimes, for better performance, you may need database redundancy, which means you will store the same information in different tables. For example, you may want to save `username` into `posts` table, rather than just store `user_id` in it.

Redundancy allows you to quickly make a cache column in ActiveRecord.

How it works
------------

```ruby
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name

      t.timestamps
    end
  end
end

class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :user, index: true
      t.string :user_name
      
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end

class User < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :user

  redundancy :user, :name
end
```

Here Redundancy do 2 things for you:

1. when we create or update a post, it will check `post.user_id_changed?`, if true, it will update `user_name` by calling `post.write_attribute(:user_name, post.user.name)`
2. when we update a user, it will check `user.name_changed?`, if true, it will update the `user_name` of all related posts by calling `user.posts.update_all(:user_name => user.name)`


Usage
-----

```ruby
redundancy association, attribute, options
```

available options:

1. __cache_column__ - Specify the column used to store the cached attribute, by default this is :"#{association}_#{attribute}", e.g.: user.name will cached in post.user_name
2. __inverse_of__ - Specifies the name of the associated object that is the inverse of this association, by default this is singular or plural of the current model name, e.g.: :post or :posts.

Installation
------------

Install the gem by adding it to your Gemfile and bundle it up:

```ruby
gem 'activerecord-redundancy', github: 'bbtfr/activerecord-redundancy'
```

And you are ready to go.

Note: This gem is only tested on Rails 3.2 and 4.

This project rocks and uses MIT-LICENSE.