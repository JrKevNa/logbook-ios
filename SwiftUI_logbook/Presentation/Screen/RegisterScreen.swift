//
//  RegisterScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//

import SwiftUI

struct RegisterScreen: View {
    @StateObject var vm = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // public initializer
//    init(vm: RegisterViewModel = RegisterViewModel()) {
//        _vm = StateObject(wrappedValue: vm)
//    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Register")
                .font(.largeTitle)
                .bold()

            // Company section
            VStack(alignment: .leading, spacing: 8) {
                Text("Company")
                    .font(.headline)
                TextField("Company Name", text: $vm.companyName)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
            }

            Divider() // <-- visual separation line

            // User credentials section
            VStack(alignment: .leading, spacing: 8) {
                Text("User Information")
                    .font(.headline)

                TextField("Username", text: $vm.username)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)

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

                SecureField("Confirm Password", text: $vm.confirmPassword)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
            }

            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: {
                Task { await vm.register() }
            }) {
                if vm.isLoading {
                    ProgressView()
                } else {
                    Text("Register")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            Spacer()
        }
        .padding()
        .alert(isPresented: $vm.showAlert) {
            Alert(
                title: Text("Success"),
                message: Text(vm.alertMessage),
                dismissButton: .default(Text("OK")) {
                    dismiss()  // <- Environment dismiss
                }
            )
        }
    }
}
