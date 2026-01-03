//
//  LoginScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//
import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm: LoginViewModel
    @State private var showRegister = false

    init(appState: AppState) {
        _vm = StateObject(wrappedValue: LoginViewModel(appState: appState))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .bold()

                TextField("Email", text: $vm.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Password", text: $vm.password)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)

                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: {
                    Task { await vm.login() }
                }) {
                    if vm.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Login")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Spacer()

                HStack {
                    Text("Don't have an account?")
                    Button("Register") {
                        showRegister = true
                    }
                }
                .font(.footnote)
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterScreen()
            }
            .padding()
        }
    }
}
