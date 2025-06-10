//
//  PixabayVideoService.swift
//  PickaView
//
//  Created by DONGNYEONG on 6/9/25.
//

import Foundation


struct PixabayVideoService {
    static let shared = PixabayVideoService()

    private let baseURL = "https://pixabay.com/api/videos/"

    private var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "PIXABAY_API_KEY") as? String else {
            fatalError("❌ PIXABAY_API_KEY is not set in Info.plist")
        }
        return key
    }

    func fetchVideos() async throws -> [PixabayVideo] {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
        ]

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        print("📡 Requesting:", url.absoluteString)

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(PixabayResponse.self, from: data)
        return decoded.hits
    }
}
