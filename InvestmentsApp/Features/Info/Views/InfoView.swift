//
//  InfoView.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 21.06.2022.
//

import SwiftUI

struct InfoView: View {
    @EnvironmentObject private var viewsRouter: ViewsRouter
    
    let title1 = Array("Investments App")
    let title2 = Array("By Litvak Lev")
    @State var startMoving = false
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack {
                Button {
                    viewsRouter.showMainView()
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(RoundButtonStyle())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()

                Spacer()
                
                Image("InfoImage")
                    .resizable()
                    .scaledToFit()
                    .opacity(startMoving ? 1 : 0)
                    .animation(.linear(duration: 2), value: startMoving)
                
                Spacer()
                
                HStack(spacing: 0) {
                    ForEach(0..<title1.count, id: \.self) { index in
                        Text(String(title1[index]))
                            .offset(x: startMoving ? 0 : -500 + -CGFloat(index * 20))
                            .animation(.spring().delay(Double(title2.count - index - 1) * 0.1), value: startMoving)
                    }
                }
                
                HStack(spacing: 0) {
                    ForEach(0..<title2.count, id: \.self) { index in
                        Text(String(title2[index]))
                            .offset(x: startMoving ? 0 : 500 + CGFloat(index * 20))
                            .animation(.spring().delay(Double(index) * 0.1), value: startMoving)
                    }
                }
                
                Spacer()
                Spacer()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    startMoving = true
                }
            }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
