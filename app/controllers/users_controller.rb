class UsersController < ApplicationController

  before_action :require_login, except: [:new, :create]
  before_action :user_is_current_user?, only: [:edit, :update]

  def index
    if params[:query]
      @users = User.search(params[:query])
    else
      @users = User.all
    end
  end

  def new
    if current_user
      redirect_to user_posts_path(current_user.id)
    else
      @user = User.new
    end
  end

  def create
    if current_user
      redirect_to user_posts_path(current_user.id)
    else
      @user = User.new(user_params)

      if @user.save
        sign_in(@user)
        flash[:success] = "Congrats on making your account!"

        redirect_to user_posts_path(current_user.id)
      else
        errors = @user.errors.full_messages.join(", ")
        flash[:sorry] = "We could not create an accout. #{errors}"
        render :new
      end
    end

  end

  def show
    @profile = User.find(params[:id]).profile
  end

  def edit
    @user = User.find(params[:id])
    @profile = @user.profile
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      flash[:success] = "You successfully updated your profile."
      redirect_to user_path(current_user.id)

    else
      errors = @user.errors.full_messages.join(", ")
      flash[:sorry] = "We could not update your profile. #{errors}"
      render :edit
    end

  end

  def edit_cover_photo
    @user = User.find(params[:user_id])
    @profile = @user.profile
    @photos = Photo.where(user_id: params[:user_id])

  end

  def edit_profile_photo
    @user = User.find(params[:user_id])
    @profile = @user.profile
    @photos = Photo.where(user_id: params[:user_id])
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, 
                                  :gender, :birthday, :email, :password,
                                   :password_confirmation, profile_attributes: 
                                   [:college, :city, :state, :country, :phone, 
                                    :words_to_live_by, :about_me, 
                                    :password_confirmation, :profile_photo_id, :cover_photo_id])
  end


  def user_is_current_user?
    unless params[:id].to_i == current_user.id
      flash[:error] = "Not authorized!"
      redirect_to user_posts_path(current_user.id)
    end
  end
end
