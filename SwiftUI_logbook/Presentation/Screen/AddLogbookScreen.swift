//
//  AddLogbookScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 03/12/25.
//
import SwiftUI

struct AddLogbookScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm: AddLogbookViewModel
    
    // ✅ Custom initializer
    init(mode: ModalMode = .add, logbook: Logbook? = nil) {
        _vm = StateObject(wrappedValue: AddLogbookViewModel(mode: mode, logbook: logbook))
    }
    
    var body: some View {
        Form {
            DatePicker("Log Date", selection: $vm.logDate, displayedComponents: .date)
            Stepper("Duration: \(vm.durationNumber) \(vm.durationUnit)",
                    value: $vm.durationNumber, in: 0...1000)
            Picker("Unit", selection: $vm.durationUnit) {
                Text("minutes").tag("minutes")
                Text("hours").tag("hours")
                Text("days").tag("days")
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Activity")
                    .font(.headline)

                TextEditor(text: $vm.activity)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
            }
            .padding(.vertical, 12)
            
            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            // Delete button
            if vm.logbookToEdit != nil {
                Button(role: .destructive) {
                    Task {
                        await vm.deleteLogbook()
                        dismiss()
                    }
                } label: {
                    Text("Delete Logbook")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(vm.logbookToEdit == nil ? "Add Logbook" : "Edit Logbook")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(vm.logbookToEdit == nil ? "Add" : "Save") {
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
