require 'test_helper'

class HasManyBelongsToAssociationTest < ActiveSupport::TestCase

  # has_many:belongs_to association
  # cache_method
  test "should update user.posts_count when create post" do
    user = users(:one)
    post = Post.create(title: 'title', content: 'content', user: user)
    assert_equal user.raw_posts_count, user.posts_count
  end

  test "should update user.posts_star when create post" do
    user = users(:one)
    post = Post.create(title: 'title', content: 'content', user: user, star: 5)
    assert_equal user.raw_posts_star, user.posts_star
  end

  test "should update user.posts_star when create post without star" do
    user = users(:one)
    post = Post.create(title: 'title', content: 'content', user: user)
    assert_equal user.raw_posts_star, user.posts_star
  end

  test "should update nothing when create post without user" do
    post = Post.create(title: 'title', content: 'content')
  end

  test "should update user.posts_star when update post.user" do
    user = users(:one)
    post = posts(:two)
    assert_equal user.raw_posts_star, user.posts_star

    post.update_attribute(:user, user)
    assert_equal user.raw_posts_star, user.reload.posts_star
  end

  test "should update user.posts_star when update post.user with nil" do
    user = users(:one)
    post = posts(:one)
    assert_equal user.raw_posts_star, user.posts_star

    post.update_attribute(:user, nil)
    assert_equal user.raw_posts_star, user.reload.posts_star
  end

  test "should update user.posts_star when update post.user with other user" do
    user = users(:one)
    other_user = users(:two)
    post = posts(:one)
    other_post = posts(:two)
    assert_equal user.raw_posts_star, user.posts_star
    assert_equal other_user.raw_posts_star, other_user.posts_star

    post.update_attribute(:user, other_user)
    assert_equal user.raw_posts_star, user.reload.posts_star
    assert_equal other_user.raw_posts_star, other_user.reload.posts_star
  end

  test "should update user.posts_star when update post.star" do
    user = users(:one)
    post = posts(:one)
    assert_equal user.raw_posts_star, user.posts_star

    post.update_attribute(:star, 5)
    assert_equal user.raw_posts_star, post.user.posts_star
    assert_equal user.raw_posts_star, user.reload.posts_star
  end

end
