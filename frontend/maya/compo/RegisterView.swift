import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            LoginView()
        } else {
            registerViewContent
        }
    }
    
    var registerViewContent: some View {
        NavigationStack {
            ZStack {
                // Sophisticated dark gradient
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.05, blue: 0.12), Color(red: 0.02, green: 0.02, blue: 0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Add a subtle accent glow
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 100)
                    .offset(x: 100, y: -200)
                    
                ScrollView(showsIndicators: false) {
                    VStack {
                        Spacer(minLength: 40)
                        
                        Image("maya")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .shadow(color: .purple.opacity(0.2), radius: 30, x: 0, y: 10)
                            .padding(.bottom, 10)
                        
                        VStack(spacing: 8) {
                            Text("Create Account")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Join us and start your journey.")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.bottom, 30)
                        
                        VStack(spacing: 20) {
                            CustomTextField(
                                icon: "person.fill",
                                placeholder: "Full Name",
                                text: $name
                            )
                            
                            CustomTextField(
                                icon: "envelope.fill",
                                placeholder: "Email Address",
                                text: $email
                            )
                            
                            CustomSecureField(
                                icon: "lock.fill",
                                placeholder: "Password",
                                text: $password
                            )
                            
                            Button(action: {
                                UserAPI.user(type: "register", name: name, email: email, password: password) { success in
                                    if success {
                                        withAnimation {
                                            isLoggedIn = true
                                        }
                                    }
                                }
                            }) {
                                Text("Sign Up")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                            .padding(.top, 10)
                            
                            HStack(spacing: 6) {
                                Text("Already have an account?")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                
                                NavigationLink(destination: LoginView()) {
                                    Text("Log In")
                                        .foregroundColor(.purple)
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                }
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
                        
                        Spacer(minLength: 40)
                    }
                }
            }
        }
    }
    
    struct CustomTextField: View {
        var icon: String
        var placeholder: String
        @Binding var text: String
        
        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20)
                
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.4)))
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }
            .padding()
            .background(Color.white.opacity(0.08))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    struct CustomSecureField: View {
        var icon: String
        var placeholder: String
        @Binding var text: String

        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20)

                SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.4)))
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }
            .padding()
            .background(Color.white.opacity(0.08))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    RegisterView()
}

