//
//  VideoDTO.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/5/25.
//

// 응답 모델 정의

import Foundation

struct PixabayResponse: Decodable {
    let total: Int
    let totalHits: Int
    let hits: [PixabayVideo]
}

struct PixabayVideo: Decodable {
    let id: Int
    let pageURL: String
    let type: String
    let tags: String
    let duration: Int
    let videos: VideoVariants
    let views: Int
    let downloads: Int
    let likes: Int
    let comments: Int
    let userId: Int
    let user: String
    let userImageURL: String
    let noAiTraining: Bool

    enum CodingKeys: String, CodingKey {
        case id, pageURL, type, tags, duration, videos, views, downloads, likes, comments, user, userImageURL, noAiTraining
        case userId = "user_id"
    }
}

struct VideoVariants: Decodable {
    let large: VideoFile
    let medium: VideoFile
    let small: VideoFile
    let tiny: VideoFile
}

struct VideoFile: Decodable {
    let url: String
    let width: Int
    let height: Int
    let size: Int
    let thumbnail: String
}
