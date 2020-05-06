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
                    Spacer()
                    Spacer()
                    
                    Text("New Update")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.orange)
                    
                    HStack(spacing: 0) {
                        Text("Version \(helper.getCurrentAppVersion())")
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                    
                    
                    Text("This is a big update. Here's what's new:")
                }
                
                Divider()
                
                Group {
                    Spacer()
                    
                    Text("TL;DR")
                        .font(.headline)
                    
                    Text("– This update brings CatchUp into the modern era of iOS development, but you'll have to set up all of your contacts and reminders again.")
                    
                    Spacer()
                    
                    Text("Complete Rewrite")
                        .font(.headline)
                    
                    Text("– CatchUp has been rebuilt from scratch with Apple's latest technologies. To celebrate the rewrite, we've given it a new icon as well.")
                    
                    Spacer()
                    
                    Text("Dark Mode Support")
                        .font(.headline)
                    
                    Text("– CatchUp now fully supports both light and dark mode, and will change automatically based on your system setting.")
                    
                    Spacer()
                }
                
                Group {
                    Text("All-New Back End")
                        .font(.headline)
                    
                    Text("– This is a significant upgrade to our back end, but unfortunately will force you to have to set your contacts and reminders again.")
                    
                    Spacer()
                    
                    Text("Redesigned Screens")
                        .font(.headline)
                    
                    Text("– Every screen in CatchUp has been updated and polished for a fresh new look that's still familiar.")
                    
                    Spacer()
                    
                    Text("This update also includes major performance improvements and cleans up a lot of unnecessary code.")
                    
                }
                Spacer()
            }
        }
        .padding(15)
    }
}

struct UpdatesScreen_Previews: PreviewProvider {
    @Environment(\.presentationMode) var presentationMode
    
    static var previews: some View {
        UpdatesScreen()
    }
}
