# Just a human controller
class HumansController < ApplicationController
  before_action :human_only
  skip_before_action :human_only, only: [:new, :create]

  def show
    @human = Human.find_by('id = ?', params[:id]) # looks securely
    return if @human
    flash[:alert] = t(:no_id)
    redirect_to root_path
  end

  def send_avatar
    @human = Human.find_by('id = ?', params[:id]) # looks securely
    if !@human
      flash[:alert] = t(:no_id)
      redirect_to root_path
    else
      avatar_path = Rails.root.to_s + @human.avatar
      send_file avatar_path, x_sendfile: true
    end
  end

  def index
    @humans = Human.numbering(params[:list], 25, 5) # numbering looks securely
  end

  def new
    if !current_human
      @human = Human.new
    else
      flash[:alert] = t(:must_be_logged_out)
      redirect_to root_path
    end
  end

  def create
    if !current_human
      @human = Human.new(attributes) # this is handled by model validations
      if @human && @human.save

        dir = "private/avatars/human_#{@human.id}"
        unless File.exist?(Rails.root.join(dir))
          FileUtils.mkdir_p(Rails.root.join(dir), mode: 0700)
        end

        MiniMagick::Tool::Convert.new do |convert|
          convert << "#{Rails.root}/public/Default_Cover/Default_Avatar.png"
          convert << "#{Rails.root}/" + dir + '/avatar.png'
        end

        @human.avatar = "/private/avatars/human_#{@human.id}/avatar.png"

        # Creating activation token
        begin
          token = SecureRandom.urlsafe_base64
          @human.activation_token = BCrypt::Password.create(token)
        end while Human.exists?(activation_token: @human.activation_token)
        @human.activation_request_at = DateTime.now

# with no Mailer auto-activation

        @human.activation_status = 'Activated'
        @human.activated_at = DateTime.now

        if @human.save

# with Mailer
#         HumanMailer.account_activation(@human, token).deliver_now

          flash[:message] = t(:new_profile)
          redirect_to root_path
        else
          render 'new'
        end
      else
        render 'new'
      end
    else
      flash[:alert] = t(:must_be_logged_out)
      redirect_to root_path
    end
  end

  def edit
    @human = Human.find_by('id = ?', params[:id]) # looks securely
    if @human && (@human.id == current_human.id || current_human.admin?)
      render 'edit'
    else
      flash[:alert] = t(:restrict_to_change_profile)
      redirect_to root_path
    end
  end

  def update
    @human = Human.find_by('id = ?', params[:id]) # looks securely

    if @human && (@human.id == current_human.id || current_human.admin?)

      # if new avatar
      if file = file_attribute # looks securely
        dir = "private/avatars/human_#{@human.id}/"
        file_path = Rails.root.join(dir, 'avatar.png')
        @human.avatar = '/' + dir + 'avatar.png'

        # Creating folder
        unless File.exist?(Rails.root.join(dir))
          FileUtils.mkdir_p(Rails.root.join(dir), mode: 0700)
        end

        # Convert uploaded file to ".png"
        MiniMagick::Tool::Convert.new(false) do |convert|
          convert << file.path # questionable place
          convert << '-resize'
          convert << '200x200'
          convert << file_path
        end
        @human.save(validate: false)
      end

      # Avatar rotation.
      if !params[:rotate_avatar].blank? &&
         params[:rotate_avatar] != 'nope' &&
         !file
        avatar_rotation avatar_path: @human.avatar,
                        rotation: params[:rotate_avatar] # looks securely
      end

      # Checking for errors
      if attributes
        @human.update_attributes(attributes) # looks securely
        if @human.errors.any?
          render 'edit'
        else
          flash[:message] = t(:successful_update)
          redirect_to human_path(@human.id)
        end
      else
        flash[:alert] = t(:no_data)
        redirect_to root_path
      end

    else
      flash[:alert] = t(:restrict_to_change_profile)
      redirect_to root_path
    end
  end

  def destroy
    if current_human.admin?
      @human = Human.find_by('id = ?', params[:id]) # looks securely
      if @human && @human.id != current_human.id && @human.destroy
        flash[:message] = @human.name + t(:deleted)
        redirect_to humans_path
      else
        flash[:alert] = t(:delete_profile_problem)
        redirect_to root_path
      end
    else
      flash[:alert] = t(:nope)
      redirect_to root_path
    end
  end

  private

  def avatar_rotation(hash = {})
    full_path = "#{Rails.root}#{hash[:avatar_path]}"
    MiniMagick::Tool::Convert.new do |convert|
      convert << full_path
      convert << '-rotate'
      convert << '90' if hash[:rotation] == 'right' # looks securely
      convert << '-90' if hash[:rotation] == 'left' # looks securely
      convert << '180' if hash[:rotation] == 'upside_down' # looks securely
      convert << full_path
    end
  end

  def attributes
    return if params[:human].blank? || !params[:human].is_a?(Hash)
    params.require(:human).permit(:name,
                                  :email,
                                  :password,
                                  :password_confirmation)
  end

  def file_attribute
    return if params[:human].blank? || !params[:human].is_a?(Hash)
    params.require(:human).permit(:avatar)[:avatar]
  end
end
