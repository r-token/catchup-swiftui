//
//  ContentView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 6/26/19.
//  Copyright © 2019 Token Solutions. All rights reserved.
//

import SwiftUI

let contactUtility = Contacts()

struct Home : View {
    var body: some View {

        NavigationView {
            VStack {
                List {
                    HomeCell()
                    HomeCell()
                    HomeCell()
                }
                
                Button(action: {
                    contactUtility.verifyAccessToContactsDatabase()
                }) {
                    Text("Add Contacts")
                        .font(.headline)
                        .padding()
                }
                .navigationBarTitle(Text("CatchUp"), displayMode: .large)
            }
        }
    }
}

#if DEBUG
struct Home_Previews : PreviewProvider {
    static var previews: some View {
        Home()
    }
}
#endif
