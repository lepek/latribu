class MessagesController < ApplicationController

  def index
    respond_to do |format|
      format.html
      format.json { render json: MessageDatatable.new(view_context) }
    end
  end

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    if @message.save
      redirect_to messages_path, success: "Nueva notifiación creada."
    else
      render :new
    end
  end

  def edit
    @message = Message.find(params[:id])
  end

  def update
    @message = Message.find(params[:id])
    @message.update_attributes!(message_params)
    redirect_to messages_path, success: "La notifiación ha sido modificada."
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    redirect_to messages_path, success: "La notifiación ha sido borrada"
  end

  def message_params
    params[:message][:show_credit_less] = -1 unless params[:message][:show_credit_less_check].present?
    params[:message].delete(:show_credit_less_check)
    params.require(:message).permit(:message, :start_date, :end_date, :show_all, :show_no_certificate, :show_credit_less)
  end

end