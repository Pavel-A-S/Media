class Permission < ActiveRecord::Base
  belongs_to :photo_gallery
  belongs_to :human
end
