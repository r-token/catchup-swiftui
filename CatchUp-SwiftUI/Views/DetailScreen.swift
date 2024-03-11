//
//  DetailScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct DetailScreen: View {
	@State private var isShowingPreferenceScreen = false
    
    @Bindable var contact: SelectedContact

    var body: some View {
		VStack {
			GradientView()
				.edgesIgnoringSafeArea(.top)
				.frame(height: 75)
			
            ContactPhoto(image: Converter.getContactPicture(from: contact.picture))
				.offset(x: 0, y: -130)
				.padding(.bottom, -130)
			
			NamePreferenceChangeStack(contact: contact, isShowingPreferenceScreen: $isShowingPreferenceScreen)

			ContactInfoListView(contact: contact)
		}
        .onAppear(perform: Utils.clearNotificationBadge)
    }
}
