# Just a photos controller
class PhotosController < ApplicationController
  before_action :human_only

  def send_photo
    if @photo = Photo.find_by('id = ?', params[:id]) # ok
      path = @photo.path
    else
      path = '/public/Default_Cover/Default_Cover.png'
    end

    if path && photo_path = check_path(params[:type], path) # ok
      send_file Rails.root.to_s + photo_path, x_sendfile: true
    else
      flash[:alert] = t(:no_photo)
      redirect_to root_path
    end
  end

  def show
    if @photo = Photo.find_by('id = ?', params[:id]) # ok
      @comment = Comment.new
      @comments = @photo.comments
      if @photo_gallery = PhotoGallery.find_by(id: @photo.photo_gallery_id)
        @human = @photo_gallery.human
      end

      if @photo_gallery.humans.exists?(current_human.id) ||
                current_human == @photo_gallery.human ||
                current_human.admin?
        render 'show'
      else
        flash[:alert] = t(:no_photo_gallery)
        redirect_to root_path
      end

    else
      flash[:alert] = t(:no_photo)
      redirect_to root_path
    end
  end

  def index
    if @photo_gallery = PhotoGallery
                        .find_by('id = ?', params[:photo_gallery_id]) # ok
      @photos = @photo_gallery.photos.numbering(params[:list], 25, 5) # ok
      @human = @photo_gallery.human

      if @photo_gallery.humans.exists?(current_human.id) ||
                current_human == @photo_gallery.human ||
                current_human.admin?
        render 'index'
      else
        flash[:alert] = t(:no_photo_gallery)
        redirect_to root_path
      end
    else
      flash[:alert] = t(:no_photo_gallery)
      redirect_to root_path
    end
  end

  def new
    @photo_gallery = PhotoGallery
                     .find_by('id = ?', params[:photo_gallery_id]) # ok
    if @photo_gallery && (@photo_gallery.human == current_human ||
                          current_human.admin?)
      @photo = Photo.new
    else
      flash[:alert] = t(:restrict_to_add_photo)
      redirect_to root_path
    end
  end

  def new_link
    @photo_gallery = PhotoGallery
                     .find_by('id = ?', params[:photo_gallery_id]) # ok
    if @photo_gallery && (@photo_gallery.human == current_human ||
                          current_human.admin?)
      @photo = Photo.new
    else
      flash[:alert] = t(:restrict_to_add_link)
      redirect_to root_path
    end
  end

  def create_link

    @current_gallery = PhotoGallery
                       .find_by('id = ?', params[:photo_gallery_id]) # ok

    if @current_gallery && (current_human == @current_gallery.human ||
                            current_human.admin?)

      if attributes
        path = attributes_link[:description]
        if path =~ /\A#{URI::regexp(['http', 'https'])}\z/
          begin
            @object = LinkThumbnailer.generate(path) rescue 'none'
          rescue LinkThumbnailer::Exceptions => e
            nil
          end
        end
        if @object
          images_path = @object.images.first.src.to_s rescue '/Default_Cover/delete_button.png'
          site_title = @object.title rescue 'none'
          site_description = @object.description rescue ''
          site_favicon = @object.favicon rescue ''

          @photo = @current_gallery.photos.build(path: images_path)
          @photo.name = path
          @photo.description = site_title + " " + site_description rescue ''
          @photo.source_type = 'link'

          if @photo.save # Not user problem!
            redirect_to photo_gallery_photos_path(@current_gallery.id)
          else
            render 'new'
          end
        else
          flash[:alert] = t(:link_thumbnailer)
          redirect_to new_link_path(@current_gallery)
        end
      else
        flash[:alert] = t(:no_data)
        redirect_to root_path
      end
    else
      flash[:alert] = t(:restrict_to_add_photo)
      redirect_to root_path
    end
  end

  def create
    @current_gallery = PhotoGallery
                       .find_by('id = ?', params[:photo_gallery_id]) # ok

    if @current_gallery && (current_human == @current_gallery.human ||
                            current_human.admin?)

      if params[:uploading] &&
         params[:uploading].is_a?(Hash) &&
         params[:uploading][:files] &&
         params[:uploading][:files].respond_to?(:each)

        files = params[:uploading][:files] # ok

        # Folder path for storing files
        dir = "private/photo_galleries/human_#{current_human.id}/" \
              "photo_gallery_#{@current_gallery.id}/"
        @json = []

        files.each do |file|
          # Checking content of 'file' variable
          if file.respond_to?(:content_type) &&
             file.respond_to?(:original_filename)

            file_name = file.original_filename # ok

            # Check file type
            if file.content_type == 'image/jpeg' ||
               file.content_type == 'image/png'

              # If file has been handled - creating photo object
              if file_path_for_db = handle_file(file, dir) # ok
                @photo = @current_gallery.photos.build(path: file_path_for_db)
                @photo.save # Not user problem!
                @json << { id: @photo.id }
              else
                # add error message to @json and Flash
                @json << add_error(file_name) # questionable place
              end
            else
              # add error message to @json and Flash
              @json << add_error(file_name) # questionable place
            end
          end
        end
        # sending answer
        if request.xhr?
          render json: @json
        else
          redirect_to photo_gallery_photos_path(@current_gallery.id)
        end
      else
        # sending answer if wrong attributes
        if request.xhr?
          render json: { message: t(:wrong_data) }
        else
          flash[:alert] = t(:wrong_data)
          redirect_to root_path
        end
      end
    else
      # sending answer if no access
      if request.xhr?
        render json: { message: t(:restrict_to_add_photo) }
      else
        flash[:alert] = t(:restrict_to_add_photo)
        redirect_to root_path
      end
    end
  end

  def edit
    if @photo = Photo.find_by('id = ?', params[:id]) # ok
      @current_gallery = @photo.photo_gallery

      if @current_gallery && (@current_gallery.human == current_human ||
                              current_human.admin?)
        render 'edit'
      else
        flash[:alert] = t(:restrict_to_change_photo)
        redirect_to root_path
      end
    else
      flash[:alert] = t(:no_photo)
      redirect_to root_path
    end
  end

  def update
    if @photo = Photo.find_by('id = ?', params[:id]) # ok
      @current_gallery = @photo.photo_gallery

      if @current_gallery && (@current_gallery.human == current_human ||
                              current_human.admin?)
        # Photo rotation
        rotation = params[:rotation] # ok
        if rotation == 'left' || rotation == 'right'

          photo_rotation photo_path: @photo.path, rotation: rotation

          if request.xhr?
            render json: { status: 'OK' }
          else
            render 'edit'
          end
        else
          # Update attributes
          if params[:make_me_cover] == '1' # ok
            @current_gallery.cover = @photo.id
            @current_gallery.save # Not user problem!
          end
          @photo.update_attributes(attributes) # ok

          # Check errors
          if @photo.errors.any?
            if request.xhr?
              render json: { status: 'BAD', errors: get_errors(@photo) }
            else
              render 'edit'
            end
          else
            if request.xhr?
              render json: { status: 'OK' }
            else
              redirect_to photo_path(@photo.id)
            end
          end
        end
      else
        flash[:alert] = t(:restrict_to_change_photo)
        redirect_to root_path
      end
    else
      flash[:alert] = t(:no_photo)
      redirect_to root_path
    end
  end

  def destroy
    if @photo = Photo.find_by('id = ?', params[:id]) # ok
      @photo_gallery = @photo.photo_gallery
      if @photo_gallery && (@photo_gallery.human == current_human ||
                            current_human.admin?)

        # if has been deleted
        if @photo.destroy
          if request.xhr?
            render json: { status: 'OK', errors: 'NoErrors' }
          else
            flash[:message] = t(:deleted_photo)
            redirect_to photo_gallery_photos_path(@photo_gallery.id)
          end

        # if hasn't been deleted
        else
          if request.xhr?
            render json: { status: 'BAD', errors: get_errors(@photo) }
          else
            flash[:alert] = t(:delete_photo_problem)
            redirect_to photo_gallery_photos_path(@photo_gallery.id)
          end
        end
      else
        flash[:alert] = t(:restrict_to_delete_photo)
        redirect_to root_path
      end
    else
      flash[:alert] = t(:no_photo)
      redirect_to root_path
    end
  end

  private

  def attributes_link
    if !params[:link_resource].blank? && params[:link_resource].is_a?(Hash)
      return params.require(:link_resource).permit(:description)
    else
      return {}
    end
  end

  def attributes
    if !params[:photo].blank? && params[:photo].is_a?(Hash)
      return params.require(:photo).permit(:name)
    else
      return {}
    end
  end

  def get_errors(object)
    errors = []
    object.errors.full_messages.each do |error|
      errors << error
    end
    errors
  end

  def add_error(filename)
    flash[:alert] ||= []
    flash[:alert] << t(:file) + " '" + filename + # questionable place
      "' " + t(:upload_problem)
    { name: filename, id: 'None' } # questionable place
  end

  def handle_file(file, dir)
    # Creating data for file
    file_name = DateTime.now.strftime('%H%M%S_%d%m%Y') +
                SecureRandom.urlsafe_base64 +
                '.png'

    file_path = Rails.root.join(dir, file_name)
    file_path_resized = Rails.root.join(dir, 'resized_' + file_name)
    file_path_for_db = '/' + dir + file_name

    # Creating new folder if doesn't exist
    unless File.exist?(Rails.root.join(dir))
      FileUtils.mkdir_p(Rails.root.join(dir), mode: 0700)
    end

    # Convert uploaded file to ".png"
    MiniMagick::Tool::Convert.new(false) do |convert|
      convert << file.path # questionable place
      convert << '-resize'
      convert << '800x800'
      convert << '-auto-orient'
      convert << file_path
    end

    # Resizing
    MiniMagick::Tool::Convert.new(false) do |convert|
      convert << file_path # questionable place
      convert << '-resize'
      convert << '300x300'
      convert << file_path_resized
    end

    if File.exist?(file_path)
      return file_path_for_db
    else
      return false
    end
  end

  def photo_rotation(hash = {})
    path1 = hash[:photo_path]
    path2 = path1[%r{\A.*/}] + 'resized_' + path1[%r{[^/]*\z}]
    full_paths = ["#{Rails.root}/#{path1}", "#{Rails.root}/#{path2}"]
    full_paths.each do |path|
      MiniMagick::Tool::Convert.new do |convert|
        convert << path
        convert << '-rotate'
        convert << '90' if hash[:rotation] == 'right'
        convert << '-90' if hash[:rotation] == 'left'
        convert << path
      end
    end
  end

  def check_path(type, path)
    if type == 'resized'
      path[%r{\A.*/}] + 'resized_' + path[%r{[^/]*\z}]
    elsif type == 'full'
      path
    else
      return false
    end
  end
end
