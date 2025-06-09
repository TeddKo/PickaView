//
//  PixabayVideoService.swift
//  PickaView
//
//  Created by DONGNYEONG on 6/9/25.
//

import Foundation


struct PixabayVideoService {
    static let shared = PixabayVideoService()

    private let baseURL = 
    "https://pixabay.com/api/videos/"
    private var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "PIXABAY_API_KEY") as? String else {
            fatalError("PIXABAY_API_KEY is not set in Info.plist")
        }
        print("API Key:", key)
        return key
    }


    func fetchVideos(perPage: Int = 20) async throws -> [PixabayVideo] {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: "nature"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        print("Request URL:", url.absoluteString)

        let config = URLSessionConfiguration.default


        let session = URLSession(configuration: config)

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            let decoder = JSONDecoder()
            let pixabayResponse = try decoder.decode(PixabayResponse.self, from: data)
            print("Fetched \(pixabayResponse.hits.count) videos")
            return pixabayResponse.hits

        } catch {
            print("Fetch failed with error:", error)
            throw error
        }
    }


}
