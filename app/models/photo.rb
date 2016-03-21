# Just a photo
class Photo < ActiveRecord::Base
  include SharedModelMethods
  before_destroy :delete_photo
  belongs_to :photo_gallery
  has_many :comments, dependent: :destroy

  validates :name, length: { maximum: 222 }

  def delete_photo
    FileUtils.rm_f "#{Rails.root}#{path}"
    FileUtils.rm_f "#{Rails.root}" \
      "#{path[%r{\A.*/}]}resized_#{path[%r{[^/]*\z}]}"
    return unless Dir["#{Rails.root}#{path[%r{\A.*/}]}*"].empty?
    FileUtils.rmdir "#{Rails.root}#{path[%r{\A.*/}]}"
  end
end
