//
//  AboutScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/19/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct AboutScreen: View {
	@State private var showingAlert = false
	@Environment(\.presentationMode) var presentationMode
	
	let generator = UINotificationFeedbackGenerator()
	
    var body: some View {
		VStack(alignment: .center, spacing: 15) {
			
			Spacer()
			
			Image("CatchUp")
				.resizable()
				.frame(width: 80, height: 80)
				.clipShape(RoundedRectangle(cornerRadius: 15))
				.shadow(radius: 10)
			
			Text("CatchUp")
				.foregroundColor(.orange)
				.font(.largeTitle)
				.bold()
			
			Text("Made with ❤️ by an independent developer")
				.multilineTextAlignment(.center)
				.padding(.horizontal)
			
			.padding(.bottom)
			
			Divider()
				.frame(height: 1)
				.background(Color.orange)
				.padding(.bottom)
			
			Text("Tip Jar")
				.font(.headline)
			
			Text("CatchUp is free with no ads. If you find it useful, please consider supporting development by leaving a tip.")
				.multilineTextAlignment(.center)
			
			.padding(.bottom)
			
			HStack {
				
				Spacer()
				
				Button("$0.99") {
					self.graciousTipPressed()
				}
					.font(.headline)
					.foregroundColor(.white)
					.padding()
					.background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .top, endPoint: .bottom))
					)
					.shadow(radius: 15)
				
				Spacer()
				
				Button("$1.99") {
					self.generousTipPressed()
				}
					.font(.headline)
					.foregroundColor(.white)
					.padding()
					.background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .top, endPoint: .bottom))
					)
					.shadow(radius: 15)
				
				Spacer()
				
				Button("$4.99") {
					self.gratuitousTipPressed()
				}
					.font(.headline)
					.foregroundColor(.white)
					.padding()
					.background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .top, endPoint: .bottom))
					)
					.shadow(radius: 15)
				
				Spacer()
			}
			
			.padding(.bottom)
			.padding(.bottom)
			
			Divider()
				.frame(height: 1)
				.background(Color.orange)
			
			Spacer()
		}
		.padding()
		.onAppear(perform: fetchAvailableIAPs)
    }
	
	func graciousTipPressed() {
		generator.notificationOccurred(.success)
		IAPService.shared.leaveATip(index: 1)
    }
	
	func generousTipPressed() {
		generator.notificationOccurred(.success)
		IAPService.shared.leaveATip(index: 0)
    }
	
	func gratuitousTipPressed() {
		generator.notificationOccurred(.success)
		IAPService.shared.leaveATip(index: 2)
    }
	
	func fetchAvailableIAPs() {
		IAPService.shared.fetchAvailableProducts()
	}
}

struct AboutScreen_Previews: PreviewProvider {
	@Environment(\.presentationMode) var presentationMode
	
    static var previews: some View {
        AboutScreen()
    }
}
