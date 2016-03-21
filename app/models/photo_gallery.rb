# Just a photo gallery
class PhotoGallery < ActiveRecord::Base
  include SharedModelMethods

  belongs_to :human
  has_many :photos, dependent: :destroy
  has_many :permissions
  has_many :humans, through: :permissions

  validates :description, presence: true, length: { maximum:  150 }
end
