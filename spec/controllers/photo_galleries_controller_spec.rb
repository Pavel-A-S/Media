require 'rails_helper'
RSpec.describe PhotoGalleriesController, type: :controller do

  def log_in(id)
    session[:human_id] = id
  end

  before(:each) do
    @locale = 'en'
    @good_man = Human.find_by(email: 'goodman@test.com')
    @bad_man = Human.find_by(email: 'badman@test.com')
    @admin = Human.find_by(email: 'admin@test.com')
    @good_attributes = { description: 'good description' }
    @bad_attributes = { description: 'bad description' * 50 }
    @good_gallery = PhotoGallery.find_by(id: 17)
  end

  #-------------------------------- new action ---------------------------------

  # logged out users must be redirected
  it 'new action: logged out users must be redirected' do
    get :new, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must have access
  it 'new action: logged in users must have access' do
    log_in(@good_man.id)
    get :new, locale: @locale
    expect(response).to be_success
  end

  #------------------------------- create action -------------------------------

  # logged out users must be redirected
  it 'create action: logged out users must be redirected' do
    post :create, photo_gallery: @good_attributes, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must have access
  it 'create action: logged in users must have access' do
    log_in(@good_man.id)
    post :create, photo_gallery: @good_attributes, locale: @locale
    expect(response).to redirect_to photo_gallery_photos_path(assigns(:photo_gallery).id)
  end

  # wrong attributes must be handled
  it 'create action: wrong attributes must be handled' do
    log_in(@good_man.id)
    post :create, photo_gallery: @bad_attributes, locale: @locale
    expect(response).to render_template :new
    expect(assigns(:photo_gallery).errors.any?).to_not be_nil
  end

  # if "no attributes" request - must be handled
  it "create action: if 'no attributes' request - must be handled" do
    log_in(@good_man.id)
    post :create, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # if "wrong type attributes" request - must be handled
  it "create action: if 'wrong type attributes' request - must be handled" do
    log_in(@good_man.id)
    post :create, photo_gallery: 'lalala', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #-------------------------------- show action --------------------------------

  # logged out users must be redirected to login page
  it "show action: logged out users mustn't get access" do
    get :show, id: @good_gallery.id, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must get access
  it 'show action: logged in users must get access' do
    log_in(@good_man.id)
    get :show, id: @good_gallery.id, locale: @locale
    expect(response).to be_success
  end

  # user id must be right
  it 'show acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    get :show, id: 'wrong_id', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #---------------------------------- edit action ------------------------------

  # logged out users must be redirected to login form
  it "edit action: logged out users mustn't have access" do
    get :edit, id: @good_gallery.id, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # user mustn't have ability to change someone else gallery
  it "edit action: user mustn't change someone else gallery" do
    log_in(@bad_man.id)
    get :edit, id: @good_gallery.id, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # logged in user must have access to change his gallery
  it 'edit action: logged in user must have access to change his gallery' do
    log_in(@good_man.id)
    get :edit, id: @good_gallery.id, locale: @locale
    expect(response).to be_success
  end

  # admin must have access to change any gallery
  it 'edit action: admin must have access to change any gallery' do
    log_in(@admin.id)
    get :edit, id: @good_gallery.id, locale: @locale
    expect(response).to be_success
  end

  # gallery id must be right
  it 'edit acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    get :edit, id: 'wrong_id', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #--------------------------------- update action -----------------------------

  # logged out users must be redirected to login form
  it "update action: logged out users mustn't have access" do
    patch :update, id: @good_gallery.id, photo_gallery: @good_attributes,
                   locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # user mustn't have ability to change someone else gallery
  it "update action: user mustn't change someone else gallery" do
    log_in(@bad_man.id)
    patch :update, id: @good_gallery.id, photo_gallery: @good_attributes,
                   locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must have access to change their gallery
  it 'update action: users must have access to change their gallery' do
    log_in(@good_man.id)
    patch :update, id: @good_gallery.id, photo_gallery: @good_attributes,
                   locale: @locale
    expect(response).to redirect_to photo_gallery_path(assigns(:photo_gallery).id)
  end

  # admin must have access to change any gallery
  it 'update action: admin must have access to change any gallery' do
    log_in(@admin.id)
    patch :update, id: @good_gallery.id, photo_gallery: @good_attributes,
                   locale: @locale
    expect(response).to redirect_to photo_gallery_path(assigns(:photo_gallery).id)
  end

  # gallery id must be right
  it 'update acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    patch :update, id: 'wrong_id', photo_gallery: @good_attributes,
                   locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # wrong attributes request must be handled
  it "update action: if any errors user mustn't be redirected" do
    log_in(@good_man.id)
    patch :update, id: @good_gallery.id, photo_gallery: @bad_attributes,
                   locale: @locale
    expect(response).to render_template :edit
    expect(assigns(:photo_gallery).errors.any?).to_not be_nil
  end

  # if "no attributes" request - must be handled
  it "update action: if 'no attributes request' - must be handled" do
    log_in(@good_man.id)
    patch :update, id: @good_gallery.id, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # if "empty attributes" request - must be handled
  it "update action: if 'empty attributes request' - must be handled" do
    log_in(@good_man.id)
    patch :update, id: @good_gallery.id, photo_gallery: {}, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # if "wrong type attributes" request - must be handled
  it "update action: if 'wrong type attributes request' - must be handled" do
    log_in(@good_man.id)
    patch :update, id: @good_gallery.id, photo_gallery: 'lalala',
                   locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #-------------------------------- destroy action -----------------------------

  # logged out users must be redirected to login form
  it 'destroy action: logged out users must be redirected to login form' do
    delete :destroy, id: @good_gallery.id, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in users mustn't have ability to delete someone else gallery
  it "destroy action: users mustn't delete someone else gallery" do
    log_in(@bad_man.id)
    delete :destroy, id: @good_gallery.id, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must have ability to delete their galleries
  it 'destroy action: users must have ability to delete their galleries' do
    log_in(@good_man.id)
    delete :destroy, id: @good_gallery.id, locale: @locale
    expect(response).to redirect_to photo_galleries_path
    expect(flash.empty?).to_not be true
  end

  # admin must have access to destroy any gallery
  it 'destroy action: admin must have access to destroy any gallery' do
    log_in(@admin.id)
    delete :destroy, id: @good_gallery.id, locale: @locale
    expect(response).to redirect_to photo_galleries_path
    expect(flash.empty?).to_not be true
  end

  # gallery id must be right
  it 'destroy action: gallery id must be right' do
    log_in(@admin.id)
    delete :destroy, id: 'wrong_id', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #------------------------------- index action --------------------------------

  # logged out users must be redirected to login page
  it "index action: logged out users mustn't get access" do
    get :index, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must get access
  it 'index action: logged in users must get access' do
    log_in(@good_man.id)
    get :index, locale: @locale
    expect(response).to be_success
  end
end
