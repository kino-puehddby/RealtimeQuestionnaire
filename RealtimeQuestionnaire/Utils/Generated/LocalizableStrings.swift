// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Alert {
    /// メールアドレスまたはパスワードが間違っています。
    internal static let invalidLoginInfo = L10n.tr("Localizable", "Alert.InvalidLoginInfo")
    internal enum Auth {
      /// 認証に失敗しました
      internal static let failure = L10n.tr("Localizable", "Alert.Auth.Failure")
    }
  }

  internal enum Common {
    /// キャンセル
    internal static let cancel = L10n.tr("Localizable", "Common.Cancel")
    /// 完了
    internal static let done = L10n.tr("Localizable", "Common.Done")
    /// OK
    internal static let ok = L10n.tr("Localizable", "Common.Ok")
    /// リトライ
    internal static let retry = L10n.tr("Localizable", "Common.Retry")
    internal enum Close {
      /// CLOSE
      internal static let en = L10n.tr("Localizable", "Common.Close.en")
      /// 閉じる
      internal static let ja = L10n.tr("Localizable", "Common.Close.ja")
    }
    internal enum Count {
      /// %@件
      internal static func value(_ p1: String) -> String {
        return L10n.tr("Localizable", "Common.Count.value", p1)
      }
    }
    internal enum Price {
      /// ¥%@
      internal static func value(_ p1: String) -> String {
        return L10n.tr("Localizable", "Common.Price.value", p1)
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
