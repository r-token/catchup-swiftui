//
//  SKProduct+localizedPrice.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 7/20/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import StoreKit

extension SKProduct {
	var localizedPrice: String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.locale = priceLocale
		return formatter.string(from: price)!
	}
}
