# Just a chats controller
class ChatsController < ApplicationController
  before_action :human_only

  def index
    @messages = Chat.limit(1000).order('created_at desc')
    @message = Chat.new
  end

  def show
    @messages = Chat.limit(1000).order('created_at desc')
    if !@messages.blank?
      if @messages.first.id == params[:id].to_i # ok
        render json: { status: 'NoChanges' }
      else
        render json: { status: 'Refresh',
                       data: render_to_string('_messages',
                                              locals: { object: @messages },
                                              layout: false) }
      end
    else
      render json: { status: 'NoChanges' }
    end
  end

  def create
    @message = current_human.chats.build
    if @message.update_attributes(attributes) # ok
      render json: { status: 'Ok' }
    else
      render json: { status: 'errors', errors: get_errors(@message) }
    end
  end

  private

  def get_errors(object)
    errors = []
    object.errors.full_messages.each do |error|
      errors << error
    end
    errors
  end

  def attributes
    if !params[:chat].blank? && params[:chat].is_a?(Hash)
      return params.require(:chat).permit(:text) # ok
    else
      return {}
    end
  end
end
