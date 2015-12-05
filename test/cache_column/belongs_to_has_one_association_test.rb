require 'test_helper'

class BelongsToHasOneAssociationTest < ActiveSupport::TestCase

  # belongs_to:has_one association
  test "should update account.user_name when create account" do
    user = users(:one)
    account = Account.create(email: 'email@email.com', user: user)
    assert_equal user.name, account.user_name
  end

  test "should update account.user_name when create account without user" do
    account = Account.create(email: 'email@email.com')
    assert_equal nil, account.user_name
  end

  test "should update account.user_name when update account.user" do
    user = users(:one)
    account = accounts(:two)
    assert_not_equal user.name, account.user_name

    account.update_attribute(:user, user)
    assert_equal user.name, account.user_name
    assert_equal user.name, account.reload.user_name
  end

  test "should update account.user_name when update account.user with nil" do
    user = users(:one)
    account = accounts(:one)
    assert_equal user.name, account.user_name

    account.update_attribute(:user, nil)
    assert_equal nil, account.user_name
    assert_equal nil, account.reload.user_name
  end

  test "should update account.user_name when update account.user with other user" do
    user = users(:one)
    other_user = users(:two)
    account = accounts(:one)
    other_account = accounts(:two)
    assert_equal user.name, account.user_name
    assert_equal other_user.name, other_account.user_name

    account.update_attribute(:user, other_user)
    assert_equal other_user.name, account.user_name
    assert_equal other_user.name, account.reload.user_name
    assert_equal nil, other_account.user
    assert_equal nil, other_account.reload.user_name
  end

  test "should update account.user_name when update user.name" do
    user = users(:one)
    account = accounts(:one)
    assert_equal user.name, account.user_name

    user.update_attribute(:name, "Other Name")
    assert_equal user.name, user.account.user_name
    assert_equal user.name, account.reload.user_name
  end

end
