class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [ :google_oauth2, :failure ]

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      flash[:notice] = "Googleアカウントでログインしました。"

      # 登録ボタンから来た場合は、postsページにリダイレクト
      if session[:redirect_to_posts_after_sign_in]
        session.delete(:redirect_to_posts_after_sign_in)
        sign_in @user, event: :authentication
        redirect_to posts_path
      else
        sign_in_and_redirect @user, event: :authentication
      end
    else
      session["devise.google_data"] = request.env["omniauth.auth"].except("extra")
      flash[:alert] = "ログインに失敗しました。"
      redirect_to new_user_session_path
    end
  end

  def failure
    flash[:alert] = "ログインがキャンセルされました。"
    redirect_to new_user_session_path
  end
end
