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
            HStack {
                Spacer()

                Text("Remove \(contact.name)")

                Spacer()
            }
            .fontWeight(.semibold)
            .padding(.vertical, 12)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .fill(.red)
            )
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
