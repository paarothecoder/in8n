import Foundation

class UserRequest {
    
    enum RequestError: Error {
        case invalidURL
        case invalidResponse
        case serverError(Int)
    }
    
    static func reqwest(what: String, method: String, auth: String, data: String? = nil) async throws -> Data {
        
        let urlString = "\(const.url)\(what)/"
        print("URL:", urlString)
        
        guard let url = URL(string: urlString) else {
            throw RequestError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(auth)", forHTTPHeaderField: "Authorization")
        
        // Only attach body for non-GET requests
        if method != "GET", let data = data {
            let body: [String: Any] = [
                "data": data
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RequestError.invalidResponse
        }
        
        print("Status:", httpResponse.statusCode)
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print(String(data: responseData, encoding: .utf8) ?? "")
            throw RequestError.serverError(httpResponse.statusCode)
        }
        
        return responseData
    }
}
