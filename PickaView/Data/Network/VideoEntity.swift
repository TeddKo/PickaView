//
//  VideoDTO.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/5/25.
//

// 응답 모델 정의

import Foundation

struct PixabayResponse: Decodable {
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
    let userID: Int
    let user: String
    let userImageURL: String
    let noAiTraining: Bool

    enum CodingKeys: String, CodingKey {
        case id, pageURL, type, tags, duration, videos, views, downloads, likes, comments, user, userImageURL, noAiTraining
        case userID = "user_id"
    }
}

struct VideoVariants: Decodable {
    let medium: VideoFile
}

struct VideoFile: Decodable {
    let url: String
    let width: Int
    let height: Int
    let size: Int
    let thumbnail: String
}


// MARK: - Medium 영상만 사용할 경우
extension PixabayVideo {
    var mediumURL: URL? {
        URL(string: videos.medium.url)
    }

    var mediumThumbnailURL: URL? {
        URL(string: videos.medium.thumbnail)
    }

    var mediumVideoFile: VideoFile {
        videos.medium
    }
}
