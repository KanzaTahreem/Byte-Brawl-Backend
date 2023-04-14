class UsersController < ApplicationController
  before_action :authorize_request
  before_action :find_user

  def index
    @users = User.all
    render json: @users, status: :ok
  end

  def show
    render json: @user, status: :ok
  end

  def update
    return if @user.update(user_params)

    render json: { errors: @user.errors.full_messages },
           status: :unprocessable_entity
  end

  def destroy
    if @user.destroy
      render json: { success: 'User destroyed successfully' }, status: :ok
    else
      render :json, { error: 'Unable to destroy a user' }, status: :unprocessable_entity
    end
  end

  private

  def find_user
    @user = User.find_by_id(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: 'User not found' }, status: :not_found
  end

  def user_params
    params.permit(:name, :email, :password)
  end
end
