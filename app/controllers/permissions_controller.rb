class PermissionsController < ApplicationController

  def new
    @photo_gallery = PhotoGallery
                     .find_by('id = ?', params[:photo_gallery_id]) # ok
    if @photo_gallery && (@photo_gallery.human == current_human ||
                          current_human.admin?)
      @permission = Permission.new
      render 'new'
    else
      flash[:alert] = t(:restrict_to_add_permission)
      redirect_to root_path
    end
  end

  def create
    if attributes
      @photo_gallery = PhotoGallery
                       .find_by('id = ?', params[:photo_gallery_id]) # ok

      if @photo_gallery && (@photo_gallery.human == current_human ||
                            current_human.admin?)

        if !Permission.exists?(human_id: attributes[:human_id],
                               photo_gallery_id: params[:photo_gallery_id])

          @permission = @photo_gallery.permissions.build(attributes)
        end

        if @permission && @permission.save
          flash[:message] = t(:permission_granted)
          redirect_to new_photo_gallery_permission_path(@photo_gallery.id)
        else
          flash[:message] = t(:permission_exists)
          redirect_to new_photo_gallery_permission_path(@photo_gallery.id)
        end
      else
        flash[:alert] = t(:no_data)
        redirect_to root_path
      end
    else
      flash[:alert] = t(:no_data)
      redirect_to root_path
    end
  end

  def destroy
    @permission = Permission.find_by('id = ?', params[:id]) # Ok
    @photo_gallery = @permission.photo_gallery
    if @permission && (@photo_gallery.human_id == current_human.id ||
                                               current_human.admin?)
      if @permission.destroy
        flash[:message] = t(:permission_deleted)
        redirect_to new_photo_gallery_permission_path(@photo_gallery.id)
      else
        redirect_to root_path
      end
    else
      flash[:alert] = t(:restrict_to_delete_photo_gallery)
      redirect_to root_path
    end
  end


  private

  def attributes
    return if params[:permission].blank? ||
              !params[:permission].is_a?(Hash)
    params.require(:permission).permit(:human_id)
  end
end
