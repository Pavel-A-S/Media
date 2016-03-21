# Just a comments controller
class CommentsController < ApplicationController
  before_action :human_only

  def create
    if @photo = Photo.find_by('id = ?', params[:photo_id]) # ok
      if @comment = current_human.comments.build(attributes) # ok
        @comment.photo_id = @photo.id
        if @comment.save
          redirect_to photo_path(@comment.photo_id) + '#bottom'
        else
          flash[:alert] = get_errors(@comment)
          redirect_to photo_path(@comment.photo_id) + '#'
        end
      else
        flash[:alert] = t(:wrong_data)
        redirect_to root_path
      end
    else
      flash[:alert] = t(:no_photo)
      redirect_to root_path
    end
  end

  def destroy
    if @comment = Comment.find_by('id = ?', params[:id]) # ok
      if @comment.human == current_human || current_human.admin?
        if @comment.destroy
          flash[:message] = t(:deleted_comment)
          redirect_to photo_path(@comment.photo_id)
        else
          flash[:alert] = t(:delete_comment_problem)
          redirect_to root_path
        end
      else
        flash[:alert] = t(:restrict_to_delete_comment)
        redirect_to root_path
      end
    else
      flash[:alert] = t(:no_comment)
      redirect_to root_path
    end
  end

  private

  def attributes
    return if params[:comment].blank? || !params[:comment].is_a?(Hash) # ok
    params.require(:comment).permit(:text)
  end

  def get_errors(object)
    errors = []
    object.errors.full_messages.each do |error|
      errors << error
    end
    errors
  end
end
