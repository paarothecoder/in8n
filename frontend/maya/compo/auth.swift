import Foundation

class Auth {

private static let tokenKey = "accessToken"

static func saveToken(_ token: String) {
    UserDefaults.standard.set(token, forKey: tokenKey)
}

static func getToken() -> String? {
    return UserDefaults.standard.string(forKey: tokenKey)
}

static func logout() {
    UserDefaults.standard.removeObject(forKey: tokenKey)
}

}

