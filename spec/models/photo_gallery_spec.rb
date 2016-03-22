require 'rails_helper'

RSpec.describe PhotoGallery, type: :model do
  before(:each) do
    @good_attributes = { description: 'Test' }

    @wrong_attributes = { description: nil }

    @second_wrong_attributes = { description: 'T' * 151 }
  end

  it 'Must not be errors if attributes are correct' do
    @description = PhotoGallery.create(@good_attributes)
    expect(@description.errors.size).to eq(0)
  end

  it 'Description must be present' do
    @description = PhotoGallery.create(@wrong_attributes)
    expect(@description.errors[:description].size).to eq(1)
  end

  it 'Description length must not be more than 150 symbols' do
    @description = PhotoGallery.create(@second_wrong_attributes)
    expect(@description.errors[:description].size).to eq(1)
  end
end
