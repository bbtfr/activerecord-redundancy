require 'test_helper'

class HasManyBelongsToAssociationTest < ActiveSupport::TestCase

  # has_many:belongs_to association
  # cache_column
  test "should update post.user_name when create post" do
    user = users(:one)
    post = Post.create(title: 'title', content: 'content', user: user)
    assert_equal user.name, post.user_name
  end

  test "should update post.user_name when create post without user" do
    post = Post.create(title: 'title', content: 'content')
    assert_equal nil, post.user_name
  end

  test "should update post.user_name when update post.user" do
    user = users(:one)
    post = posts(:two)
    assert_not_equal user.name, post.user_name

    post.update_attribute(:user, user)
    assert_equal user.name, post.user_name
    assert_equal user.name, post.reload.user_name
  end

  test "should update post.user_name when update post.user with nil" do
    user = users(:one)
    post = posts(:one)
    assert_equal user.name, post.user_name

    post.update_attribute(:user, nil)
    assert_equal nil, post.user_name
    assert_equal nil, post.reload.user_name
  end

  test "should update post.user_name when update post.user with other user" do
    user = users(:one)
    other_user = users(:two)
    post = posts(:one)
    other_post = posts(:two)
    assert_equal user.name, post.user_name
    assert_equal other_user.name, other_post.user_name

    post.update_attribute(:user, other_user)
    assert_equal other_user.name, post.user_name
    assert_equal other_user.name, post.reload.user_name
  end

  test "should update post.user_name when update user.name" do
    user = users(:one)
    post = posts(:one)
    assert_equal user.name, post.user_name

    user.update_attribute(:name, "Other Name")
    user.posts.each do |post|
      assert_equal user.name, post.user_name
    end
    assert_equal user.name, post.reload.user_name
  end
end
