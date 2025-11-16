import { Controller } from "@hotwired/stimulus"

/**
 * 画像アップロード時のプレビュー表示を制御するStimulusコントローラー
 *
 * 機能:
 * - ファイル選択時にプレビュー表示
 * - ドラッグ&ドロップ対応
 * - 画像削除機能
 * - ファイルサイズ・形式バリデーション
 */
export default class extends Controller {
  static targets = ["input", "preview", "placeholder", "fileName", "fileSize", "removeButton"]
  static values = {
    existingImageUrl: String
  }

  // 定数
  static MAX_FILE_SIZE = 10 * 1024 * 1024 // 10MB
  static ALLOWED_TYPES = ["image/jpeg", "image/png", "image/webp", "image/gif"]

  connect() {
    this.setupDragAndDrop()
    this.displayExistingImage()
  }

  /**
   * 既存画像がある場合、初期表示
   */
  displayExistingImage() {
    if (this.existingImageUrlValue && this.existingImageUrlValue !== '') {
      // プレビュー画像を表示
      this.previewTarget.src = this.existingImageUrlValue
      this.previewTarget.classList.remove("hidden")

      // プレースホルダーを非表示
      if (this.hasPlaceholderTarget) {
        this.placeholderTarget.classList.add("hidden")
      }

      // 削除ボタンを表示
      if (this.hasRemoveButtonTarget) {
        this.removeButtonTarget.classList.remove("hidden")
      }
    }
  }

  /**
   * ファイル選択時の処理
   */
  preview(event) {
    const file = event.target.files[0]
    if (!file) return

    // バリデーション
    if (!this.validateFile(file)) {
      this.resetInput()
      return
    }

    // プレビュー表示
    this.displayPreview(file)
  }

  /**
   * ファイルのバリデーション
   */
  validateFile(file) {
    // ファイルサイズチェック
    if (file.size > this.constructor.MAX_FILE_SIZE) {
      alert(`ファイルサイズは${this.constructor.MAX_FILE_SIZE / 1024 / 1024}MB以下にしてください`)
      return false
    }

    // ファイル形式チェック
    if (!this.constructor.ALLOWED_TYPES.includes(file.type)) {
      alert("JPEG、PNG、WebP、GIF形式の画像ファイルを選択してください")
      return false
    }

    return true
  }

  /**
   * プレビューを表示
   */
  displayPreview(file) {
    const reader = new FileReader()

    reader.onload = (e) => {
      // プレビュー画像を表示
      this.previewTarget.src = e.target.result
      this.previewTarget.classList.remove("hidden")

      // プレースホルダーを非表示
      if (this.hasPlaceholderTarget) {
        this.placeholderTarget.classList.add("hidden")
      }

      // ファイル情報を表示
      if (this.hasFileNameTarget) {
        this.fileNameTarget.textContent = file.name
        this.fileNameTarget.classList.remove("hidden")
      }

      if (this.hasFileSizeTarget) {
        this.fileSizeTarget.textContent = this.formatFileSize(file.size)
        this.fileSizeTarget.classList.remove("hidden")
      }

      // 削除ボタンを表示
      if (this.hasRemoveButtonTarget) {
        this.removeButtonTarget.classList.remove("hidden")
      }
    }

    reader.readAsDataURL(file)
  }

  /**
   * プレビューを削除
   */
  remove(event) {
    event.preventDefault()

    // input をリセット
    this.resetInput()

    // プレビュー画像を非表示
    this.previewTarget.src = ""
    this.previewTarget.classList.add("hidden")

    // プレースホルダーを表示
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.remove("hidden")
    }

    // ファイル情報を非表示
    if (this.hasFileNameTarget) {
      this.fileNameTarget.classList.add("hidden")
    }

    if (this.hasFileSizeTarget) {
      this.fileSizeTarget.classList.add("hidden")
    }

    // 削除ボタンを非表示
    if (this.hasRemoveButtonTarget) {
      this.removeButtonTarget.classList.add("hidden")
    }
  }

  /**
   * inputをリセット
   */
  resetInput() {
    this.inputTarget.value = ""
  }

  /**
   * ドラッグ&ドロップの設定
   */
  setupDragAndDrop() {
    const dropZone = this.element

    // ドラッグオーバー時
    dropZone.addEventListener("dragover", (e) => {
      e.preventDefault()
      dropZone.classList.add("border-blue-500", "bg-blue-50")
    })

    // ドラッグリーブ時
    dropZone.addEventListener("dragleave", (e) => {
      e.preventDefault()
      dropZone.classList.remove("border-blue-500", "bg-blue-50")
    })

    // ドロップ時
    dropZone.addEventListener("drop", (e) => {
      e.preventDefault()
      dropZone.classList.remove("border-blue-500", "bg-blue-50")

      const file = e.dataTransfer.files[0]
      if (file && this.validateFile(file)) {
        // FileListオブジェクトを作成してinputに設定
        const dataTransfer = new DataTransfer()
        dataTransfer.items.add(file)
        this.inputTarget.files = dataTransfer.files

        this.displayPreview(file)
      }
    })
  }

  /**
   * ファイルサイズをフォーマット
   */
  formatFileSize(bytes) {
    if (bytes === 0) return "0 Bytes"

    const k = 1024
    const sizes = ["Bytes", "KB", "MB", "GB"]
    const i = Math.floor(Math.log(bytes) / Math.log(k))

    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + " " + sizes[i]
  }
}
