//
//  ImageCacheManager.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/13/25.
//

import Foundation
import UIKit


/// 이미지의 인메모리 캐시를 관리하는 싱글톤 클래스.
/// 
/// `NSCache`를 내부적으로 사용하여, 시스템 메모리가 부족할 때
/// 자동으로 캐시된 항목을 제거하는 등 메모리를 효율적으로 관리함.
final class ImageCacheManager {
    /// `ImageCacheManager`의 전역 싱글톤 인스턴스.
    static let shared = ImageCacheManager()
    
    /// 싱글톤 패턴을 위해 외부에서 인스턴스를 생성하는 것을 방지.
    private init() {}

    /// URL 문자열을 키로, UIImage를 값으로 갖는 인메모리 캐시 저장소.
    private let cache = NSCache<NSString, UIImage>()
    
    /**
     지정된 키에 해당하는 캐시된 이미지를 반환함.

     - Parameter key: 검색할 이미지의 키 (일반적으로 URL 문자열).
     - Returns: 캐시에 이미지가 있으면 `UIImage`, 없으면 `nil`.
     */
    func object(forKey key: NSString) -> UIImage? {
        print("캐시된 이미지를 가져옵니다.\(key)")
        return cache.object(forKey: key)
    }
    
    /// 지정된 키와 함께 이미지를 캐시에 저장함.
    ///
    /// - Parameters:
    ///   - object: 캐시할 `UIImage`.
    ///   - key: 저장할 이미지의 키 (일반적으로 URL 문자열).
    func setObject(_ object: UIImage, forKey key: NSString) {
        print("캐시에 이미지를 저장합니다.\(object) \(key)")
        cache.setObject(object, forKey: key)
    }
}
