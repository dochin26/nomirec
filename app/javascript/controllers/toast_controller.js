import { Controller } from "@hotwired/stimulus"

/**
 * トーストメッセージの表示を制御するStimulusコントローラー
 *
 * 機能:
 * - スライドインアニメーション
 * - 自動非表示（3秒後）
 * - 手動で閉じる機能
 */
export default class extends Controller {
  static values = {
    type: String
  }

  connect() {
    // スライドインアニメーション
    requestAnimationFrame(() => {
      this.element.classList.remove("translate-x-full")
      this.element.classList.add("translate-x-0")
    })

    // 3秒後に自動で閉じる
    this.timeout = setTimeout(() => {
      this.close()
    }, 3000)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  /**
   * トーストを閉じる
   */
  close() {
    // スライドアウトアニメーション
    this.element.classList.remove("translate-x-0")
    this.element.classList.add("translate-x-full")

    // アニメーション完了後に要素を削除
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  /**
   * 削除イベント
   */
  remove() {
    this.element.remove()
  }
}
