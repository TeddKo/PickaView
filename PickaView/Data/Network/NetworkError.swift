//
//  NetworkError.swift
//  PickaView
//
//  Created by DONGNYEONG on 6/11/25.
//

import Foundation

// MARK: - 네트워크 오류 정의
// 발생 가능한 에러를 명확히 분리해 디버깅 및 사용자 대응을 용이하게 함

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse(statusCode: Int)
    case noData
    case decodingFailed(Error)
    case missingAPIKey
}
