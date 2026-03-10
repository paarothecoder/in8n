import SwiftUI

struct ContentView: View {

    @State private var showSplash = true
    @State private var hasToken = Auth.getToken() != nil

    var body: some View {

        if hasToken {
            MainTabView(hasToken: $hasToken)
        } else {

            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            showSplash = false
                        }
                    }
            } else {
                RegisterView()
            }
        }
    }
}
