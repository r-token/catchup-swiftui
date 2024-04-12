//
//  UpdatesScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/29/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct UpdatesScreen: View {
    var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 10) {
				Group {
					Spacer()
						.frame(height: 10)
					
					Text("New Update")
						.font(.largeTitle)
						.bold()
						.foregroundStyle(.orange)

					Text("Version \(Utils.getCurrentAppVersion())")
						.font(.headline)
						.foregroundStyle(.blue)
					
					Text("Release Notes:")
						.font(.headline)
					
					Divider()
					Spacer()
				}
				
				Group {
                    Text("– New **Quarterly** and **Annually** notification options")

                    Spacer()

                    Text("***From version 3.0***:")
                        .padding(.top)

                    Spacer()

                    Text("– A grid of your next CatchUps")

                    Spacer()

                    Text("– Pull-to-refresh photo & contact information for your selected contacts")

                    Spacer()

                    Text("– Unread indicators for contacts it's time to CatchUp with")

                    Spacer()

					Text("– Automatic cloud syncing with other Apple devices")

					Spacer()

                    Text("– UI redesign")

                    Spacer()
                    
                    Text("– Significant under-the-hood improvements")
				}
                
				Spacer()

                Button {
                    Utils.requestReviewManually()
                } label: {
                    CalloutButtonView(buttonText: "Review on the App Store", buttonColor: .orange)
                }
                .padding(.vertical)
			}
		}
		.padding([.top, .horizontal])
    }
}

#Preview {
    UpdatesScreen()
}
