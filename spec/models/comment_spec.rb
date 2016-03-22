require 'rails_helper'

RSpec.describe Comment, type: :model do
  before(:each) do
    @good_attributes = { text: 'Test' }

    @wrong_attributes = { text: nil }

    @second_wrong_attributes = { text: 'T' * 251 }
  end

  it 'Must not be errors if attributes are correct' do
    @comment = Comment.create(@good_attributes)
    expect(@comment.errors.size).to eq(0)
  end

  it 'Comment must be present' do
    @comment = Comment.create(@wrong_attributes)
    expect(@comment.errors[:text].size).to eq(1)
  end

  it 'Comment length must not be more than 250 symbols' do
    @comment = Comment.create(@second_wrong_attributes)
    expect(@comment.errors[:text].size).to eq(1)
  end
end
