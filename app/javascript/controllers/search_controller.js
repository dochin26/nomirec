import { Controller } from "@hotwired/stimulus"

/**
 * 検索フォームの送信を制御するStimulusコントローラー
 *
 * 動作:
 * - オートコンプリートから選択時: 即座にフォーム送信
 * - 手動入力時: Enterキーを2回押すことでフォーム送信
 */
export default class extends Controller {
  static targets = ["form", "input"]

  // 定数
  static ENTER_REQUIRED_COUNT = 2
  static AUTOCOMPLETE_DELAY_MS = 100

  connect() {
    this.resetEnterCount()
  }

  /**
   * オートコンプリートから選択された時の処理
   * autocomplete.changeイベントから呼び出される
   */
  submitForm() {
    // オートコンプリートの値が入力フィールドに反映されるまで待機
    setTimeout(() => {
      this.formTarget.requestSubmit()
      this.resetEnterCount()
    }, this.constructor.AUTOCOMPLETE_DELAY_MS)
  }

  /**
   * Enterキー押下時の処理
   * 2回目のEnterキーでフォーム送信を実行
   */
  handleKeydown(event) {
    if (event.key !== "Enter") return

    event.preventDefault()
    this.enterPressCount++

    if (this.enterPressCount >= this.constructor.ENTER_REQUIRED_COUNT) {
      this.formTarget.requestSubmit()
      this.resetEnterCount()
    }
  }

  /**
   * Enterキーのカウントをリセット
   */
  resetEnterCount() {
    this.enterPressCount = 0
  }
}
