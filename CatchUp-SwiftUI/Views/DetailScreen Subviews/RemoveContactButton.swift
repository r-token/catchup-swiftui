//
//  RemoveContactButton.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/30/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct RemoveContactButton: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingDeleteContactAlert = false
    @Bindable var contact: SelectedContact

    var body: some View {
        Button {
            isShowingDeleteContactAlert = true
        } label: {
            CalloutButtonView(buttonText: "Remove \(contact.name)", buttonColor: .red)
        }
        .listRowBackground(Color.clear)
        .alert("Remove \(contact.name)?", isPresented: $isShowingDeleteContactAlert) {
            Button("Remove", role: .destructive, action: deleteContactAndDismiss)
            Button("Cancel", role: .cancel) {}
        }
    }

    private func deleteContactAndDismiss() {
        // Await the purge so iOS has cancelled every scheduled request for this
        // contact before SwiftData deletes the row — otherwise the row is gone
        // by the time we'd retry, and the orphan would persist until the next
        // cold-launch reconciliation.
        Task { @MainActor in
            await NotificationHelper.removeExistingNotifications(for: contact)
            modelContext.delete(contact)
            dismiss()
        }
    }
}

#Preview {
    RemoveContactButton(contact: .sampleData)
}
