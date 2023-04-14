class AuthenticationController < ApplicationController
  # rubocop:disable Metrics/MethodLength

  def signup
    @user = User.find_by_email(signup_params[:email])
    if @user.present?
      render json: { message: 'Failed to create a user', error: 'User already exists' }, status: :conflict
    else
      @user = User.new(signup_params)
      if @user.save
        token = JsonWebToken.encode(user_id: @user.id)
        time = Time.now + 24.hours.to_i
        render json: {
          token: token,
          exp: time.strftime('%m-%d-%Y %H:%M'),
          user: {
            id: @user.id,
            name: @user.name,
            email: @user.email
          }
        }, status: :ok
      elsif @user
        render json: { message: 'Failed to create an account', error: 'Password cannot be less than 6 letters' },
               status: :unprocessable_entity
      else
        render json: { message: 'Failed to create an account', error: 'Validation failed' },
               status: :unprocessable_entity
      end
    end
  end

  # rubocop:enable Metrics/MethodLength

  def login
    @user = User.find_by_email(login_params[:email])
    if @user&.authenticate(login_params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      time = Time.now + 24.hours.to_i
      render json: {
        token: token,
        exp: time.strftime('%m-%d-%Y %H:%M'),
        user: {
          id: @user.id,
          name: @user.name,
          email: @user.email
        }
      }, status: :ok
    elsif @user
      render json: { message: 'You are not authorize to access this account', error: 'Incorrect password' },
             status: :unauthorized
    else
      render json: { message: 'You are not authorize to access this account', error: 'Incorrect email' },
             status: :unauthorized
    end
  end

  private

  def signup_params
    params.require(:user).permit(:name, :email, :password)
  end

  def login_params
    params.require(:user).permit(:email, :password)
  end
end
