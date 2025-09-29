class LocationsController < ApplicationController
  def show
    raw_address = params[:address] || "東京駅"
    @address = normalize_address(raw_address)
    @api_key = Rails.application.credentials.googlemaps[:api_key]

    puts(@address)

    # デバッグ用
    Rails.logger.info "正規化前の住所: #{raw_address}"
    Rails.logger.info "正規化後の住所: #{@address}"

    respond_to do |format|
      format.html
      format.json { render json: { address: @address } }
    end
  end

  private

  def normalize_address(address)
    return "東京駅" if address.blank?

    # ほぼそのまま返す（空白のみ削除）
    address.strip
  end

  def location_params
    params.permit(:address)
  end
end
