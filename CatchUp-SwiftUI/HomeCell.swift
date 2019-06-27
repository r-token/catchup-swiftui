//
//  HomeCell.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 6/26/19.
//  Copyright © 2019 Token Solutions. All rights reserved.
//

import SwiftUI

struct HomeCell: View {
    var body: some View {
        Text("Ryan Token")
    }
}

#if DEBUG
struct HomeCell_Previews : PreviewProvider {
    static var previews: some View {
        HomeCell()
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
#endif
