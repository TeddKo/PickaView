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
    let user: String
    let user_id: Int
    let userImageURL: String
    let views: Int
    let comments: Int
    let videos: [String: VideoFile]
}

struct VideoFile: Decodable {
    let url: String
}
