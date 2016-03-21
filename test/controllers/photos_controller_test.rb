require 'test_helper'

class PhotosControllerTest < ActionController::TestCase
  def setup
    @locale = 'en'
    @good_man = humans(:good_man)
    @bad_man = humans(:bad_man)
    @admin = humans(:admin)

    @good_attributes = { files: [fixture_file_upload('/files/upload_file.png',
                                                     'image/png')] }
    @bad_attributes = { files: [fixture_file_upload('/files/upload_file.png',
                                                    'application/zip'), 'lol'] }

    @good_photo_attributes = { name: 'Very good photo' }
    @bad_photo_attributes = { name: 'lalala' * 50 }

    @good_gallery = photo_galleries(:good_gallery)
    @good_photo = photos(:good_photo)

    unless File.exist?(Rails.root.join('/test/fixtures/files/photo.png'))
      FileUtils.cp(Rails.root.to_s + '/test/fixtures/files/for_setup.png',
                   Rails.root.to_s + '/test/fixtures/files/photo.png')
    end

    return if File.exist?(Rails.root.join('/test/fixtures/files/photo.png'))

    FileUtils.cp(Rails.root.to_s + '/test/fixtures/files/for_setup.png',
                 Rails.root.to_s + '/test/fixtures/files/resized_photo.png')
  end

  #------------------------------ send_photo action ----------------------------

  # logged out users must be redirected to login page
  test 'send_photo action: logged out users must be redirected to login form' do
    get :send_photo, id: @good_photo.id, type: 'resized', locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # logged in users must get access (resized photo)
  test 'send_photo action: logged in users must get access (resized photo)' do
    log_in(@good_man.id)
    get :send_photo, id: @good_photo.id, type: 'resized', locale: @locale
    assert :success
  end

  # logged in users must get access (full photo)
  test 'send_photo action: logged in users must get access (full photo)' do
    log_in(@good_man.id)
    get :send_photo, id: @good_photo.id, type: 'full', locale: @locale
    assert :success
  end

  # photo id must be right (not at all - just check for errors)
  test 'send_photo action: photo id can be wrong' do
    log_in(@good_man.id)
    get :send_photo, id: 'wrong_id', type: 'resized', locale: @locale
    assert :success
  end

  # photo type must be right
  test 'send_photo action: photo type must be right' do
    log_in(@good_man.id)
    get :send_photo, id: @good_photo.id, type: 'wrong_type', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #-------------------------------- show action --------------------------------

  # logged out users must be redirected to login page
  test "show action: logged out users mustn't get access" do
    get :show, id: @good_photo.id, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # logged in users must get access
  test 'show action: logged in users must get access' do
    log_in(@good_man.id)
    get :show, id: @good_photo.id, locale: @locale
    assert_response :success
  end

  # photo id must be right
  test 'show acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    get :show, id: 'wrong_id', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #------------------------------- index action --------------------------------

  # logged out users must be redirected to login page
  test "index action: logged out users mustn't get access" do
    get :index, photo_gallery_id: @good_gallery.id, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # logged in users must get access
  test 'index action: logged in users must get access' do
    log_in(@good_man.id)
    get :index, photo_gallery_id: @good_gallery.id, locale: @locale
    assert_response :success
  end

  # gallery id must be right
  test 'index acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    get :index, photo_gallery_id: 'wrong_id', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #-------------------------------- new action ---------------------------------

  # logged out users must be redirected
  test 'new action: logged out users must be redirected' do
    get :new, photo_gallery_id: @good_gallery.id, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # logged in users must have access
  test 'new action: logged in users must have access' do
    log_in(@good_man.id)
    get :new, photo_gallery_id: @good_gallery.id, locale: @locale
    assert_response :success
  end

  # wrong users mustn't have access
  test "new action: wrong users mustn't have access" do
    log_in(@bad_man.id)
    get :new, photo_gallery_id: @good_gallery.id, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # admin must have access
  test 'new action: admin must have access' do
    log_in(@admin.id)
    get :new, photo_gallery_id: @good_gallery.id, locale: @locale
    assert_response :success
  end

  # id must be right
  test 'new action: id must be right' do
    log_in(@good_man.id)
    get :new, photo_gallery_id: 'wrong_id', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #------------------------------- create action -------------------------------

  # logged out users must be redirected
  test 'create action: logged out users must be redirected' do
    post :create, photo_gallery_id: @good_gallery.id,
                  uploading: @good_attributes,
                  locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # logged in users must have access
  test 'create action: logged in users must have access' do
    log_in(@good_man.id)
    post :create, photo_gallery_id: @good_gallery.id,
                  uploading: @good_attributes,
                  locale: @locale
    assert_redirected_to photo_gallery_photos_path(assigns(:current_gallery).id)
  end

  # wrong user mustn't have access
  test "create action: wrong user mustn't have access" do
    log_in(@bad_man.id)
    post :create, photo_gallery_id: @good_gallery.id,
                  uploading: @good_attributes,
                  locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # admin must have access
  test 'create action: admin must have access' do
    log_in(@admin.id)
    post :create, photo_gallery_id: @good_gallery.id,
                  uploading: @good_attributes,
                  locale: @locale
    assert_redirected_to photo_gallery_photos_path(assigns(:current_gallery).id)
  end

  # wrong attributes must be handled
  test 'create action: wrong attributes must be handled' do
    log_in(@good_man.id)
    post :create, photo_gallery_id: @good_gallery.id,
                  uploading: @bad_attributes,
                  locale: @locale
    assert_redirected_to photo_gallery_photos_path(assigns(:current_gallery).id)
  end

  # if "no attributes" request - must be handled
  test "create action: if 'no attributes' request - must be handled" do
    log_in(@good_man.id)
    post :create, photo_gallery_id: @good_gallery.id, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # if "wrong type attributes" request - must be handled
  test "create action: if 'wrong type attributes' request - must be handled" do
    log_in(@good_man.id)
    post :create, photo_gallery_id: @good_gallery.id, uploading: 'lalala',
                  locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # id must be right
  test 'create action: id must be right' do
    log_in(@good_man.id)
    post :create, photo_gallery_id: 'wrong_id',
                  uploading: @good_attributes,
                  locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #---------------------------------- edit action ------------------------------

  # logged out users must be redirected to login form
  test "edit action: logged out users mustn't have access" do
    get :edit, id: @good_photo.id, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # user mustn't have ability to change someone else photo
  test "edit action: user mustn't change someone else photo" do
    log_in(@bad_man.id)
    get :edit, id: @good_photo.id, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # logged in user must have access to change his photo
  test 'edit action: logged in user must have access to change his photo' do
    log_in(@good_man.id)
    get :edit, id: @good_photo.id, locale: @locale
    assert_response :success
  end

  # admin must have access to change any photo
  test 'edit action: admin must have access to change any photo' do
    log_in(@admin.id)
    get :edit, id: @good_photo.id, locale: @locale
    assert_response :success
  end

  # photo id must be right
  test 'edit acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    get :edit, id: 'wrong_id', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #--------------------------------- update action -----------------------------

  # logged out users must be redirected to login form
  test "update action: logged out users mustn't have access" do
    # attributes
    patch :update, id: @good_photo.id, photo: @good_photo_attributes,
                   locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?

    # rotation
    patch :update, id: @good_photo.id, rotation: 'right', locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # user mustn't have ability to change someone else photo
  test "update action: user mustn't change someone else photo" do
    # attributes
    log_in(@bad_man.id)
    patch :update, id: @good_photo.id, photo: @good_photo_attributes,
                   locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?

    # rotation
    patch :update, id: @good_photo.id, rotation: 'right', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # logged in users must have access to change their photo
  test 'update action: users must have access to change their photo' do
    # attributes
    log_in(@good_man.id)
    patch :update, id: @good_photo.id, photo: @good_photo_attributes,
                   locale: @locale
    assert_redirected_to photo_path(assigns(:photo).id)

    # rotation
    patch :update, id: @good_photo.id, rotation: 'right', locale: @locale
    assert_template :edit
  end

  # admin must have access to change any photo
  test 'update action: admin must have access to change any photo' do
    # attributes
    log_in(@admin.id)
    patch :update, id: @good_photo.id, photo: @good_photo_attributes,
                   locale: @locale
    assert_redirected_to photo_path(assigns(:photo).id)

    # rotation
    patch :update, id: @good_photo.id, rotation: 'left', locale: @locale
    assert_template :edit

    # attributes + rotation - works only rotation
    patch :update, id: @good_photo.id,
                   photo: @good_photo_attributes,
                   rotation: 'right',
                   locale: @locale
    assert_template :edit
  end

  # photo id must be right
  test 'update acton: if wrong id user must be redirected' do
    # attributes
    log_in(@good_man.id)
    patch :update, id: 'wrong_id', photo: @good_photo_attributes,
                   locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?

    # rotation
    patch :update, id: 'wrong_id', rotation: 'right', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # wrong attributes request must be handled
  test 'update action: if any errors request must be handled' do
    log_in(@good_man.id)

    # attributes - bad attributes
    patch :update, id: @good_photo.id, photo: @bad_photo_attributes,
                   locale: @locale
    assert_template :edit
    assert assigns(:photo).errors.any?

    # rotation - bad rotation
    patch :update, id: @good_photo.id, rotation: 'none', locale: @locale
    assert_redirected_to photo_path(assigns(:photo).id)

    # attributes + rotation - all wrong
    patch :update, id: @good_photo.id, rotation: 'none',
                   photo: @bad_photo_attributes,
                   locale: @locale
    assert_template :edit
    assert assigns(:photo).errors.any?

    # no attributes, no rotation
    patch :update, id: @good_photo.id, locale: @locale
    assert_redirected_to photo_path(assigns(:photo).id)
  end

  # if "empty attributes" request - must not be errors
  test "update action: if 'empty attributes request' - must not be errors" do
    # attributes
    log_in(@good_man.id)
    patch :update, id: @good_photo.id, photo: {}, locale: @locale
    assert_redirected_to photo_path(assigns(:photo).id)

    # rotation
    patch :update, id: @good_photo.id, rotation: {}, locale: @locale
    assert_redirected_to photo_path(assigns(:photo).id)
  end

  # if "wrong type attributes" request - must not be errors
  test "update action: if 'wrong type attributes' - must not be errors" do
    # attributes
    log_in(@good_man.id)
    patch :update, id: @good_photo.id, photo: 'lalala', locale: @locale
    assert_redirected_to photo_path(assigns(:photo).id)

    # rotation
    patch :update, id: @good_photo.id, rotation: 'lalala', locale: @locale
    assert_redirected_to photo_path(assigns(:photo).id)
  end

  #-------------------------------- destroy action -----------------------------

  # logged out users must be redirected to login form
  test 'destroy action: logged out users must be redirected to login form' do
    delete :destroy, id: @good_photo.id, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # users mustn't have ability to delete someone else photo
  test "destroy action: users mustn't delete someone else photo" do
    log_in(@bad_man.id)
    delete :destroy, id: @good_photo.id, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # logged in users must have ability to delete their photos
  test 'destroy action: users must have ability to delete their photos' do
    log_in(@good_man.id)
    delete :destroy, id: @good_photo.id, locale: @locale
    assert_redirected_to photo_gallery_photos_path(assigns(:photo_gallery).id)
    assert_not flash.empty?
  end

  # admin must have access to destroy any photo
  test 'destroy action: admin must have access to destroy any photo' do
    log_in(@admin.id)
    delete :destroy, id: @good_photo.id, locale: @locale
    assert_redirected_to photo_gallery_photos_path(assigns(:photo_gallery).id)
    assert_not flash.empty?
  end

  # photo id must be right
  test 'destroy action: photo id must be right' do
    log_in(@admin.id)
    delete :destroy, id: 'wrong_id', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end
end
