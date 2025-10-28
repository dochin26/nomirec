class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [ :google_oauth2, :failure ]

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      flash[:notice] = "Googleアカウントでログインしました。"
      sign_in_and_redirect @user, event: :authentication
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
