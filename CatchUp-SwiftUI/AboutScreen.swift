//
//  AboutScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/19/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct AboutScreen: View {
	@State private var showingUpdateScreen = false
	
	let generator = UINotificationFeedbackGenerator()
	
	let smallTip = IAPService.shared.getSmallTipAmount()
	let mediumTip = IAPService.shared.getMediumTipAmount()
	let largeTip = IAPService.shared.getLargeTipAmount()
	
    var body: some View {
		VStack(alignment: .center, spacing: 15) {
			Spacer()
				.frame(height: 100)
            
            Group {
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
                    
                    Button(smallTip) {
                        self.graciousTipPressed()
                    }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .top, endPoint: .bottom))
                        )
                        .shadow(radius: 15)
                    
                    Spacer()
                    
                    Button(mediumTip) {
                        self.generousTipPressed()
                    }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .top, endPoint: .bottom))
                        )
                        .shadow(radius: 15)
                    
                    Spacer()
                    
                    Button(largeTip) {
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
            
            Group {
                Button(action: {
                    self.showingUpdateScreen = true
                }) {
                    Text("Show Latest Update Details")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
		}
		.padding()
        
        .sheet(isPresented: $showingUpdateScreen) {
            UpdatesScreen()
        }
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
}

struct AboutScreen_Previews: PreviewProvider {
	static var previews: some View {
        AboutScreen()
    }
}
