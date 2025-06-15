//
//  search.swift
//  PickaView
//
//  Created by juks86 on 6/13/25.
//

import UIKit

extension HomeViewController: UISearchBarDelegate {

    //테이블뷰가 보여졌을때 검색목록 높이 설정
    func updateTableViewVisibility(isVisible: Bool) {
        tableView.isHidden = !isVisible

        if isVisible {
            // 적당한 높이로 설정 (예: 테이블뷰 내용이 많으면 최대 높이 제한)
            let maxHeight: CGFloat = 200
            let contentHeight = tableView.contentSize.height
            tableViewHeightConstraint.constant = min(contentHeight, maxHeight)
        } else {
            tableViewHeightConstraint.constant = 0  //테이블뷰 숨겨지면 높이 0으로
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }


    // 실시간 필터링, 예를 들어 f입력하면 그걸로 시작하는 태그들 보여주기 //일치하는 태그 없으면 없다고 플레이스 홀더 띄우기
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let viewModel = viewModel else { return }

        // 무한 호출 방지
        if searchText.first != "#" && !searchText.isEmpty {
            searchBar.text = "#\(searchText)"
            return
        }

        let cleanKeyword = searchBar.text?.replacingOccurrences(of: "#", with: "") ?? ""
        if cleanKeyword.isEmpty {
            filteredTags = viewModel.allTags
        } else {
            filteredTags = viewModel.filterTags(keyword: cleanKeyword)
        }
        tableView.reloadData()
        updateTableViewVisibility(isVisible: !filteredTags.isEmpty)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("🔍 검색 버튼 클릭됨")
        searchBar.resignFirstResponder()

        guard let keyword = searchBar.text, !keyword.isEmpty else {
            return
        }

        // '#' 기호 제거
        let cleanKeyword = keyword.replacingOccurrences(of: "#", with: "").lowercased()

        // 현재 태그 목록에서 검색어와 일치하는 태그가 있는지 확인
        let matchedTag = viewModel?.allTags.first(where: { tag in
            tag.name?.lowercased() == cleanKeyword
        })

        // 일치하는 태그가 없으면 검색 안 함
        guard let validTag = matchedTag else {
            print("❌ 일치하는 태그 없음 - 검색 중단")
            return
        }

        // 해당 태그 기반으로 비디오 가져오기
        let filteredVideos = viewModel?.fetchVideosForTag(validTag.name ?? "") ?? []

        // 컬렉션뷰 업데이트
        self.videoList = filteredVideos
        self.collectionView.reloadData()

        // 검색창 초기화
        searchBar.text = ""

        // 태그 테이블 숨김 처리 (선택사항)
        updateTableViewVisibility(isVisible: true)
    }

    //검색 텍스트 입력직전
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // 키보드가 올라올 때 전체 태그 목록 보여주기
        filteredTags = viewModel?.allTags ?? []
        tableView.reloadData()
        updateTableViewVisibility(isVisible: true)
    }

    // 사용자가 검색 끝내고 나가면 테이블뷰 숨김
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        updateTableViewVisibility(isVisible: false)
    }

    

}

//서치바에서 글자수 제한
extension HomeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        return updatedText.count <= 30 // 최대 글자 수 10자
    }
}
