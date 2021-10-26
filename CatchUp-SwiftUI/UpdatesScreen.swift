//
//  UpdatesScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/29/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct UpdatesScreen: View {
    let helper = GeneralHelpers()
    
    var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 10) {
				Group {
					
					Spacer()
						.frame(height: 45)
					
					Text("New Update")
						.font(.largeTitle)
						.bold()
						.foregroundColor(.orange)
					
					Text("Version \(helper.getCurrentAppVersion())")
						.font(.headline)
						.foregroundColor(.blue)

					
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

struct UpdatesScreen_Previews: PreviewProvider {
    @Environment(\.presentationMode) var presentationMode
    
    static var previews: some View {
        UpdatesScreen()
    }
}
