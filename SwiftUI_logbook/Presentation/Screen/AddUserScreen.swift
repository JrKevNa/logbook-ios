//
//  AddUserScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 16/12/25.
//

import SwiftUI

struct AddUserScreen: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = AddUserViewModel()
    
    // ✅ Custom initializer
    init(mode: ModalMode = .add, user: User? = nil) {
        _vm = StateObject(wrappedValue: AddUserViewModel(mode: mode, user: user))
    }
    
    var body: some View {
        Form {
            if appState.currentUser?.isAdmin == true {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Username")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter username", text: $vm.username)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("NIK")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter NIK", text: $vm.nik)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.vertical, 8)
                
                Picker("Role", selection: $vm.selectedRole) {
                    Text("None").tag(Optional<Role>(nil))   // No role selected
                    
                    ForEach(vm.roles, id: \.id) { role in
                        Text(role.name).tag(Optional(role))  // Wrap each role in Optional
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter Email", text: $vm.email)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.vertical, 8)
                
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Password")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    SecureField("Enter Password", text: $vm.password)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.vertical, 8)
                
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Confirm Password")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    SecureField("Confirm Password", text: $vm.confirmPassword)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.vertical, 8)
                
                // Show error if present
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            } else {
                Text("You do not have permission to access this page.")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(vm.userToEdit == nil ? "Add User" : "Edit User")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(vm.userToEdit == nil ? "Add" : "Save") {
                    Task {
                        let success = await vm.save()
                        if success {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
