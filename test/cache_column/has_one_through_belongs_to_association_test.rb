require 'test_helper'

class HasOneThroughBelongsToAssociationTest < ActiveSupport::TestCase

  # has_one:through:belongs_to association
  test "should update post.account_email when create post" do
    account = accounts(:one)
    user = users(:one)
    post = Post.create(title: 'title', content: 'content', user: user)
    assert_equal account.email, post.account_email
  end

  test "should update post.account_email when update post.user" do
    account = accounts(:one)
    user = users(:one)
    post = posts(:two)
    assert_not_equal account.email, post.account_email

    post.update_attribute(:user, user)
    assert_equal account.email, post.account_email
    assert_equal account.email, post.reload.account_email
  end

  test "should update post.account_email when update user.account" do
    account = accounts(:one)
    user = users(:two)
    post = posts(:two)
    assert_not_equal account.email, post.account_email

    user.update_attribute(:account, account)
    assert_equal account.email, post.reload.account_email
  end

  test "should update post.account_email when update account.email" do
    account = accounts(:one)
    user = users(:one)
    post = posts(:one)
    assert_equal account.email, post.account_email

    account.update_attribute(:email, "other@email.com")
    assert_equal account.email, post.reload.account_email
  end

end
