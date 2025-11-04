class Users::SessionsController < Devise::SessionsController
  def new
    super
  end

  def create
    super do |resource|
      # 登録ボタンから来た場合は、stored_locationをpostsページで上書き
      if session[:redirect_to_posts_after_sign_in]
        session.delete(:redirect_to_posts_after_sign_in)
        store_location_for(resource, posts_path)
      end
    end
  end

  def destroy
    super
  end

  # Rails 7.1対応
  def index
    redirect_to root_path
  end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
