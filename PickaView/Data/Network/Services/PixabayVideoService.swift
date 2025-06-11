//
//  PixabayVideoService.swift
//  PickaView
//
//  Created by DONGNYEONG on 6/9/25.
//

import Foundation

// MARK: - HTTP 메서드 정의
// 현재는 GET만 사용하지만 확장을 고려해 enum으로 설계 , 추후 확장되면 파일로 분리
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - URLRequest 생성용 구조체
// 개별 API 요청을 구성하는 역할. URL, 쿼리, HTTP 메서드 등을 관리 , 추후 확장되면 파일로 분리
struct Endpoint {
    let scheme = "https"
    let host = "pixabay.com"
    let basePath = "/api/videos/"
    let apiKey: String
    var queryItems: [URLQueryItem]
    var method: HTTPMethod = .get

    // 최종 URLRequest를 생성하여 반환
    var urlRequest: URLRequest? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = basePath
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey)
        ] + queryItems

        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}


// MARK: - Pixabay 전용 서비스
// Pixabay 비디오 API에 대한 비즈니스 로직 담당
struct PixabayVideoService {
    private let client: APIClient
    private let apiKey: String

    // APIClient와 Info.plist 번들을 주입받아 테스트 가능하게 설계
    init(client: APIClient = .init(), infoPlistBundle: Bundle = .main) throws {
        self.client = client

        guard let key = infoPlistBundle.object(forInfoDictionaryKey: "PIXABAY_API_KEY") as? String else {
            throw NetworkError.missingAPIKey
        }

        self.apiKey = key
    }


    /// Pixabay에서 비디오 목록을 가져옵니다
    /// - Parameter query: 검색어(옵션). 없으면 전체 인기 목록을 불러옵니다
    /// - Returns: [PixabayVideo] 배열
    func fetchVideos(query: String? = nil) async throws -> [PixabayVideo] {
        var queryItems: [URLQueryItem] = []
        if let q = query {
            queryItems.append(URLQueryItem(name: "q", value: q))
        }

        let endpoint = Endpoint(apiKey: apiKey, queryItems: queryItems)

        // URLRequest 생성 실패 시 에러 발생
        guard let request = endpoint.urlRequest else {
            throw NetworkError.invalidURL
        }

        // APIClient를 통해 실제 네트워크 요청 및 결과 반환
        let response: PixabayResponse = try await client.send(request)
        return response.hits
    }
}
