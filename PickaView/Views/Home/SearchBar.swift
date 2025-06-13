//
//  search.swift
//  PickaView
//
//  Created by juks86 on 6/13/25.
//

import UIKit

extension HomeViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("🔍 검색어 변경됨: \(searchText)")
        // 실시간 필터링 예를 들어 f입력하면 그걸로 시작하는 태그들 보여주기 //일치하는 태그 없으면 없다고 플레이스 홀더 띄우기
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { //검색 되도록
        print("🔍 검색 버튼 클릭됨")
        searchBar.resignFirstResponder()

        guard let keyword = searchBar.text, !keyword.isEmpty else {
            // 검색어가 없으면 전체 비디오 다시 로드
            //videos = viewModel.fetchAllVideos()
            collectionView.reloadData()
            return
        }

        // CoreData에서 태그 필터링
       //videos = viewModel.fetchVideos(tag: keyword)
        collectionView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        print("❌ 검색 취소됨")

        // 전체 비디오로 복원
        //videos = viewModel.fetchAllVideos()
        collectionView.reloadData()
    }
}
