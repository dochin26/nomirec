import { Controller } from "@hotwired/stimulus"

/**
 * 新規投稿ボタンの動作を制御するStimulusコントローラー
 *
 * 機能:
 * - どのページからでもTurbo Frameでモーダルを開く
 * - 未ログイン時: サーバー側で認証チェック
 */
export default class extends Controller {
  openModal(event) {
    event.preventDefault()

    // 認証状態をチェック
    const isAuthenticated = document.body.dataset.userSignedIn === 'true'

    if (!isAuthenticated) {
      // 未ログイン: from_registerパラメータを付けて遷移
      window.location.href = this.element.href + '?from_register=true'
      return
    }

    // ログイン済み: どのページからでもTurbo Frameでモーダルを開く
    const frame = document.getElementById('post_modal')
    if (frame) {
      // クエリパラメータを削除してからTurbo Frameに読み込む
      frame.src = this.element.href.replace(/\?.*$/, '')
    }
  }
}
