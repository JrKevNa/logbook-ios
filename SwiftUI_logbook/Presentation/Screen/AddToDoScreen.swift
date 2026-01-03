//
//  AddToDoScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 05/12/25.
//

import SwiftUI

struct AddToDoScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm: AddToDoViewModel
    
    // ✅ Custom initializer for editing
    init(mode: ModalMode = .add, todo: ToDoList? = nil) {
        _vm = StateObject(wrappedValue: AddToDoViewModel(mode: mode, todo: todo))
    }
    
    var body: some View {
        Form {
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
            
            // Show error if present
            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            // Delete button (only if editing existing ToDo)
            if vm.todoToEdit != nil {
                // Only show finish button if it's NOT already done
                if !vm.todoToEdit!.isDone {
                    Button {
                        Task {
                            await vm.finishToDo()
                            dismiss()
                        }
                    } label: {
                        Text("Mark as Finished")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .padding(.vertical, 12)
                }
                
                Button(role: .destructive) {
                    Task {
                        await vm.deleteToDo()
                        dismiss()
                    }
                } label: {
                    Text("Delete To-Do")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(vm.todoToEdit == nil ? "Add To-Do" : "Edit To-Do")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(vm.todoToEdit == nil ? "Add" : "Save") {
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
