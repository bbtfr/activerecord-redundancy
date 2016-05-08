require 'test_helper'

class OptionsTest < ActiveSupport::TestCase

  # :cache_column option
  test "should update post.username when create post" do
    user = users(:one)
    post = Post.create(title: 'title', content: 'content', user: user)
    assert_equal user.name, post.username
  end

end
