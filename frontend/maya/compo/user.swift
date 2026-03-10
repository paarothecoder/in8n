import Foundation

struct LoginResponse: Codable {
    let refresh: String
    let access: String
}

class UserAPI {

    static func user(type: String, name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {

        var body: [String: Any]
        var endpoint = ""

        if type == "Login" {
            body = [
                "email": email,
                "password": password
            ]
            endpoint = "user/login"
        } else {
            body = [
                "name": name,
                "email": email,
                "password": password
            ]
            endpoint = "user/register"
        }

        let urlString = "\(const.url)\(endpoint)/"

        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("Error:", error)
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            print(String(data: data, encoding: .utf8) ?? "")

            if type == "Login" {
                do {
                    let result = try JSONDecoder().decode(LoginResponse.self, from: data)

                    // Save token
                    Auth.saveToken(result.access)
                    print("save is done baby girl \(result.access)")

                    DispatchQueue.main.async {
                        completion(true)
                    }

                } catch {
                    print("Decode error:", error)
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }

            } else {
                DispatchQueue.main.async {
                    completion(true)
                }
            }

        }.resume()
    }
}
