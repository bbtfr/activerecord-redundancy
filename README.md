Redundancy
==========

[![Gem Version](https://fury-badge.herokuapp.com/rb/activerecord-redundancy.png)](http://badge.fury.io/rb/activerecord-redundancy)
[![Build Status](https://api.travis-ci.org/bbtfr/activerecord-redundancy.png?branch=master)](http://travis-ci.org/bbtfr/activerecord-redundancy)
[![Code Climate](https://codeclimate.com/github/bbtfr/activerecord-redundancy.png)](https://codeclimate.com/github/bbtfr/activerecord-redundancy)

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

  def raw_posts_count
    posts.count
  end
end

class Post < ActiveRecord::Base
  belongs_to :user

  cache_column :user, :name
  cache_method :user, :posts_count
end
```

Here Redundancy do 2 things for you:

1. when we create or update a post, it will check `post.user_id_changed?`, if true, it will update `user_name` by calling `post.write_attribute(:user_name, post.user.name)`
2. when we update a user, it will check `user.name_changed?`, if true, it will update the `user_name` of all related posts by calling `user.posts.update_all(:user_name => user.name)`


Usage
-----

### CacheColumn

```ruby
cache_column association, attribute, options
```

available options:

1. __cache_column__ - Specify the column used to store the cached attribute, by default this is `:"#{association}_#{attribute}"`, e.g.: `user.name` will cached in `post.user_name`

### CacheMethod

```ruby
cache_method association, attribute, options
```

available options:

1. __cache_method__ - Specify the method need to be cached, by default this is `:"raw_#{attribute}"`, e.g.: `user.raw_orders_count` will cached in `post.orders_count`

Installation
------------

Install the gem by adding it to your Gemfile and bundle it up:

```ruby
gem 'activerecord-redundancy', github: 'bbtfr/activerecord-redundancy'
```

And you are ready to go.

Note: This gem is only tested on Rails 3.2 and 4.

This project rocks and uses MIT-LICENSE.
