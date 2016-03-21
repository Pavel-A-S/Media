# Just a photo galleries controller
class PhotoGalleriesController < ApplicationController
  before_action :human_only

  def new
    @photo_gallery = PhotoGallery.new
  end

  def create
    if attributes
      cover = 'default'
      @photo_gallery = current_human.photo_galleries.build(attributes) # Ok
      if @photo_gallery && @photo_gallery.cover = cover
        if @photo_gallery.save
          redirect_to photo_gallery_photos_path(@photo_gallery.id)
        else
          render 'new'
        end
      end
    else
      flash[:alert] = t(:no_data)
      redirect_to root_path
    end
  end

  def show
    return if @photo_gallery = PhotoGallery.find_by('id = ?', params[:id]) # Ok
    flash[:alert] = t(:no_photo_gallery)
    redirect_to root_path
  end

  def edit
    @photo_gallery = PhotoGallery.find_by('id = ?', params[:id]) # Ok
    if @photo_gallery && (@photo_gallery.human == current_human ||
                                                  current_human.admin?)
      render 'edit'
    else
      flash[:alert] = t(:restrict_to_change_photo_gallery)
      redirect_to root_path
    end
  end

  def update
    @photo_gallery = PhotoGallery.find_by('id = ?', params[:id]) # Ok
    if @photo_gallery && (@photo_gallery.human == current_human ||
                                                  current_human.admin?)
      if attributes
        if @photo_gallery.update_attributes(attributes) # Ok
          redirect_to photo_gallery_path(@photo_gallery.id)
        else
          render 'edit'
        end
      else
        flash[:alert] = t(:no_data)
        redirect_to root_path
      end
    else
      flash[:alert] = t(:restrict_to_change_photo_gallery)
      redirect_to root_path
    end
  end

  def destroy
    @photo_gallery = PhotoGallery.find_by('id = ?', params[:id]) # Ok
    if @photo_gallery && (@photo_gallery.human == current_human ||
                                                  current_human.admin?)
      if @photo_gallery.destroy
        flash[:message] = t(:deleted_photo_gallery)
        redirect_to photo_galleries_path
      else
        redirect_to root_path
      end
    else
      flash[:alert] = t(:restrict_to_delete_photo_gallery)
      redirect_to root_path
    end
  end

  def index
    @photo_gallery = PhotoGallery.all
  end

  private

  def attributes
    return if params[:photo_gallery].blank? ||
              !params[:photo_gallery].is_a?(Hash)
    params.require(:photo_gallery).permit(:description)
  end
end
