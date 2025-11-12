class AccountsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    # パスワード変更がリクエストされている場合
    if password_change_requested?
      update_with_password_change
    else
      # 通常の更新(名前、メール、アバターのみ)
      if @user.update(account_params)
        redirect_to mypage_path, notice: "アカウント情報を更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private

  def password_change_requested?
    params[:user][:password].present?
  end

  def update_with_password_change
    # Google OAuth経由のユーザーはパスワード変更不可
    if @user.provider.present?
      @user.errors.add(:base, "Google認証でログインしているため、パスワードは変更できません")
      render :edit, status: :unprocessable_entity
      return
    end

    # Deviseのupdate_with_passwordメソッドを使用
    # 現在のパスワードの確認が必要
    if @user.update_with_password(account_params_with_password)
      bypass_sign_in(@user) # パスワード変更後も自動ログイン
      redirect_to mypage_path, notice: "アカウント情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def account_params
    params.require(:user).permit(:name, :email, :avatar)
  end

  def account_params_with_password
    params.require(:user).permit(:name, :email, :avatar, :current_password, :password, :password_confirmation)
  end
end
