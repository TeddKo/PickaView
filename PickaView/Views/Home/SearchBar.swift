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
        print("🔍 검색어 변경됨: \(searchText)")

    }

    //검색버튼 클릭시
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("🔍 검색 버튼 클릭됨")
        searchBar.resignFirstResponder()

        guard let keyword = searchBar.text, !keyword.isEmpty else {
            //collectionView.reloadData()
            return
        }

        // CoreData에서 태그 필터링
        // videos = viewModel.fetchVideos(tag: keyword)
        searchBar.text = ""
    }

    //검색 텍스트 입력직전
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
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

        return updatedText.count <= 10 // 최대 글자 수 10자
    }
}
