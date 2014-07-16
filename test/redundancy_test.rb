require 'test_helper'

class RedundancyTest < ActiveSupport::TestCase
  test "should update post.user_name when create post" do
    user = users(:one)
    post = Post.create(title: 'title', content: 'content', user: user)
    assert_equal post.user_name, user.name
  end

  test "should update post.user_name when create post without user" do
    post = Post.create(title: 'title', content: 'content')
    assert_equal post.user_name, nil
  end

  test "should update post.user_name when update post.user" do
    user = users(:one)
    post = posts(:two)
    assert_not_equal post.user_name, user.name

    post.update_attribute(:user, user)
    assert_equal post.user_name, user.name
  end

  test "should update post.user_name when update post.user with nil" do
    user = users(:one)
    post = Post.create(title: 'title', content: 'content', user: user)
    assert_equal post.user_name, user.name

    post.update_attribute(:user, nil)
    assert_equal post.user_name, nil
  end

  test "should update post.user_name when update user.name" do
    user = users(:one)
    post = Post.create(title: 'title', content: 'content', user: user)
    assert_equal post.user_name, user.name

    user.update_attribute(:name, "Other Name")
    user.posts.each do |post|
      assert_equal post.user_name, user.name
    end
    
    assert_not_equal post.user_name, user.name
    assert_equal post.reload.user_name, user.name
  end
end
