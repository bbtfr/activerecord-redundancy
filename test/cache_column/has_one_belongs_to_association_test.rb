require 'test_helper'

class HasOneBelongsToAssociationTest < ActiveSupport::TestCase

  # has_one:belongs_to association
  test "should update user.account_email when create user" do
    account = accounts(:one)
    user = User.create(name: 'Name', account: account)
    assert_equal account.email, user.account_email
  end

  test "should update user.account_email when create user without account" do
    user = User.create(name: 'Name')
    assert_equal nil, user.account_email
  end

  test "should update user.account_email when update user.account" do
    account = accounts(:one)
    user = users(:two)
    assert_not_equal account.email, user.account_email

    user.update_attribute(:account, account)
    assert_equal account.email, user.account_email
    assert_equal account.email, user.reload.account_email
  end

  test "should update user.account_email when update user.account with nil" do
    account = accounts(:one)
    user = users(:one)
    assert_equal account.email, user.account_email

    user.update_attribute(:account, nil)
    assert_equal nil, user.account_email
    assert_equal nil, user.reload.account_email
  end

  test "should update user.account_email when update user.account with other account" do
    account = accounts(:one)
    other_account = accounts(:two)
    user = users(:one)
    other_user = users(:two)
    assert_equal account.email, user.account_email
    assert_equal other_account.email, other_user.account_email

    user.update_attribute(:account, other_account)
    assert_equal other_account.email, user.account_email
    assert_equal other_account.email, user.reload.account_email
    assert_equal other_account, other_user.account
    assert_equal other_account.email, other_user.account_email
    assert_equal other_account.email, other_user.reload.account_email
  end

  test "should update user.account_email when update account.email" do
    account = accounts(:one)
    user = users(:one)
    assert_equal account.email, user.account_email

    account.update_attribute(:email, "other@email.com")
    assert_equal account.email, account.user.account_email

    assert_equal account.email, user.reload.account_email
  end

end
