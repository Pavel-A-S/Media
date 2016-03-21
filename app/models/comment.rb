# Just comment
class Comment < ActiveRecord::Base
  belongs_to :human
  belongs_to :photo

  validates :text, presence: true, length: { maximum: 250 }
end
