require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  def setup
    @locale = 'en'
    @good_man = humans(:good_man)
    @bad_man = humans(:bad_man)
    @admin = humans(:admin)

    @good_photo = photos(:good_photo)
    @good_comment = comments(:good_comment)
    @good_comment_attributes = { text: 'Very good photo' }
    @bad_comment_attributes = { text: 'lalala' * 50 }
  end

  #------------------------------- create action -------------------------------

  # logged out users must be redirected
  test 'create action: logged out users must be redirected' do
    post :create, photo_id: @good_photo.id, comment: @good_comment_attributes,
                  locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # logged in users must have access
  test 'create action: logged in users must have access' do
    log_in(@good_man.id)
    post :create, photo_id: @good_photo.id, comment: @good_comment_attributes,
                  locale: @locale
    assert_redirected_to photo_path(assigns(:comment).photo_id) + '#bottom'
  end

  # any user can comment any photo
  test 'create action: any user can comment any photo' do
    log_in(@bad_man.id)
    post :create, photo_id: @good_photo.id, comment: @good_comment_attributes,
                  locale: @locale
    assert_redirected_to photo_path(assigns(:comment).photo_id) + '#bottom'
  end

  # id must be right
  test 'create action: id must be right' do
    log_in(@good_man.id)
    post :create, photo_id: 'wrong_id', comment: @good_comment_attributes,
                  locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # wrong attributes must be handled
  test 'create action: wrong attributes must be handled' do
    log_in(@good_man.id)
    post :create, photo_id: @good_photo.id, comment: @bad_comment_attributes,
                  locale: @locale
    assert_redirected_to photo_path(assigns(:comment).photo_id) + '#'
    assert assigns(:comment).errors.any?
    assert_not flash.empty?
  end

  # if "no attributes" request - must be handled
  test "create action: if 'no attributes' request - must be handled" do
    log_in(@good_man.id)
    post :create, photo_id: @good_photo.id, locale: @locale
    assert_redirected_to photo_path(assigns(:comment).photo_id) + '#'
    assert assigns(:comment).errors.any?
    assert_not flash.empty?
  end

  # if "wrong type attributes" request - must be handled
  test "create action: if 'wrong type attributes' request - must be handled" do
    log_in(@good_man.id)
    post :create, photo_id: @good_photo.id, comment: 'lalala', locale: @locale
    assert_redirected_to photo_path(assigns(:comment).photo_id) + '#'
    assert assigns(:comment).errors.any?
    assert_not flash.empty?
  end

  #-------------------------------- destroy action -----------------------------

  # logged out users must be redirected to login form
  test 'destroy action: logged out users must be redirected to login form' do
    delete :destroy, id: @good_comment.id, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # users mustn't have ability to delete someone else comment
  test "destroy action: users mustn't delete someone else comment" do
    log_in(@bad_man.id)
    delete :destroy, id: @good_comment.id, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # logged in users must have ability to delete their comment
  test 'destroy action: users must have ability to delete their comment' do
    log_in(@good_man.id)
    delete :destroy, id: @good_comment.id, locale: @locale
    assert_redirected_to photo_path(assigns(:comment).photo_id)
    assert_not flash.empty?
  end

  # admin must have access to destroy any comment
  test 'destroy action: admin must have access to destroy any comment' do
    log_in(@admin.id)
    delete :destroy, id: @good_comment.id, locale: @locale
    assert_redirected_to photo_path(assigns(:comment).photo_id)
    assert_not flash.empty?
  end

  # comment id must be right
  test 'destroy action: comment id must be right' do
    log_in(@admin.id)
    delete :destroy, id: 'wrong_id', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end
end
