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
						.frame(height: 45)
					
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
					Text("– iOS 15 compatibility")
					
					Spacer()
					
					Text("– CatchUp now requires iOS 14 or newer")
                    
                    Spacer()
                    
                    Text("– More to come soon!")
				}
                
				Spacer()
			}
		}
		.padding([.top, .horizontal])
    }
}

#Preview {
    UpdatesScreen()
}
