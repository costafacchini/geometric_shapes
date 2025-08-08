class FramesController < ApplicationController
  before_action :set_frame, only: [ :show, :destroy ]

  # POST /frames
  def create
    @frame = Frame.new(frame_params)

    if @frame.save
      render :create, status: :created
    else
      render json: { errors: @frame.errors.full_messages }, status: :unprocessable_content
    end
  end

  # GET /frames/:id
  def show
    render :show
  end

  # DELETE /frames/:id
  def destroy
    if @frame.circles.exists?
      render json: { error: "Cannot delete frame with associated circles" }, status: :unprocessable_content
    else
      @frame.destroy
      head :no_content
    end
  end

  private

  def set_frame
    @frame = Frame.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Frame not found" }, status: :not_found
  end

  def frame_params
    params.require(:frame).permit(:x, :y, :width, :height)
  end
end
