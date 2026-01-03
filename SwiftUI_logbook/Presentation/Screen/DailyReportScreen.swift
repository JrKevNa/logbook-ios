//
//  DailyReportScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 10/12/25.
//

import SwiftUI

struct DailyReportScreen: View {
    @StateObject private var vm = DailyReportViewModel()
    @State private var filterExpanded = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: - Filter Toggle Header
                FilterHeader(filterExpanded: $filterExpanded)

                // MARK: - Collapsible Filter Content
                if filterExpanded {
                    FilterSection(vm: vm)
                        .transition(.opacity)
                }

                Divider()

                // MARK: - Day Navigation (always visible)
                DayNavigation(vm: vm)

                Divider()

                // MARK: - Report List
                ReportListContainer(vm: vm)

                Spacer()
            }
            .navigationTitle("Daily Report")
            .task { await vm.loadInitial() }
            .modifier(FilterWatcher(vm: vm))   // << Monitoring filter changes
        }
    }
}

struct FilterHeader: View {
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

struct FilterSection: View {
    @ObservedObject var vm: DailyReportViewModel

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

struct DayNavigation: View {
    @ObservedObject var vm: DailyReportViewModel

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

struct ReportListContainer: View {
    @ObservedObject var vm: DailyReportViewModel

    var body: some View {
        if vm.isLoading {
            ProgressView().padding()
        } else if let error = vm.errorMessage {
            Text(error)
                .foregroundColor(.red)
                .padding()
        } else {
            ReportListView(reports: vm.reports)
        }
    }
}

struct ReportListView: View {
    let reports: [DailyReport]

    var body: some View {
        List {
            ForEach(reports) { report in
                Section(header: Text(report.date)) {
                    ForEach(report.entries) { entry in
                        EntryRow(entry: entry)
                    }
                }
            }
        }
    }
}

struct EntryRow: View {
    let entry: DailyEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.activity).font(.headline)
            Text("\(entry.durationNumber) \(entry.durationUnit)").font(.subheadline)
            Text(entry.createdBy?.username ?? "Unknown User")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct FilterWatcher: ViewModifier {
    @ObservedObject var vm: DailyReportViewModel

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
