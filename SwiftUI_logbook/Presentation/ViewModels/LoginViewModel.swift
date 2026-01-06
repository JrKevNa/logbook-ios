//
//  LoginViewModel.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//
import GoogleSignIn
import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var user: User?

    private var appState: AppState   // <- reference the shared instance

    init(appState: AppState) {
        self.appState = appState
    }

    func login() async {
        isLoading = true
        errorMessage = nil
        do {
            let loggedInUser = try await APIService.shared.login(email: email, password: password)
            self.user = loggedInUser
            appState.currentUser = loggedInUser   // update shared app state
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
//    func loginWithGoogle() async {
//        print("login with google")
//        
//        if let rootViewController = getRootViewController() {
//            GIDSignIn.sharedInstance.signIn(
//                withPresenting: rootViewController
//            ) { result, error in
//                guard let result else {
//                    print("error: \(String(describing: error))")
//                    return
//                }
//                    
//                // do soemthing with the result
//                print(result.user.profile?.email)
//                print(result.user.idToken?.tokenString)
//            }
//        }
//    }

    func loginWithGoogle() async {
        isLoading = true
        errorMessage = nil

        guard let rootVC = getRootViewController() else {
            errorMessage = "Unable to start Google login"
            isLoading = false
            return
        }

        do {
            let idToken: String = try await withCheckedThrowingContinuation { continuation in
                GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let token = result?.user.idToken?.tokenString else {
                        continuation.resume(throwing: NSError(
                            domain: "",
                            code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Missing Google ID token"]
                        ))
                        return
                    }

                    continuation.resume(returning: token)
                }
            }

            let loggedInUser = try await APIService.shared.loginWithGoogle(idToken: idToken)
            self.user = loggedInUser
            appState.currentUser = loggedInUser

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as?
            UIWindowScene,
                let rootViewController = scene.windows.first?.rootViewController else {
            return nil
        }
        return getVisibleViewController(from: rootViewController)
    }
    
    private func getVisibleViewController(from vc: UIViewController) ->
        UIViewController? {
            if let navigationController = vc as? UINavigationController {
                return getVisibleViewController(from: navigationController.visibleViewController!)
            }
            if let tabBarController = vc as? UITabBarController {
                return getVisibleViewController(from: tabBarController.selectedViewController!)
            }
            if let presentedViewController = vc.presentedViewController {
                return getVisibleViewController(from: presentedViewController)
            }
        return vc
    }
}


