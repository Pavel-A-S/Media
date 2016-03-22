require 'rails_helper'
RSpec.describe PhotosController, type: :controller do

  def log_in(id)
    session[:human_id] = id
  end

  before(:each) do
    @locale = 'en'
    @good_man = Human.find_by(email: 'goodman@test.com')
    @bad_man = Human.find_by(email: 'badman@test.com')
    @admin = Human.find_by(email: 'admin@test.com')

    @good_attributes = { files: [fixture_file_upload('/files/upload_file.png',
                                                     'image/png')] }
    @bad_attributes = { files: [fixture_file_upload('/files/upload_file.png',
                                                    'application/zip'), 'lol'] }

    @good_photo_attributes = { name: 'Very good photo' }
    @bad_photo_attributes = { name: 'lalala' * 50 }

    @good_gallery = PhotoGallery.find_by(id: 17)
    @good_photo = Photo.find_by(id: 73)

    unless File.exist?(Rails.root.join('/spec/fixtures/files/photo.png'))
      FileUtils.cp(Rails.root.to_s + '/spec/fixtures/files/for_setup.png',
                   Rails.root.to_s + '/spec/fixtures/files/photo.png')
    end

    return if File.exist?(Rails.root.join('/spec/fixtures/files/photo.png'))

    FileUtils.cp(Rails.root.to_s + '/spec/fixtures/files/for_setup.png',
                 Rails.root.to_s + '/spec/fixtures/files/resized_photo.png')
  end

  #------------------------------ send_photo action ----------------------------

  # logged out users must be redirected to login page
  it 'send_photo action: logged out users must be redirected to login form' do
    get :send_photo, id: @good_photo.id, type: 'resized', locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must get access (resized photo)
  it 'send_photo action: logged in users must get access (resized photo)' do
    log_in(@good_man.id)
    get :send_photo, id: @good_photo.id, type: 'resized', locale: @locale
    expect(response).to be_success
  end

  # logged in users must get access (full photo)
  it 'send_photo action: logged in users must get access (full photo)' do
    log_in(@good_man.id)
    get :send_photo, id: @good_photo.id, type: 'full', locale: @locale
    expect(response).to be_success
  end

  # photo id must be right (not at all - just check for errors)
  it 'send_photo action: photo id can be wrong' do
    log_in(@good_man.id)
    get :send_photo, id: 'wrong_id', type: 'resized', locale: @locale
    expect(response).to be_success
  end

  # photo type must be right
  it 'send_photo action: photo type must be right' do
    log_in(@good_man.id)
    get :send_photo, id: @good_photo.id, type: 'wrong_type', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #-------------------------------- show action --------------------------------

  # logged out users must be redirected to login page
  it "show action: logged out users mustn't get access" do
    get :show, id: @good_photo.id, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must get access
  it 'show action: logged in users must get access' do
    log_in(@good_man.id)
    get :show, id: @good_photo.id, locale: @locale
    expect(response).to be_success
  end

  # photo id must be right
  it 'show acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    get :show, id: 'wrong_id', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #------------------------------- index action --------------------------------

  # logged out users must be redirected to login page
  it "index action: logged out users mustn't get access" do
    get :index, photo_gallery_id: @good_gallery.id, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must get access
  it 'index action: logged in users must get access' do
    log_in(@good_man.id)
    get :index, photo_gallery_id: @good_gallery.id, locale: @locale
    expect(response).to be_success
  end

  # gallery id must be right
  it 'index acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    get :index, photo_gallery_id: 'wrong_id', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #-------------------------------- new action ---------------------------------

  # logged out users must be redirected
  it 'new action: logged out users must be redirected' do
    get :new, photo_gallery_id: @good_gallery.id, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must have access
  it 'new action: logged in users must have access' do
    log_in(@good_man.id)
    get :new, photo_gallery_id: @good_gallery.id, locale: @locale
    expect(response).to be_success
  end

  # wrong users mustn't have access
  it "new action: wrong users mustn't have access" do
    log_in(@bad_man.id)
    get :new, photo_gallery_id: @good_gallery.id, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # admin must have access
  it 'new action: admin must have access' do
    log_in(@admin.id)
    get :new, photo_gallery_id: @good_gallery.id, locale: @locale
    expect(response).to be_success
  end

  # id must be right
  it 'new action: id must be right' do
    log_in(@good_man.id)
    get :new, photo_gallery_id: 'wrong_id', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #------------------------------- create action -------------------------------

  # logged out users must be redirected
  it 'create action: logged out users must be redirected' do
    post :create, photo_gallery_id: @good_gallery.id,
                  uploading: @good_attributes,
                  locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must have access
  it 'create action: logged in users must have access' do
    log_in(@good_man.id)
    post :create, photo_gallery_id: @good_gallery.id,
                  uploading: @good_attributes,
                  locale: @locale
    expect(response).to redirect_to photo_gallery_photos_path(assigns(:current_gallery).id)
  end

  # wrong user mustn't have access
  it "create action: wrong user mustn't have access" do
    log_in(@bad_man.id)
    post :create, photo_gallery_id: @good_gallery.id,
                  uploading: @good_attributes,
                  locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # admin must have access
  it 'create action: admin must have access' do
    log_in(@admin.id)
    post :create, photo_gallery_id: @good_gallery.id,
                  uploading: @good_attributes,
                  locale: @locale
    expect(response).to redirect_to photo_gallery_photos_path(assigns(:current_gallery).id)
  end

  # wrong attributes must be handled
  it 'create action: wrong attributes must be handled' do
    log_in(@good_man.id)
    post :create, photo_gallery_id: @good_gallery.id,
                  uploading: @bad_attributes,
                  locale: @locale
    expect(response).to redirect_to photo_gallery_photos_path(assigns(:current_gallery).id)
  end

  # if "no attributes" request - must be handled
  it "create action: if 'no attributes' request - must be handled" do
    log_in(@good_man.id)
    post :create, photo_gallery_id: @good_gallery.id, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # if "wrong type attributes" request - must be handled
  it "create action: if 'wrong type attributes' request - must be handled" do
    log_in(@good_man.id)
    post :create, photo_gallery_id: @good_gallery.id, uploading: 'lalala',
                  locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # id must be right
  it 'create action: id must be right' do
    log_in(@good_man.id)
    post :create, photo_gallery_id: 'wrong_id',
                  uploading: @good_attributes,
                  locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #---------------------------------- edit action ------------------------------

  # logged out users must be redirected to login form
  it "edit action: logged out users mustn't have access" do
    get :edit, id: @good_photo.id, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # user mustn't have ability to change someone else photo
  it "edit action: user mustn't change someone else photo" do
    log_in(@bad_man.id)
    get :edit, id: @good_photo.id, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # logged in user must have access to change his photo
  it 'edit action: logged in user must have access to change his photo' do
    log_in(@good_man.id)
    get :edit, id: @good_photo.id, locale: @locale
    expect(response).to be_success
  end

  # admin must have access to change any photo
  it 'edit action: admin must have access to change any photo' do
    log_in(@admin.id)
    get :edit, id: @good_photo.id, locale: @locale
    expect(response).to be_success
  end

  # photo id must be right
  it 'edit acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    get :edit, id: 'wrong_id', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #--------------------------------- update action -----------------------------

  # logged out users must be redirected to login form
  it "update action: logged out users mustn't have access" do
    # attributes
    patch :update, id: @good_photo.id, photo: @good_photo_attributes,
                   locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true

    # rotation
    patch :update, id: @good_photo.id, rotation: 'right', locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # user mustn't have ability to change someone else photo
  it "update action: user mustn't change someone else photo" do
    # attributes
    log_in(@bad_man.id)
    patch :update, id: @good_photo.id, photo: @good_photo_attributes,
                   locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true

    # rotation
    patch :update, id: @good_photo.id, rotation: 'right', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must have access to change their photo
  it 'update action: users must have access to change their photo' do
    # attributes
    log_in(@good_man.id)
    patch :update, id: @good_photo.id, photo: @good_photo_attributes,
                   locale: @locale
    expect(response).to redirect_to photo_path(assigns(:photo).id)

    # rotation
    patch :update, id: @good_photo.id, rotation: 'right', locale: @locale
    expect(response).to render_template :edit
  end

  # admin must have access to change any photo
  it 'update action: admin must have access to change any photo' do
    # attributes
    log_in(@admin.id)
    patch :update, id: @good_photo.id, photo: @good_photo_attributes,
                   locale: @locale
    expect(response).to redirect_to photo_path(assigns(:photo).id)

    # rotation
    patch :update, id: @good_photo.id, rotation: 'left', locale: @locale
    expect(response).to render_template :edit

    # attributes + rotation - works only rotation
    patch :update, id: @good_photo.id,
                   photo: @good_photo_attributes,
                   rotation: 'right',
                   locale: @locale
    expect(response).to render_template :edit
  end

  # photo id must be right
  it 'update acton: if wrong id user must be redirected' do
    # attributes
    log_in(@good_man.id)
    patch :update, id: 'wrong_id', photo: @good_photo_attributes,
                   locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true

    # rotation
    patch :update, id: 'wrong_id', rotation: 'right', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # wrong attributes request must be handled
  it 'update action: if any errors request must be handled' do
    log_in(@good_man.id)

    # attributes - bad attributes
    patch :update, id: @good_photo.id, photo: @bad_photo_attributes,
                   locale: @locale
    expect(response).to render_template :edit
    expect(assigns(:photo).errors.any?).to_not be_nil

    # rotation - bad rotation
    patch :update, id: @good_photo.id, rotation: 'none', locale: @locale
    expect(response).to redirect_to photo_path(assigns(:photo).id)

    # attributes + rotation - all wrong
    patch :update, id: @good_photo.id, rotation: 'none',
                   photo: @bad_photo_attributes,
                   locale: @locale
    expect(response).to render_template :edit
    expect(assigns(:photo).errors.any?).to_not be_nil

    # no attributes, no rotation
    patch :update, id: @good_photo.id, locale: @locale
    expect(response).to redirect_to photo_path(assigns(:photo).id)
  end

  # if "empty attributes" request - must not be errors
  it "update action: if 'empty attributes request' - must not be errors" do
    # attributes
    log_in(@good_man.id)
    patch :update, id: @good_photo.id, photo: {}, locale: @locale
    expect(response).to redirect_to photo_path(assigns(:photo).id)

    # rotation
    patch :update, id: @good_photo.id, rotation: {}, locale: @locale
    expect(response).to redirect_to photo_path(assigns(:photo).id)
  end

  # if "wrong type attributes" request - must not be errors
  it "update action: if 'wrong type attributes' - must not be errors" do
    # attributes
    log_in(@good_man.id)
    patch :update, id: @good_photo.id, photo: 'lalala', locale: @locale
    expect(response).to redirect_to photo_path(assigns(:photo).id)

    # rotation
    patch :update, id: @good_photo.id, rotation: 'lalala', locale: @locale
    expect(response).to redirect_to photo_path(assigns(:photo).id)
  end

  #-------------------------------- destroy action -----------------------------

  # logged out users must be redirected to login form
  it 'destroy action: logged out users must be redirected to login form' do
    delete :destroy, id: @good_photo.id, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # users mustn't have ability to delete someone else photo
  it "destroy action: users mustn't delete someone else photo" do
    log_in(@bad_man.id)
    delete :destroy, id: @good_photo.id, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must have ability to delete their photos
  it 'destroy action: users must have ability to delete their photos' do
    log_in(@good_man.id)
    delete :destroy, id: @good_photo.id, locale: @locale
    expect(response).to redirect_to photo_gallery_photos_path(assigns(:photo_gallery).id)
    expect(flash.empty?).to_not be true
  end

  # admin must have access to destroy any photo
  it 'destroy action: admin must have access to destroy any photo' do
    log_in(@admin.id)
    delete :destroy, id: @good_photo.id, locale: @locale
    expect(response).to redirect_to photo_gallery_photos_path(assigns(:photo_gallery).id)
    expect(flash.empty?).to_not be true
  end

  # photo id must be right
  it 'destroy action: photo id must be right' do
    log_in(@admin.id)
    delete :destroy, id: 'wrong_id', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end
end
