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
    /// ログアウト
    internal static let logout = L10n.tr("Localizable", "Alert.Logout")
    internal enum Auth {
      /// 認証に失敗しました
      internal static let failure = L10n.tr("Localizable", "Alert.Auth.Failure")
      /// メールアドレスを入力してください
      internal static let inputEmailAddress = L10n.tr("Localizable", "Alert.Auth.InputEmailAddress")
      /// パスワードをリセットする
      internal static let resetPassword = L10n.tr("Localizable", "Alert.Auth.ResetPassword")
    }
    internal enum InvalidLogin {
      /// メールアドレスまたはパスワードが間違っています。
      internal static let message = L10n.tr("Localizable", "Alert.InvalidLogin.Message")
    }
    internal enum Logout {
      /// 本当にログアウトしますか？
      internal static let message = L10n.tr("Localizable", "Alert.Logout.Message")
    }
    internal enum Questionnaire {
      /// アンケートの作成に失敗しました
      internal static let failedToCreate = L10n.tr("Localizable", "Alert.Questionnaire.FailedToCreate")
    }
    internal enum RequestPictureAuth {
      /// 設定変更
      internal static let actionTitle = L10n.tr("Localizable", "Alert.RequestPictureAuth.ActionTitle")
      /// 写真へのアクセスを許可する必要があります。設定を変更してください。
      internal static let subTitle = L10n.tr("Localizable", "Alert.RequestPictureAuth.SubTitle")
      /// 写真へのアクセスを許可
      internal static let title = L10n.tr("Localizable", "Alert.RequestPictureAuth.Title")
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

  internal enum Error {
    /// 不明なエラーが発生しました。
    internal static let unknown = L10n.tr("Localizable", "Error.unknown")
  }

  internal enum Menu {
    /// 会員情報変更
    internal static let changeMemberInfo = L10n.tr("Localizable", "Menu.ChangeMemberInfo")
    /// コミュニティをつくる
    internal static let createCommunity = L10n.tr("Localizable", "Menu.CreateCommunity")
    /// ログアウト
    internal static let logout = L10n.tr("Localizable", "Menu.Logout")
  }

  internal enum Questionnaire {
    internal enum Create {
      internal enum Choice {
        /// 選択肢%d
        internal static func value(_ p1: Int) -> String {
          return L10n.tr("Localizable", "Questionnaire.Create.Choice.value", p1)
        }
      }
    }
    internal enum Detail {
      /// アンケート回答
      internal static let answer = L10n.tr("Localizable", "Questionnaire.Detail.Answer")
      /// アンケート結果
      internal static let result = L10n.tr("Localizable", "Questionnaire.Detail.Result")
    }
  }

  internal enum Sample {
    internal enum Questionnaire {
      internal enum Community {
        /// TresInnovation
        internal static let name = L10n.tr("Localizable", "Sample.Questionnaire.Community.Name")
        /// 従業員満足度の調査
        internal static let title = L10n.tr("Localizable", "Sample.Questionnaire.Community.Title")
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
