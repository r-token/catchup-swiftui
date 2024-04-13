//
//  RemoveContactButton.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/30/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct RemoveContactButton: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
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
            Button("Remove", role: .destructive) {
                deleteContactAndDismiss()
            }

            Button("Cancel", role: .cancel) {}
        }
    }

    func deleteContactAndDismiss() {
        NotificationHelper.removeExistingNotifications(for: contact)
        modelContext.delete(contact)
        dismiss()
    }
}

#Preview {
    RemoveContactButton(contact: SelectedContact.sampleData)
}
