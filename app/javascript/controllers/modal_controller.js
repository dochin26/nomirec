import { Controller } from "@hotwired/stimulus"

/**
 * モーダルの表示・非表示を制御するStimulusコントローラー
 *
 * 機能:
 * - モーダルの開閉
 * - Escキーで閉じる
 * - 背景クリックで閉じる
 * - アニメーション対応
 */
export default class extends Controller {
  static targets = ["container", "backdrop", "panel"]

  connect() {
    // Escキーでモーダルを閉じる
    this.handleKeydown = this.handleKeydown.bind(this)

    if (this.hasContainerTarget) {
      // Turbo Frameから呼び出された場合、モーダルを開く
      this.open()
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)

    // ページ遷移時にもbodyのスクロールを復元
    document.body.style.overflow = ""
  }

  /**
   * モーダルを開く
   */
  open() {
    this.containerTarget.classList.remove("hidden")

    // アニメーション用に少し遅延
    requestAnimationFrame(() => {
      this.backdropTarget.classList.remove("opacity-0")
      this.backdropTarget.classList.add("opacity-100")
      this.panelTarget.classList.remove("opacity-0", "translate-y-4", "sm:translate-y-0", "sm:scale-95")
      this.panelTarget.classList.add("opacity-100", "translate-y-0", "sm:scale-100")
    })

    // Escキーのリスナーを追加
    document.addEventListener("keydown", this.handleKeydown)

    // bodyのスクロールを防止
    document.body.style.overflow = "hidden"
  }

  /**
   * モーダルを閉じる
   */
  close() {
    // アニメーションを逆再生
    this.backdropTarget.classList.remove("opacity-100")
    this.backdropTarget.classList.add("opacity-0")
    this.panelTarget.classList.remove("opacity-100", "translate-y-0", "sm:scale-100")
    this.panelTarget.classList.add("opacity-0", "translate-y-4", "sm:translate-y-0", "sm:scale-95")

    // アニメーション完了後に非表示
    setTimeout(() => {
      this.containerTarget.classList.add("hidden")

      // Turbo Frameの中身を空にする
      const turboFrame = this.element.closest('turbo-frame')
      if (turboFrame) {
        turboFrame.innerHTML = ''
      }
    }, 200)

    // Escキーのリスナーを削除
    document.removeEventListener("keydown", this.handleKeydown)

    // bodyのスクロールを復元
    document.body.style.overflow = ""
  }

  /**
   * 背景クリック時の処理
   */
  closeOnBackdrop(event) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }

  /**
   * Escキー押下時の処理
   */
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
