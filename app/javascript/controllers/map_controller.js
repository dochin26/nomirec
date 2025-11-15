import { Controller } from "@hotwired/stimulus"

/**
 * Google Maps表示を制御するStimulusコントローラー
 *
 * 機能:
 * - 地図の初期化と表示
 * - 住所からの位置検索（ジオコーディング）
 * - マーカーの表示
 */
export default class extends Controller {
  static targets = ["container"]
  static values = {
    address: String
  }

  connect() {
    this.map = null
    this.geocoder = null
    this.currentMarker = null

    // Google Maps APIが読み込まれているか確認
    if (typeof google !== 'undefined' && google.maps) {
      this.initMap()
    } else {
      // APIがまだ読み込まれていない場合は、読み込みを待つ
      this.waitForGoogleMaps()
    }
  }

  waitForGoogleMaps() {
    const checkInterval = setInterval(() => {
      if (typeof google !== 'undefined' && google.maps) {
        clearInterval(checkInterval)
        this.initMap()
      }
    }, 100)

    // 10秒後にタイムアウト
    setTimeout(() => {
      clearInterval(checkInterval)
      if (!this.map) {
        console.error('Google Maps API failed to load')
      }
    }, 10000)
  }

  /**
   * 地図を初期化
   */
  initMap() {
    console.log("Google Maps API loaded")

    this.map = new google.maps.Map(this.containerTarget, {
      zoom: 15,
      center: { lat: 35.6812, lng: 139.7671 } // デフォルト: 東京駅
    })

    this.geocoder = new google.maps.Geocoder()

    // 住所が指定されている場合はその場所を表示
    const address = this.addressValue || '東京駅'
    this.geocodeAddress(address)
  }

  /**
   * 住所から位置を検索してマーカーを表示
   */
  geocodeAddress(address) {
    if (!this.geocoder) return

    if (!address || address === '') {
      address = '東京駅'
    }

    this.geocoder.geocode({
      address: address,
      region: 'JP'
    }, (results, status) => {
      if (status === "OK" && results && results.length > 0) {
        const location = results[0].geometry.location

        if (!this.map) return

        // 既存のマーカーを削除
        if (this.currentMarker) {
          this.currentMarker.setMap(null)
        }

        // 地図の中心を移動
        this.map.setCenter(location)

        // 新しいマーカーを追加
        this.currentMarker = new google.maps.Marker({
          map: this.map,
          position: location,
          title: results[0].formatted_address
        })
      } else {
        alert("住所が見つかりませんでした")
      }
    })
  }

  disconnect() {
    // クリーンアップ
    if (this.currentMarker) {
      this.currentMarker.setMap(null)
    }
    this.map = null
    this.geocoder = null
    this.currentMarker = null
  }
}
