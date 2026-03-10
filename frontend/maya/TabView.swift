import SwiftUI

struct UserDetails: Codable {
    let username: String
}

struct MainTabView: View {
    @Binding var hasToken: Bool
    @State private var username: String = "Loading..." // Good to have a placeholder

    var body: some View {
        TabView {
            HomeView(username: username, hasToken: $hasToken)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            WorkflowView()
                .tabItem {
                    Label("Workflow", systemImage: "point.3.connected.trianglepath.dotted")
                }
        }
        .accentColor(.purple) // Update accent color to match new design system
        .preferredColorScheme(.dark)
        .task {
            await loadUser()
        }
    }

    // Notice the 'async' keyword here
    func loadUser() async {
        guard let token = Auth.getToken() else { return }

        do {
            // Using the async version of your API
            let data = try await UserRequest.reqwest(
                what: "user/details",
                method: "GET",
                auth: token
            )
            
            let user = try JSONDecoder().decode(UserDetails.self, from: data)
            
            // No need for DispatchQueue.main.async!
            // SwiftUI updates the UI safely here.
            self.username = user.username
            
        } catch {
            print("Failed to load user: \(error)")
            // Maybe set username to "Guest" or show an alert here
        }
    }
}

