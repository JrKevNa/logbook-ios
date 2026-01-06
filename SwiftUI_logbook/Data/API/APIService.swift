//
//  APIService.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//

import Foundation
import KeychainAccess

class APIService {
    static let shared = APIService()
    var accessToken: String?
    var refreshToken: String?
    public let baseURL = "http://127.0.0.1:3001" // adjust for your backend
    
    // Use a session that does NOT send cookies automatically
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.httpCookieAcceptPolicy = .never
        config.httpShouldSetCookies = false
        self.session = URLSession(configuration: config)
    }

    func debugPrintRequest(_ request: URLRequest) {
        print("──────── REQUEST DEBUG ────────")
        print("URL: \(request.url?.absoluteString ?? "nil")")
        print("Method: \(request.httpMethod ?? "nil")")

        if let headers = request.allHTTPHeaderFields {
            print("Headers:")
            for (key, value) in headers {
                print("  \(key): \(value)")
            }
        } else {
            print("Headers: none")
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body:")
            print(bodyString)
        } else {
            print("Body: none")
        }

        print("────────────────────────────────")
    }
    
    enum APIError: Error, LocalizedError {
        case invalidResponse
        case unauthorized
        case noData
        case decodingFailed
        case unknown

        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Invalid server response."
            case .unauthorized:
                return "Unauthorized. Please log in again."
            case .noData:
                return "No data received from server."
            case .decodingFailed:
                return "Failed to decode response."
            case .unknown:
                return "An unknown error occurred."
            }
        }
    }
    
    // MARK: - Request with auth
    func requestWithAuth(_ request: URLRequest) async throws -> Data {
        // debugPrintRequest(request)
        
        // 1️⃣ Perform request normally
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 401 {
            return data
        }

        print("⚠️ 401 received → refreshing token…")

        // Print HTTP status code
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP status code:", httpResponse.statusCode)
        }

        // Print raw response body as string
        if let bodyString = String(data: data, encoding: .utf8) {
            print("Response body:", bodyString)
        }
        
        // 2️⃣ Try refresh token
        guard let refreshToken = self.refreshToken else {
            throw URLError(.userAuthenticationRequired)
        }

        let newAccess = try await self.refreshToken(refreshToken: refreshToken)
        // self.accessToken = newAccess

        print("🔄 Retry request with new access token")

        // 3️⃣ Retry original request with updated Authorization header
        var retryRequest = request
        retryRequest.setValue("Bearer \(newAccess)", forHTTPHeaderField: "Authorization")

        // debugPrintRequest(retryRequest)
        
        let (retryData, retryResponse) = try await URLSession.shared.data(for: retryRequest)

        // Print HTTP status code
        if let httpResponse = retryResponse as? HTTPURLResponse {
            print("HTTP status code:", httpResponse.statusCode)
        }

        // Print raw response body as string
        if let bodyString = String(data: retryData, encoding: .utf8) {
            print("Response body:", bodyString)
        }
        
        
        guard let retryHttp = retryResponse as? HTTPURLResponse,
              (200...299).contains(retryHttp.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return retryData
    }
    
    func storeRefreshToken(_ token: String) {
        let keychain = Keychain(service: "com.yourapp.inventory")
        do {
            try keychain.set(token, key: "refreshToken")
        } catch {
            print("Failed to save refresh token:", error)
        }
    }

    func readRefreshToken() -> String? {
        let keychain = Keychain(service: "com.yourapp.inventory")
        return try? keychain.get("refreshToken")
    }
    
    func refreshToken(refreshToken: String) async throws -> String {
        let url = URL(string: "\(baseURL)/auth/mobile-refresh")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["refreshToken": refreshToken])
        
        let (data, _) = try await session.data(for: request)
        let decoded = try JSONDecoder().decode([String: String].self, from: data)
        
        guard let newAccessToken = decoded["accessToken"] else {
            throw URLError(.badServerResponse)
        }
        
        self.accessToken = newAccessToken   // <--- store it in your APIService
        self.refreshToken = refreshToken
        return newAccessToken
    }
    
    func login(email: String, password: String) async throws -> User {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["email": email, "password": password])

        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP status code:", httpResponse.statusCode)
            if let dataString = String(data: data, encoding: .utf8) {
                print("Response body:", dataString)
            }
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let result = try JSONDecoder().decode(AuthResponse.self, from: data)
        self.accessToken = result.accessToken
        self.refreshToken = result.refreshToken
        
        KeychainService.shared.save("refreshToken", value: result.refreshToken)

        return result.user
    }
    
    func loginWithGoogle(idToken: String) async throws -> User {
        let url = URL(string: "\(baseURL)/auth/google/mobile/login")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["idToken": idToken])

        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP status code:", httpResponse.statusCode)
            if let dataString = String(data: data, encoding: .utf8) {
                print("Response body:", dataString)
            }
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let result = try JSONDecoder().decode(AuthResponse.self, from: data)
        self.accessToken = result.accessToken
        self.refreshToken = result.refreshToken
        
        KeychainService.shared.save("refreshToken", value: result.refreshToken)

        return result.user
    }
    
