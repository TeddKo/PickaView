//
//  Components.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/15/25.
//

import Foundation
import UIKit

/// 두 개의 레이블을 한 행의 양 끝에 수평으로 배치하는 뷰.
final class TwoLabelRowView: UIView {

    private let horizontalTwoItemStackView: HorizontalTwoItemStackView = {
       let stackView = HorizontalTwoItemStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let leftLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.textColor = .label
        return label
    }()

    private let rightLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .right
        label.textColor = .label
        return label
    }()

    /// 코드로 뷰를 초기화함.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    /// Interface Builder(스토리보드)에서 뷰를 초기화하는 것은 지원하지 않음.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 하위 뷰들을 추가하고 오토레이아웃을 설정함.
    private func setupViews() {
        self.addSubview(horizontalTwoItemStackView)
        
        NSLayoutConstraint.activate([
            horizontalTwoItemStackView.topAnchor.constraint(equalTo: topAnchor),
            horizontalTwoItemStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            horizontalTwoItemStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            horizontalTwoItemStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
        
        horizontalTwoItemStackView.configure(leftItem: leftLabel, rightItem: rightLabel)
    }

    /// 왼쪽과 오른쪽 레이블의 텍스트를 설정함.
    /// - Parameters:
    ///   - leftText: 왼쪽 레이블에 표시할 문자열.
    ///   - rightText: 오른쪽 레이블에 표시할 문자열.
    func configure(leftText: String, rightText: String) {
        leftLabel.text = leftText
        rightLabel.text = rightText
    }
}

/// 왼쪽에는 제목 레이블, 오른쪽에는 '전체 보기' 형태의 버튼을 수평으로 배치하는 뷰.
final class HorizontalLabelButtonView: UIView {
    
    /// 버튼이 탭되었을 때 실행될 클로저.
    private var buttonAction: (() -> Void)?
    
    /// 레이블과 버튼을 수평으로 배치하는 스택뷰.
    private let horizontalTwoItemStackView: HorizontalTwoItemStackView = {
       let stackView = HorizontalTwoItemStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// 왼쪽에 표시될 제목 `UILabel`.
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textColor = .label
        label.textAlignment = .left
        label.text = "History"
        return label
    }()
    
    /// 오른쪽에 표시될 `UIButton`.
    private let button: UIButton = {
        var config = UIButton.Configuration.plain()
        
        config.attributedTitle = AttributedString("All", attributes: AttributeContainer([.font: UIFont.preferredFont(forTextStyle: .body)]))
        config.contentInsets = .zero
        config.image = UIImage(systemName: "chevron.right")
        config.imagePlacement = .trailing
        config.imagePadding = 5
        config.baseForegroundColor = .label
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    /// 코드로 뷰를 초기화함.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
    }
    
    /// Interface Builder(스토리보드)에서 뷰를 초기화하는 것은 지원하지 않음.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 하위 뷰들을 추가하고 오토레이아웃을 설정함.
    private func setupLayout() {
        self.addSubview(horizontalTwoItemStackView)
        
        NSLayoutConstraint.activate([
            horizontalTwoItemStackView.topAnchor.constraint(equalTo: topAnchor),
            horizontalTwoItemStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            horizontalTwoItemStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            horizontalTwoItemStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        horizontalTwoItemStackView.addArrangedSubview(titleLabel)
        horizontalTwoItemStackView.addArrangedSubview(button)
    }
    
    /// 버튼 탭 이벤트를 처리하여 `buttonAction` 클로저를 실행함.
    @objc private func handleButtonTap() {
        guard let buttonAction else { return }
        buttonAction()
    }
    
    /// 버튼이 탭되었을 때 실행될 클로저를 외부에서 설정함.
    /// - Parameter action: 버튼 탭 시 실행될 클로저.
    func setButtonTapAction(action: @escaping () -> Void) {
        self.buttonAction = action
    }
}
