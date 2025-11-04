import { Controller } from "@hotwired/stimulus"

/**
 * フォーム送信時のローディング状態を制御するStimulusコントローラー
 *
 * 機能:
 * - フォーム送信時のローディング表示
 * - ボタンの二重送信防止
 * - 送信中のオーバーレイ表示
 */
export default class extends Controller {
  static targets = ["submit", "spinner", "overlay"]

  /**
   * フォーム送信開始時の処理
   */
  start(event) {
    // 既にローディング中なら送信をキャンセル
    if (this.isLoading) {
      event.preventDefault()
      return
    }

    this.isLoading = true

    // 送信ボタンを無効化
    this.submitTargets.forEach(button => {
      button.disabled = true
      button.classList.add("opacity-50", "cursor-not-allowed")

      // ボタンテキストを変更
      const originalText = button.textContent
      button.dataset.originalText = originalText
      button.textContent = "送信中..."
    })

    // スピナーを表示
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.remove("hidden")
    }

    // オーバーレイを表示
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("hidden")
    }
  }

  /**
   * フォーム送信完了時の処理（成功・失敗問わず）
   */
  end() {
    this.isLoading = false

    // 送信ボタンを有効化
    this.submitTargets.forEach(button => {
      button.disabled = false
      button.classList.remove("opacity-50", "cursor-not-allowed")

      // ボタンテキストを元に戻す
      if (button.dataset.originalText) {
        button.textContent = button.dataset.originalText
        delete button.dataset.originalText
      }
    })

    // スピナーを非表示
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.add("hidden")
    }

    // オーバーレイを非表示
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("hidden")
    }
  }

  /**
   * Turboフレームのエラー時の処理
   */
  handleError() {
    this.end()
  }
}
