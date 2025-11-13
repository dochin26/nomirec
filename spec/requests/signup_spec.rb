require 'rails_helper'

RSpec.describe "Google OAuth", type: :request do
  describe 'GET /users/auth/google_oauth2/callback' do
    before do
      # https://github.com/omniauth/omniauth/wiki/Integration-Testing
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
      # 認証のコールバック
      get '/users/auth/google_oauth2/callback', params: { provider: "google_oauth2" }
    end

    it 'Google認証が成功し、リダイレクトすること' do
      expect(response).to have_http_status(302)
    end

    it 'ユーザーが作成されること' do
      expect(User.find_by(email: "john@example.com")).to be_present
    end
  end
end
