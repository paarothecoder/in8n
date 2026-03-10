import SwiftUI

struct SplashView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Elegant dark gradient background
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.1), Color(red: 0.1, green: 0.05, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            AsyncImage(url: URL(string: const.kajo)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        .shadow(color: Color.purple.opacity(0.3), radius: 20, x: 0, y: 10)
                        .scaleEffect(animate ? 1.05 : 0.95)
                        .opacity(animate ? 1 : 0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                animate = true
                            }
                        }
                case .failure(_):
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.5))
                case .empty:
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 200, height: 200)
        }
    }
}

