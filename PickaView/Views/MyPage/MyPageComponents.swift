//
//  Components.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/15/25.
//

import Foundation
import UIKit

/// 두 개의 텍스트를 수평으로 배치하는 UI 컴포넌트를 생성하여 스택뷰에 추가.
final class TwoLabelRowView: UIView {

    // MARK: - UI Components
    
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

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        fatalError("init(coder:) has not been implemented")
    }
    
    

    // MARK: - Private Methods

    private func setupViews() {
        self.addSubview(horizontalTwoItemStackView)
        
        // 오토레이아웃 설정
        NSLayoutConstraint.activate([
            horizontalTwoItemStackView.topAnchor.constraint(equalTo: topAnchor),
            horizontalTwoItemStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            horizontalTwoItemStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            horizontalTwoItemStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
        
        horizontalTwoItemStackView.configure(leftItem: leftLabel, rightItem: rightLabel)
    }

    // MARK: - Public Methods

    /// 뷰의 텍스트를 설정
    /// - Parameters:
    ///   - leftText: 왼쪽 텍스트
    ///   - rightText: 오른쪽 텍스트
    
    func configure(leftText: String, rightText: String) {
        leftLabel.text = leftText
        rightLabel.text = rightText
    }
}

final class HorizontalLabelButtonView: UIView {
    
    private let horizontalTwoItemStackView: HorizontalTwoItemStackView = {
       let stackView = HorizontalTwoItemStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textColor = .label
        label.textAlignment = .left
        label.text = "History"
        return label
    }()
    
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

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        fatalError("init(coder:) has not been implemented")
    }
    
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
}
