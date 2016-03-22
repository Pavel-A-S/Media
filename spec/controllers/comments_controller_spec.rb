require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  fixtures :Humans, :Comments

  def log_in(id)
    session[:human_id] = id
  end

  before(:each) do
    @locale = 'en'
    @good_man = Human.find_by(email: 'goodman@test.com')
    @bad_man = Human.find_by(email: 'badman@test.com')
    @admin = Human.find_by(email: 'admin@test.com')

    @good_photo = Photo.find_by(id: 71)
    @good_comment = Comment.find_by(id: 131)
    @good_comment_attributes = { text: 'Very good photo' }
    @bad_comment_attributes = { text: 'lalala' * 50 }
  end

  #------------------------------- create action -------------------------------

  # logged out users must be redirected
  it 'create action: logged out users must be redirected' do
    post :create, photo_id: @good_photo.id, comment: @good_comment_attributes,
                  locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash[:alert]).to_not be_nil
  end

  # logged in users must have access
  it 'create action: logged in users must have access' do
    log_in(@good_man.id)
    post :create, photo_id: @good_photo.id, comment: @good_comment_attributes,
                  locale: @locale
    expect(response).to redirect_to photo_path(assigns(:comment).photo_id) + '#bottom'
  end

  # any user can comment any photo
  it 'create action: any user can comment any photo' do
    log_in(@bad_man.id)
    post :create, photo_id: @good_photo.id, comment: @good_comment_attributes,
                  locale: @locale
    expect(response).to redirect_to photo_path(assigns(:comment).photo_id) + '#bottom'
  end

  # id must be right
  it 'create action: id must be right' do
    log_in(@good_man.id)
    post :create, photo_id: 'wrong_id', comment: @good_comment_attributes,
                  locale: @locale
    expect(response).to redirect_to root_path
    expect(flash[:alert]).to_not be_nil
  end

  # wrong attributes must be handled
  it 'create action: wrong attributes must be handled' do
    log_in(@good_man.id)
    post :create, photo_id: @good_photo.id, comment: @bad_comment_attributes,
                  locale: @locale
    expect(response).to redirect_to photo_path(assigns(:comment).photo_id) + '#'
    expect(assigns(:comment).errors.any?).to_not be_nil
    expect(flash[:alert]).to_not be_nil
  end

  # if "no attributes" request - must be handled
  it "create action: if 'no attributes' request - must be handled" do
    log_in(@good_man.id)
    post :create, photo_id: @good_photo.id, locale: @locale
    expect(response).to redirect_to photo_path(assigns(:comment).photo_id) + '#'
    expect(assigns(:comment).errors.any?).to_not be_nil

    expect(flash[:alert]).to_not be_nil
  end

  # if "wrong type attributes" request - must be handled
  it "create action: if 'wrong type attributes' request - must be handled" do
    log_in(@good_man.id)
    post :create, photo_id: @good_photo.id, comment: 'lalala', locale: @locale
    expect(response).to redirect_to photo_path(assigns(:comment).photo_id) + '#'
    expect(assigns(:comment).errors.any?).to_not be_nil
    expect(flash[:alert]).to_not be_nil
  end

  #-------------------------------- destroy action -----------------------------

  # logged out users must be redirected to login form
  it 'destroy action: logged out users must be redirected to login form' do
    delete :destroy, id: @good_comment.id, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash[:alert]).to_not be_nil
  end

  # users mustn't have ability to delete someone else comment
  it "destroy action: users mustn't delete someone else comment" do
    log_in(@bad_man.id)
    delete :destroy, id: @good_comment.id, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash[:alert]).to_not be_nil
  end

  # logged in users must have ability to delete their comment
  it 'destroy action: users must have ability to delete their comment' do
    log_in(@good_man.id)
    delete :destroy, id: @good_comment.id, locale: @locale
    expect(response).to redirect_to photo_path(assigns(:comment).photo_id)
    expect(flash[:message]).to_not be_nil
  end

  # admin must have access to destroy any comment
  it 'destroy action: admin must have access to destroy any comment' do
    log_in(@admin.id)
    delete :destroy, id: @good_comment.id, locale: @locale
    expect(response).to redirect_to photo_path(assigns(:comment).photo_id)
    expect(flash[:message]).to_not be_nil
  end

  # comment id must be right
  it 'destroy action: comment id must be right' do
    log_in(@admin.id)
    delete :destroy, id: 'wrong_id', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash[:alert]).to_not be_nil
  end
end
