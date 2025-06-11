//
//  PixabayVideoService.swift
//  PickaView
//
//  Created by DONGNYEONG on 6/9/25.
//

import Foundation


struct PixabayVideoService {
    // 싱글턴 패턴을 구현해서 앱 전역에서 동일한 인스턴스를 공유
    static let shared = PixabayVideoService()

    private let baseURL = "https://pixabay.com/api/videos/"

    private var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "PIXABAY_API_KEY") as? String else {
            fatalError("❌ PIXABAY_API_KEY is not set in Info.plist")
        }
        return key
    }

    // Pixabay API에서 비디오 목록을 비동기적으로 가져오고, JSON을 디코딩
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
