//
//  UserReportScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 12/12/25.
//

import SwiftUI

struct UserReportScreen: View {
    @StateObject private var vm = UserReportViewModel()
    @State private var filterExpanded = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: - Filter Toggle Header
                UserReportFilterHeader(filterExpanded: $filterExpanded)

                // MARK: - Collapsible Filter Content
                if filterExpanded {
                    UserReportFilterSection(vm: vm)
                        .transition(.opacity)
                }

                Divider()

                // MARK: - Day Navigation (always visible)
                UserReportDayNavigation(vm: vm)

                Divider()

                // MARK: - Report List
                UserReportListContainer(vm: vm)

                Spacer()
            }
            .navigationTitle("User Report")
            .task { await vm.loadInitial() }
            .modifier(UserReportFilterWatcher(vm: vm))   // << Monitoring filter changes
        }
    }
}

struct UserReportFilterHeader: View {
    @Binding var filterExpanded: Bool

    var body: some View {
        HStack {
            Text("Filter")
                .font(.headline)

            Spacer()

            Button(action: { filterExpanded.toggle() }) {
                Image(systemName: filterExpanded ? "chevron.up" : "chevron.down")
                    .font(.title3)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }
}

struct UserReportFilterSection: View {
    @ObservedObject var vm: UserReportViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            DatePicker("Start Date", selection: $vm.startDate, displayedComponents: [.date])

            DatePicker("End Date", selection: $vm.endDate, displayedComponents: [.date])

            // User Picker in LabeledContent
            LabeledContent("User") {
                Picker("", selection: $vm.selectedUser) {
                    Text("All Users").tag(Optional<User>(nil))
                    ForEach(vm.users, id: \.id) { user in
                        Text(user.username).tag(Optional(user))
                    }
                }
                .pickerStyle(.menu)
            }

        }
        .padding()
    }
}

struct UserReportDayNavigation: View {
    @ObservedObject var vm: UserReportViewModel

    var body: some View {
        HStack {
            Button(action: { vm.goToPreviousDay() }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Previous Day")
                }
            }

            Spacer()

            Text(vm.formattedDate(vm.startDate))
                .font(.headline)

            Spacer()

            Button(action: { vm.goToNextDay() }) {
                HStack {
                    Text("Next Day")
                    Image(systemName: "chevron.right")
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }
}

struct UserReportListContainer: View {
    @ObservedObject var vm: UserReportViewModel

    var body: some View {
        if vm.isLoading {
            ProgressView().padding()
        } else if let error = vm.errorMessage {
            Text(error)
                .foregroundColor(.red)
                .padding()
        } else {
            UserReportListView(reports: vm.reports)
        }
    }
}

struct UserReportListView: View {
    let reports: [UserReport]

    var body: some View {
        List {
            ForEach(reports) { report in
                Section(header: Text(report.user.username)) {
                    ForEach(report.entries) { entry in
                        UserReportEntryRow(entry: entry)
                    }
                }
            }
        }
    }
}

struct UserReportEntryRow: View {
    let entry: UserEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.activity).font(.headline)
            Text("\(entry.durationNumber) \(entry.durationUnit)").font(.subheadline)
            Text(entry.logDate ?? "")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct UserReportFilterWatcher: ViewModifier {
    @ObservedObject var vm: UserReportViewModel

    func body(content: Content) -> some View {
        content
            .onChange(of: vm.startDate) {
                Task { await vm.loadReport() }
            }
            .onChange(of: vm.endDate) {
                Task { await vm.loadReport() }
            }
            .onChange(of: vm.selectedUser) {
                Task { await vm.loadReport() }
            }
    }
}
