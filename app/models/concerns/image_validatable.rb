module ImageValidatable
  extend ActiveSupport::Concern

  class_methods do
    # 画像添付ファイルのバリデーションを設定
    def validates_image_attachment(attribute, max_size:, allowed_types:)
      validate do
        validate_image_attachment(attribute, max_size, allowed_types)
      end
    end
  end

  private

  def validate_image_attachment(attribute, max_size, allowed_types)
    attachment = send(attribute)
    return unless attachment.attached?

    # ファイルサイズのバリデーション
    unless attachment.byte_size <= max_size.megabytes
      errors.add(attribute, "は#{max_size}MB以下にしてください")
    end

    # ファイル形式のバリデーション
    unless allowed_types.include?(attachment.content_type)
      format_names = allowed_types.map { |type| type.split("/").last.upcase }.join("、")
      errors.add(attribute, "は#{format_names}形式で登録してください")
    end
  end
end
