//
//  APIClient.swift
//  PickaView
//
//  Created by DONGNYEONG on 6/11/25.
//

import Foundation

// MARK: - 범용 API 클라이언트
// 실제 URLSession으로 요청을 수행하고 결과를 디코딩하여 반환

class APIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpRes = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(statusCode: -1)
        }

        guard httpRes.statusCode == 200 else {
            throw NetworkError.invalidResponse(statusCode: httpRes.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
