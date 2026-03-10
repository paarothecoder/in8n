import SwiftUI

struct HomeView: View {
    let username: String
    @Binding var hasToken: Bool
 
    var body: some View {
        ZStack {
            // Background gradient matching the theme
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.12), Color(red: 0.02, green: 0.02, blue: 0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle subtle accent glow
            Circle()
                .fill(Color.purple.opacity(0.1))
                .frame(width: 400, height: 400)
                .blur(radius: 120)
                .offset(x: -150, y: -250)
            
            VStack {
                // Header Profile Area
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome Back,")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(username)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.purple)
                        .background(Circle().fill(.white.opacity(0.1)))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Welcome Card
                VStack(spacing: 24) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundColor(.purple)
                        .padding()
                        .background(Circle().fill(Color.purple.opacity(0.2)))
                    
                    Text("Ready to orchestrate your tasks?")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Head over to the Workflow tab to visually design and run your operations.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        
                    Button(action: {
                        Auth.logout()
                        withAnimation {
                            hasToken = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("Logout")
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.red.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.top, 10)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 15)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

