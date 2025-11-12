# config gemとZeitwerkの互換性問題を解決
# https://github.com/rubyconfig/config/issues/349
Config.setup do |config|
  # configディレクトリから設定ファイルを読み込む
  config.const_name = "Settings"
end

# Zeitwerkによるメソッドの問題を回避
# Config::Optionsがモジュールのように扱われるのを防ぐ
if defined?(Config::Options)
  Config::Options.class_eval do
    # Zeitwerkがモジュールとして認識しようとするメソッドを無効化
    def autoload?(*args)
      false
    end

    def autoload(*args)
      false
    end

    def const_defined?(*args)
      false
    end

    def constants(*args)
      []
    end

    def name
      nil
    end
  end
end
