// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum ChangeMemberInfo: StoryboardType {
    internal static let storyboardName = "ChangeMemberInfo"

    internal static let initialScene = InitialSceneType<RealtimeQuestionnaire.ChangeMemberInfoViewController>(storyboard: ChangeMemberInfo.self)
  }
  internal enum CreateCommunity: StoryboardType {
    internal static let storyboardName = "CreateCommunity"

    internal static let initialScene = InitialSceneType<RealtimeQuestionnaire.CreateCommunityViewController>(storyboard: CreateCommunity.self)
  }
  internal enum CreateQuestionnaire: StoryboardType {
    internal static let storyboardName = "CreateQuestionnaire"

    internal static let initialScene = InitialSceneType<RealtimeQuestionnaire.CreateQuestionnaireViewController>(storyboard: CreateQuestionnaire.self)
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum Login: StoryboardType {
    internal static let storyboardName = "Login"

    internal static let initialScene = InitialSceneType<RealtimeQuestionnaire.LoginViewController>(storyboard: Login.self)

    internal static let login = SceneType<RealtimeQuestionnaire.LoginViewController>(storyboard: Login.self, identifier: "Login")
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Main.self)

    internal static let mainViewController = SceneType<RealtimeQuestionnaire.MainViewController>(storyboard: Main.self, identifier: "MainViewController")
  }
  internal enum Menu: StoryboardType {
    internal static let storyboardName = "Menu"

    internal static let initialScene = InitialSceneType<RealtimeQuestionnaire.MenuViewController>(storyboard: Menu.self)

    internal static let menuViewController = SceneType<RealtimeQuestionnaire.MenuViewController>(storyboard: Menu.self, identifier: "MenuViewController")
  }
  internal enum QuestionnaireDetail: StoryboardType {
    internal static let storyboardName = "QuestionnaireDetail"

    internal static let initialScene = InitialSceneType<RealtimeQuestionnaire.QuestionnaireDetailContainerViewController>(storyboard: QuestionnaireDetail.self)

    internal static let answerQuestionnaireViewController = SceneType<RealtimeQuestionnaire.AnswerQuestionnaireViewController>(storyboard: QuestionnaireDetail.self, identifier: "AnswerQuestionnaireViewController")

    internal static let questionnaireResultViewController = SceneType<RealtimeQuestionnaire.QuestionnaireResultViewController>(storyboard: QuestionnaireDetail.self, identifier: "QuestionnaireResultViewController")
  }
  internal enum Register: StoryboardType {
    internal static let storyboardName = "Register"

    internal static let initialScene = InitialSceneType<RealtimeQuestionnaire.RegisterViewController>(storyboard: Register.self)
  }
  internal enum Search: StoryboardType {
    internal static let storyboardName = "Search"

    internal static let initialScene = InitialSceneType<RealtimeQuestionnaire.SearchViewController>(storyboard: Search.self)
  }
  internal enum SearchCommunity: StoryboardType {
    internal static let storyboardName = "SearchCommunity"

    internal static let initialScene = InitialSceneType<RealtimeQuestionnaire.SearchCommunityViewController>(storyboard: SearchCommunity.self)
  }
  internal enum SearchUser: StoryboardType {
    internal static let storyboardName = "SearchUser"

    internal static let initialScene = InitialSceneType<RealtimeQuestionnaire.SearchUserViewController>(storyboard: SearchUser.self)
  }
  internal enum Splash: StoryboardType {
    internal static let storyboardName = "Splash"

    internal static let initialScene = InitialSceneType<RealtimeQuestionnaire.SplashViewController>(storyboard: Splash.self)
  }
  internal enum TrimImage: StoryboardType {
    internal static let storyboardName = "TrimImage"

    internal static let initialScene = InitialSceneType<RealtimeQuestionnaire.TrimImageViewController>(storyboard: TrimImage.self)

    internal static let trimImageViewController = SceneType<RealtimeQuestionnaire.TrimImageViewController>(storyboard: TrimImage.self, identifier: "TrimImageViewController")
  }
  internal enum UnansweredQuestionnaireList: StoryboardType {
    internal static let storyboardName = "UnansweredQuestionnaireList"

    internal static let initialScene = InitialSceneType<RealtimeQuestionnaire.UnansweredQuestionnaireListViewController>(storyboard: UnansweredQuestionnaireList.self)
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

private final class BundleToken {}
