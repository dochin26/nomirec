class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_redirect_location

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  # 登録ボタンから来た場合のみ記録
  def store_redirect_location
    # from_registerパラメータがある場合のみセッションに記録
    if params[:from_register] == "true"
      session[:redirect_to_posts_after_sign_in] = true
    end
  end

  private

  def public_action?
    controller_name == "static_pages" && action_name == "index"
  end
end
