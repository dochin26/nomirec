import { Controller } from "@hotwired/stimulus"

/**
 * フォームのリアルタイムバリデーションを制御するStimulusコントローラー
 *
 * 機能:
 * - フィールドごとのバリデーション
 * - エラーメッセージ表示
 * - 視覚的フィードバック
 */
export default class extends Controller {
  static targets = ["field"]

  /**
   * フィールドのバリデーション
   */
  validate(event) {
    const field = event.target
    const fieldContainer = field.closest("[data-form-validation-target='field']")

    if (!fieldContainer) return

    // 既存のエラーメッセージを削除
    this.clearError(fieldContainer)

    // バリデーションチェック
    if (!field.checkValidity()) {
      this.showError(fieldContainer, field, field.validationMessage)
    } else if (field.hasAttribute("required") && field.value.trim() === "") {
      this.showError(fieldContainer, field, "この項目は必須です")
    } else {
      this.showSuccess(fieldContainer, field)
    }
  }

  /**
   * エラー表示
   */
  showError(container, field, message) {
    // フィールドのスタイルを更新
    field.classList.remove("border-gray-300", "border-green-500")
    field.classList.add("border-red-500", "focus:border-red-500", "focus:ring-red-500")

    // エラーメッセージを追加
    const errorDiv = document.createElement("div")
    errorDiv.className = "mt-1 text-sm text-red-600"
    errorDiv.dataset.errorMessage = "true"
    errorDiv.textContent = message

    container.appendChild(errorDiv)
  }

  /**
   * 成功表示
   */
  showSuccess(container, field) {
    // フィールドのスタイルを更新
    field.classList.remove("border-gray-300", "border-red-500")
    field.classList.add("border-green-500")
  }

  /**
   * エラーメッセージをクリア
   */
  clearError(container) {
    const errorMessage = container.querySelector("[data-error-message]")
    if (errorMessage) {
      errorMessage.remove()
    }

    // フィールドのエラースタイルをリセット
    const field = container.querySelector("input, textarea, select")
    if (field) {
      field.classList.remove("border-red-500", "border-green-500", "focus:border-red-500", "focus:ring-red-500")
      field.classList.add("border-gray-300")
    }
  }

  /**
   * すべてのエラーをクリア
   */
  clearAllErrors() {
    this.fieldTargets.forEach(container => {
      this.clearError(container)
    })
  }
}
