require 'rails_helper'

RSpec.describe Photo, type: :model do
  before(:each) do
    @good_attributes = { name: 'Test' }

    @wrong_attributes = { name: nil }

    @second_wrong_attributes = { name: 'T' * 223 }
  end

  it 'Must not be errors if attributes are correct' do
    @photo = Photo.create(@good_attributes)
    expect(@photo.errors.size).to eq(0)
  end

  it 'Photo name length must not be more than 222 symbols' do
    @photo = Photo.create(@second_wrong_attributes)
    expect(@photo.errors[:name].size).to eq(1)
  end
end
