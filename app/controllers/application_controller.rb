class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_redirect_location
  before_action :set_default_meta_tags

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

  def set_default_meta_tags
    set_meta_tags(
      site: "NomireQ",
      reverse: true,
      charset: "utf-8",
      description: "お気に入りの飲み屋を記録・共有するサービス",
      keywords: "飲み屋,居酒屋,バー,日本酒,料理,グルメ",
      og: {
        type: "website",
        site_name: "NomireQ",
        locale: "ja_JP"
      },
      twitter: {
        card: "summary_large_image",
        site: "@nomireQ"
      }
    )
  end

  def public_action?
    controller_name == "static_pages" && action_name == "index"
  end
end
