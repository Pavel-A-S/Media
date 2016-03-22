require 'rails_helper'

RSpec.describe "Check links:", :type => :feature do
  fixtures :Humans
  fixtures :Photo_Galleries
  fixtures :Photos

  before :each do
    # puts "#{page.html.inspect}"
    visit "/#{I18n.locale}/login_form"
    fill_in I18n.t(:email), :with => 'goodman@test.com'
    fill_in I18n.t(:password), :with => '12345678'
    click_button I18n.t(:enter)
  end

  it "Login link" do
    expect(page).to have_content 'goodman@test.com'
  end

  it "Humans list link" do
    visit "/#{I18n.locale}/humans"
    expect(page).to have_content 'Good Man'
    expect(page).to have_content 'Admin'
    expect(page).to have_content 'Bad Man'
  end

  it "Collections list link" do
    visit "/#{I18n.locale}/photo_galleries"
    expect(page).to have_content I18n.t(:create_gallery)
  end

  it "Photos list link" do
    visit "/#{I18n.locale}/photo_galleries/17/photos"
    expect(page).to have_content I18n.t(:add_new_photo)
    expect(page).to have_content I18n.t(:add_new_link)
  end

  it "Photo link" do
    visit "/#{I18n.locale}/photos/73"
    expect(page).to have_content 'good photo'
  end

  it "Permission link" do
    visit "/#{I18n.locale}/photo_galleries/17/permissions/new"
    expect(page).to have_content I18n.t(:permission)
  end

  it "Upload photo link" do
    visit "/#{I18n.locale}/photo_galleries/17/photos/new"
    expect(page).to have_content I18n.t(:upload_files)
  end
end