//    func register(companyName: String, username: String, email: String, password: String) async throws {
//        let url = URL(string: "\(baseURL)/auth/register")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try JSONEncoder().encode([
//            "companyName": companyName,
//            "username": username,
//            "email": email,
//            "password": password
//        ])
//
//        let (_, response) = try await session.data(for: request)
//        
//        if let httpResponse = response as? HTTPURLResponse {
//            print("HTTP status code:", httpResponse.statusCode)
//            guard (200...299).contains(httpResponse.statusCode) else {
//                throw URLError(.badServerResponse)
//            }
//        }
//
//        // Registration succeeded — just redirect to login
//    }
    
    func register(companyName: String, nik: String, username: String, email: String) async throws {
        let url = URL(string: "\(baseURL)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode([
            "companyName": companyName,
            "nik": nik,
            "username": username,
            "email": email,
        ])

        let (_, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP status code:", httpResponse.statusCode)
            guard (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
        }

        // Registration succeeded — just redirect to login
    }
    
    func fetchCurrentUser(accessToken: String) async throws -> User {
        let url = URL(string: "\(baseURL)/auth/me")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await session.data(for: request)
        let decoded = try JSONDecoder().decode(MeResponse.self, from: data)
        return decoded.user
    }
    
    func fetchLogbooks(page: Int = 1, limit: Int = 10, search: String? = nil) async throws -> PaginatedLogbookResponse {
        var urlComponents = URLComponents(string: "\(baseURL)/logbook")!
        var queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let search = search {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        urlComponents.queryItems = queryItems

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // 🔥🔥🔥 Replace normal data request with automatic refresh-rettry version
        let data = try await requestWithAuth(request)

        return try JSONDecoder().decode(PaginatedLogbookResponse.self, from: data)
    }

    
    func fetchToDoList(page: Int = 1, limit: Int = 10, search: String? = nil) async throws -> PaginatedToDoListResponse {
        var urlComponents = URLComponents(string: "\(baseURL)/to-do-list")!
        var queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let search = search {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        urlComponents.queryItems = queryItems

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // 🔥🔥🔥 Replace normal data request with automatic refresh-rettry version
        let data = try await requestWithAuth(request)

        // Print raw response as a string
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("Raw response data: \(jsonString)")
//        }
//        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)

        let response = try decoder.decode(PaginatedToDoListResponse.self, from: data)
        return response
    }
    
    func fetchProjects(page: Int = 1, limit: Int = 10, search: String? = nil) async throws -> PaginatedProjectsResponse {
        var urlComponents = URLComponents(string: "\(baseURL)/projects")!
        var queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let search = search {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        urlComponents.queryItems = queryItems
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 🔥🔥🔥 Replace normal data request with automatic refresh-rettry version
        let data = try await requestWithAuth(request)
        
        // Print raw response as a string
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("Raw response data: \(jsonString)")
//        }
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let response = try decoder.decode(PaginatedProjectsResponse.self, from: data)
        return response
    }
        
    func fetchProjectById(id: String) async throws -> Project {
        let urlComponents = URLComponents(string: "\(baseURL)/projects/\(id)")!
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 🔥🔥🔥 Replace normal data request with automatic refresh-rettry version
        let data = try await requestWithAuth(request)
        
        // Print raw response as a string
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("Raw response data: \(jsonString)")
//        }
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let response = try decoder.decode(Project.self, from: data)
        return response
    }
    
    func fetchDetailProjects(id: String, page: Int = 1, limit: Int = 10, search: String? = nil) async throws -> PaginatedDetailProjectsResponse {
        var urlComponents = URLComponents(string: "\(baseURL)/detail-projects/\(id)")!
        var queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let search = search {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        urlComponents.queryItems = queryItems
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 🔥🔥🔥 Replace normal data request with automatic refresh-rettry version
        let data = try await requestWithAuth(request)
        
        // Print raw response as a string
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("Raw response data: \(jsonString)")
//        }
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let response = try decoder.decode(PaginatedDetailProjectsResponse.self, from: data)
        return response
    }
    
    func fetchUsers(page: Int = 1, limit: Int = 10, search: String? = nil) async throws -> PaginatedUsersResponse {
        var urlComponents = URLComponents(string: "\(baseURL)/users")!
        var queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let search = search {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        urlComponents.queryItems = queryItems
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 🔥🔥🔥 Replace normal data request with automatic refresh-rettry version
        let data = try await requestWithAuth(request)
        
        // Print raw response as a string
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("Raw response data: \(jsonString)")
//        }
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let response = try decoder.decode(PaginatedUsersResponse.self, from: data)
        return response
    }
    
    func fetchAllUsers() async throws -> [User] {
        let urlComponents = URLComponents(string: "\(baseURL)/users/all")!
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 🔥🔥🔥 Replace normal data request with automatic refresh-rettry version
        let data = try await requestWithAuth(request)
        
        // Print raw response as a string
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("Raw response data for all users: \(jsonString)")
//        }
        
        let response = try JSONDecoder().decode([User].self, from: data)
        return response
    }
    
    func fetchAllRoles() async throws -> [Role] {
        let urlComponents = URLComponents(string: "\(baseURL)/roles")!
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 🔥🔥🔥 Replace normal data request with automatic refresh-rettry version
        let data = try await requestWithAuth(request)
        
        // Print raw response as a string
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("Raw response data for all roles: \(jsonString)")
//        }
        
        let response = try JSONDecoder().decode([Role].self, from: data)
        return response
    }
    
    func fetchDailyReport(startDate: String, endDate: String, userId: String? = nil) async throws -> [DailyReport] {
        var urlComponents = URLComponents(string: "\(baseURL)/logbook/daily")!
        var queryItems = [
            URLQueryItem(name: "startDate", value: "\(startDate)"),
            URLQueryItem(name: "endDate", value: "\(endDate)"),
        ]

        // Only add userId if not nil and not empty
        if let userId, !userId.isEmpty {
            queryItems.append(URLQueryItem(name: "userId", value: userId))
        }
        
        urlComponents.queryItems = queryItems
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    
        debugPrintRequest(request)
        
        // 🔥🔥🔥 Replace normal data request with automatic refresh-rettry version
        let data = try await requestWithAuth(request)
        
        // Print raw response as a string
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("Raw response data: \(jsonString)")
//        }
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let response = try decoder.decode([DailyReport].self, from: data)
        return response
    }

    func fetchUserReport(startDate: String, endDate: String, userId: String? = nil) async throws -> [UserReport] {
        var urlComponents = URLComponents(string: "\(baseURL)/logbook/user")!
        var queryItems = [
            URLQueryItem(name: "startDate", value: "\(startDate)"),
            URLQueryItem(name: "endDate", value: "\(endDate)"),
        ]

        // Only add userId if not nil and not empty
        if let userId, !userId.isEmpty {
            queryItems.append(URLQueryItem(name: "userId", value: userId))
        }
        
        urlComponents.queryItems = queryItems
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    
        debugPrintRequest(request)
        
        // 🔥🔥🔥 Replace normal data request with automatic refresh-rettry version
        let data = try await requestWithAuth(request)
        
        // Print raw response as a string
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("Raw response data: \(jsonString)")
//        }
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let response = try decoder.decode([UserReport].self, from: data)
        return response
    }

    
    // MARK: - Create Logbook
    func addLogbook(_ data: CreateLogbookRequest) async throws {
        let url = URL(string: "\(baseURL)/logbook")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = self.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(data)

        // 🔥 Use your automatic refresh+retry wrapper
        _ = try await requestWithAuth(request)
    }

    // MARK: - Create To Do
    func addToDo(_ data: CreateToDoRequest) async throws {
        let url = URL(string: "\(baseURL)/to-do-list")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = self.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(data)

        // 🔥 Use your automatic refresh+retry wrapper
        _ = try await requestWithAuth(request)
    }
    
    // MARK: - Create Project
    func addProject(_ data: CreateProjectRequest) async throws {
        print("Add project from API")
        
        let url = URL(string: "\(baseURL)/projects")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = self.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(data)

        // 🔥 Use your automatic refresh+retry wrapper
        _ = try await requestWithAuth(request)
    }
    
    // MARK: - Create Detail Project
    func addDetailProject(_ data: CreateDetailProjectRequest) async throws {
        print("Add detail project from API")
        
        let url = URL(string: "\(baseURL)/detail-projects")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = self.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(data)

        // 🔥 Use your automatic refresh+retry wrapper
        _ = try await requestWithAuth(request)
    }
    
    // MARK: - Create User
    func addUser(_ data: CreateUserRequest) async throws {
        print("Add user from API")
        
        let url = URL(string: "\(baseURL)/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = self.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(data)

        // 🔥 Use your automatic refresh+retry wrapper
        _ = try await requestWithAuth(request)
    }
    
    // MARK: - Update Logbook
    func updateLogbook(id: String, data: UpdateLogbookRequest) async throws {
        let url = URL(string: "\(baseURL)/logbook/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = self.accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(data)

        // 🔥 Use your automatic refresh+retry wrapper
        _ = try await requestWithAuth(request)
    }
    
    // MARK: - Update To Do
    func updateToDo(id: String, data: UpdateToDoRequest) async throws {
        let url = URL(string: "\(baseURL)/to-do-list/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = self.accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(data)

        // 🔥 Use your automatic refresh+retry wrapper
        _ = try await requestWithAuth(request)
    }
    
    // MARK: - Update Project
    func updateProject(id: String, data: UpdateProjectRequest) async throws {
        // print("Update project from API")
        
        let url = URL(string: "\(baseURL)/projects/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = self.accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(data)

        // 🔥 Use your automatic refresh+retry wrapper
        _ = try await requestWithAuth(request)
    }
    
    // MARK: - Update Detail Project
    func updateDetailProject(id: String, data: UpdateDetailProjectRequest) async throws {
        print("Update detail project from API")
        
        let url = URL(string: "\(baseURL)/detail-projects/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = self.accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(data)
        
        // 🔥 Use your automatic refresh+retry wrapper
        _ = try await requestWithAuth(request)
    }
    
    // MARK: - Update User Profile
    func updateUserProfile(id: String, data: UpdateUserProfileRequest) async throws {
        let url = URL(string: "\(baseURL)/users/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = self.accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(data)

        // 🔥 Use your automatic refresh+retry wrapper
        _ = try await requestWithAuth(request)
    }
    
    // MARK: - Finish To Do
    func finishToDo(id: String, data: FinishToDoRequest) async throws {
        let url = URL(string: "\(baseURL)/to-do-list/finish/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = self.accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(data)

        // 🔥 Use your automatic refresh+retry wrapper
        _ = try await requestWithAuth(request)
    }
    
    // MARK: - Update User
    func updateUser(id: String, data: UpdateUserRequest) async throws {
        let url = URL(string: "\(baseURL)/users/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = self.accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(data)

        // 🔥 Use your automatic refresh+retry wrapper
        _ = try await requestWithAuth(request)
    }
    
    // MARK: - Delete Logbook
    func deleteLogbook(id: String) async throws {
        let url = URL(string: "\(baseURL)/logbook/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // 🔥 Use your automatic refresh+retry wrapper
        _ = try await requestWithAuth(request)
    }
    
    // MARK: - Delete To Do
    func deleteToDo(id: String) async throws {
        let url = URL(string: "\(baseURL)/to-do-list/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // 🔥 Use your automatic refresh+retry wrapper
        _ = try await requestWithAuth(request)
    }
    
}
