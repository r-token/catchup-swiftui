//
//  AboutScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/19/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct AboutScreen: View {
	@State private var isShowingUpdateScreen = false

	let smallTip = IAPService.shared.getSmallTipAmount()
	let mediumTip = IAPService.shared.getMediumTipAmount()
	let largeTip = IAPService.shared.getLargeTipAmount()
	
    var body: some View {
		ScrollView {
            VStack(alignment: .center, spacing: 15) {
                Spacer()
                    .frame(height: 75)

                Group {
                    Image("CatchUp")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 10)

                    Text("CatchUp")
                        .foregroundStyle(.orange)
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

                    Text("CatchUp is free with no ads. If you find it useful, please consider supporting development by leaving a tip or review.")
                        .multilineTextAlignment(.center)
                        .padding(.bottom)

                    HStack {
                        Spacer()

                        Button(smallTip) {
                            tappedSmallTip()
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .top, endPoint: .bottom))
                        )
                        .shadow(radius: 15)

                        Spacer()

                        Button(mediumTip) {
                            tappedMediumTip()
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .top, endPoint: .bottom))
                        )
                        .shadow(radius: 15)

                        Spacer()

                        Button(largeTip) {
                            tappedLargeTip()
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .top, endPoint: .bottom))
                        )
                        .shadow(radius: 15)

                        Spacer()
                    }
                    .padding(.bottom, 20)

                    Divider()
                        .frame(height: 1)
                        .background(Color.orange)

                    Button {
                        Utils.requestReviewManually()
                    } label: {
                        CalloutButtonView(buttonText: "Review on the App Store", buttonColor: .orange)
                    }
                    .padding(.vertical)
                }

                Button {
                    isShowingUpdateScreen = true
                } label: {
                    Text("Show Latest Update Details")
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
                .padding(.bottom)
            }
        }
        .padding(.horizontal)

        .sheet(isPresented: $isShowingUpdateScreen) {
            UpdatesScreen()
        }
    }

    @MainActor
    func tappedSmallTip() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        IAPService.shared.leaveATip(index: 0)
    }

    @MainActor
	func tappedMediumTip() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
		IAPService.shared.leaveATip(index: 1)
    }
	
    @MainActor
	func tappedLargeTip() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
		IAPService.shared.leaveATip(index: 2)
    }
}

#Preview {
    AboutScreen()
}
