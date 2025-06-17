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


    // 텍스트 바뀔때 실시간으로 태그 목록 필터링
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let viewModel = viewModel else { return }

        var keyword = searchText
        // 맨 앞에 # 있으면 제거
        if keyword.hasPrefix("#") {
            keyword = String(keyword.dropFirst())
        }

        // 필터링할 키워드는 소문자
        keyword = keyword.lowercased()

        if keyword.isEmpty {
            filteredTags = viewModel.allTags
        } else {
            filteredTags = viewModel.allTags.filter { $0.name?.lowercased().hasPrefix(keyword) == true }
        }

        tableView.reloadData()
        updateTableViewVisibility(isVisible: true)

        // # 없으면, 한 번만 붙여주기 (무한 루프 방지)
        if !searchText.hasPrefix("#") && !searchText.isEmpty {
            searchBar.text = "#" + searchText
        }
    }

    //검색바 클릭 됐을때 태그와 맞는 비디오 가져옴
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

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
            return
        }

        // 해당 태그 기반으로 비디오 가져오기
        applyTagFilter(tagName: validTag.name ?? "")
    }

    //태그가 필터링 되었고 필터된 비디오목록이 있을때만 동작
    func textFieldShouldClear(_ textField: UITextField) -> Bool

        if isTagSearchActive {

            // 원래 비디오 목록 복원
            videoList = originalVideoList

            collectionView.reloadData()

            collectionView.setContentOffset(.zero, animated: false)

            collectionView.bounces = true

            updateTableViewVisibility(isVisible: false)

            isTagSearchActive = false
        }

        DispatchQueue.main.async {
            textField.resignFirstResponder()
        }

        return true
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

        return updatedText.count <= 30 // 최대 글자 수 30자
    }
}
