import { Controller } from "@hotwired/stimulus"

/**
 * 新規投稿ボタンの動作を制御するStimulusコントローラー
 *
 * 機能:
 * - postsページにいる場合: Turbo Frameでモーダルを開く
 * - それ以外のページ: postsページに遷移してからモーダルを開く
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

    // ログイン済み: モーダルを開く処理
    const currentPath = window.location.pathname

    // postsページにいるかチェック
    if (currentPath === '/posts' || currentPath.startsWith('/posts?')) {
      // postsページにいる場合: Turbo Frameでモーダルを直接開く
      const frame = document.getElementById('post_modal')
      if (frame) {
        frame.src = this.element.href.replace(/\?.*$/, '') // クエリパラメータを削除
      }
    } else {
      // それ以外のページ: postsページに遷移してからモーダルを開く
      window.location.href = '/posts?open_modal=new'
    }
  }
}
