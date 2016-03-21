require 'test_helper'

class PhotoGalleriesControllerTest < ActionController::TestCase
  def setup
    @locale = 'en'
    @good_man = humans(:good_man)
    @bad_man = humans(:bad_man)
    @admin = humans(:admin)
    @good_attributes = { description: 'good description' }
    @bad_attributes = { description: 'bad description' * 50 }
    @good_gallery = photo_galleries(:good_gallery)
  end

  #-------------------------------- new action ---------------------------------

  # logged out users must be redirected
  test 'new action: logged out users must be redirected' do
    get :new, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # logged in users must have access
  test 'new action: logged in users must have access' do
    log_in(@good_man.id)
    get :new, locale: @locale
    assert_response :success
  end

  #------------------------------- create action -------------------------------

  # logged out users must be redirected
  test 'create action: logged out users must be redirected' do
    post :create, photo_gallery: @good_attributes, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # logged in users must have access
  test 'create action: logged in users must have access' do
    log_in(@good_man.id)
    post :create, photo_gallery: @good_attributes, locale: @locale
    assert_redirected_to photo_gallery_photos_path(assigns(:photo_gallery).id)
  end

  # wrong attributes must be handled
  test 'create action: wrong attributes must be handled' do
    log_in(@good_man.id)
    post :create, photo_gallery: @bad_attributes, locale: @locale
    assert_template :new
    assert assigns(:photo_gallery).errors.any?
  end

  # if "no attributes" request - must be handled
  test "create action: if 'no attributes' request - must be handled" do
    log_in(@good_man.id)
    post :create, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # if "wrong type attributes" request - must be handled
  test "create action: if 'wrong type attributes' request - must be handled" do
    log_in(@good_man.id)
    post :create, photo_gallery: 'lalala', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #-------------------------------- show action --------------------------------

  # logged out users must be redirected to login page
  test "show action: logged out users mustn't get access" do
    get :show, id: @good_gallery.id, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # logged in users must get access
  test 'show action: logged in users must get access' do
    log_in(@good_man.id)
    get :show, id: @good_gallery.id, locale: @locale
    assert_response :success
  end

  # user id must be right
  test 'show acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    get :show, id: 'wrong_id', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #---------------------------------- edit action ------------------------------

  # logged out users must be redirected to login form
  test "edit action: logged out users mustn't have access" do
    get :edit, id: @good_gallery.id, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # user mustn't have ability to change someone else gallery
  test "edit action: user mustn't change someone else gallery" do
    log_in(@bad_man.id)
    get :edit, id: @good_gallery.id, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # logged in user must have access to change his gallery
  test 'edit action: logged in user must have access to change his gallery' do
    log_in(@good_man.id)
    get :edit, id: @good_gallery.id, locale: @locale
    assert_response :success
  end

  # admin must have access to change any gallery
  test 'edit action: admin must have access to change any gallery' do
    log_in(@admin.id)
    get :edit, id: @good_gallery.id, locale: @locale
    assert_response :success
  end

  # gallery id must be right
  test 'edit acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    get :edit, id: 'wrong_id', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #--------------------------------- update action -----------------------------

  # logged out users must be redirected to login form
  test "update action: logged out users mustn't have access" do
    patch :update, id: @good_gallery.id, photo_gallery: @good_attributes,
                   locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # user mustn't have ability to change someone else gallery
  test "update action: user mustn't change someone else gallery" do
    log_in(@bad_man.id)
    patch :update, id: @good_gallery.id, photo_gallery: @good_attributes,
                   locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # logged in users must have access to change their gallery
  test 'update action: users must have access to change their gallery' do
    log_in(@good_man.id)
    patch :update, id: @good_gallery.id, photo_gallery: @good_attributes,
                   locale: @locale
    assert_redirected_to photo_gallery_path(assigns(:photo_gallery).id)
  end

  # admin must have access to change any gallery
  test 'update action: admin must have access to change any gallery' do
    log_in(@admin.id)
    patch :update, id: @good_gallery.id, photo_gallery: @good_attributes,
                   locale: @locale
    assert_redirected_to photo_gallery_path(assigns(:photo_gallery).id)
  end

  # gallery id must be right
  test 'update acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    patch :update, id: 'wrong_id', photo_gallery: @good_attributes,
                   locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # wrong attributes request must be handled
  test "update action: if any errors user mustn't be redirected" do
    log_in(@good_man.id)
    patch :update, id: @good_gallery.id, photo_gallery: @bad_attributes,
                   locale: @locale
    assert_template :edit
    assert assigns(:photo_gallery).errors.any?
  end

  # if "no attributes" request - must be handled
  test "update action: if 'no attributes request' - must be handled" do
    log_in(@good_man.id)
    patch :update, id: @good_gallery.id, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # if "empty attributes" request - must be handled
  test "update action: if 'empty attributes request' - must be handled" do
    log_in(@good_man.id)
    patch :update, id: @good_gallery.id, photo_gallery: {}, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # if "wrong type attributes" request - must be handled
  test "update action: if 'wrong type attributes request' - must be handled" do
    log_in(@good_man.id)
    patch :update, id: @good_gallery.id, photo_gallery: 'lalala',
                   locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #-------------------------------- destroy action -----------------------------

  # logged out users must be redirected to login form
  test 'destroy action: logged out users must be redirected to login form' do
    delete :destroy, id: @good_gallery.id, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # logged in users mustn't have ability to delete someone else gallery
  test "destroy action: users mustn't delete someone else gallery" do
    log_in(@bad_man.id)
    delete :destroy, id: @good_gallery.id, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # logged in users must have ability to delete their galleries
  test 'destroy action: users must have ability to delete their galleries' do
    log_in(@good_man.id)
    delete :destroy, id: @good_gallery.id, locale: @locale
    assert_redirected_to photo_galleries_path
    assert_not flash.empty?
  end

  # admin must have access to destroy any gallery
  test 'destroy action: admin must have access to destroy any gallery' do
    log_in(@admin.id)
    delete :destroy, id: @good_gallery.id, locale: @locale
    assert_redirected_to photo_galleries_path
    assert_not flash.empty?
  end

  # gallery id must be right
  test 'destroy action: gallery id must be right' do
    log_in(@admin.id)
    delete :destroy, id: 'wrong_id', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #------------------------------- index action --------------------------------

  # logged out users must be redirected to login page
  test "index action: logged out users mustn't get access" do
    get :index, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # logged in users must get access
  test 'index action: logged in users must get access' do
    log_in(@good_man.id)
    get :index, locale: @locale
    assert_response :success
  end
end
