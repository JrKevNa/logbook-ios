//
//  ProfileScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 15/12/25.
//

import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm: ProfileViewModel

    init(appState: AppState) {
        _vm = StateObject(wrappedValue: ProfileViewModel(appState: appState))
    }
    
    var body: some View {
        Form {
            Section("Profile") {
                // Editable username
                TextField("Username", text: $vm.username)
                    .autocapitalization(.none)

                // Read-only fields
                if let user = appState.currentUser {
                    LabeledContent("Email") {
                        Text(user.email ?? "")
                    }
                    LabeledContent("Role") {
                        Text(user.userRoles?.first?.role.name ?? "Unknown")
                    }
                    LabeledContent("Company") {
                        Text(user.company?.name ?? "Unknown")
                    }
                }
            }

            Section {
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    Task { await vm.saveUsername() }
                }) {
                    if vm.isLoading {
                        HStack {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(vm.isLoading)
                .alert("Profile Updated", isPresented: $vm.showSuccessAlert) {
                    Button("OK", role: .cancel) { }
                }
            }
            
            Section("Change Password") {

                SecureField("Enter your old Password", text: $vm.oldPassword)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Enter your new Password", text: $vm.newPassword)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Confirm your new Password", text: $vm.confirmPassword)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)

            }
            
            Section {
                if let error = vm.errorMessageForPassword {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    Task { await vm.updatePassword() }
                }) {
                    if vm.isLoading {
                        HStack {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Text("Update Password")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(vm.isLoading)
                .alert("Password Updated", isPresented: $vm.showSuccessAlert) {
                    Button("OK", role: .cancel) { }
                }
            }
            
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveUsername() {
        // Update username in appState
        // appState.currentUser?.username = username

        // TODO: Call API to persist username change if needed
    }
}
