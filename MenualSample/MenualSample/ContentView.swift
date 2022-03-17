//
//  ContentView.swift
//  MenualSample
//
//  Created by 정진균 on 2022/03/16.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("안녕하세요")
                .padding()
            Text("하이요")
                .padding()
            Button("하잉하이") {
                print("눌러봐")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
