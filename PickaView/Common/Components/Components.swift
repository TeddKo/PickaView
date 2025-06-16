//
//  MediaViewCell.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/11/25.
//

import UIKit

/**
 해시태그 하나를 표시하는 뷰 컴포넌트.
 */
final class TagView: UIView {
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    /**
     주어진 제목으로 TagView를 초기화함.
     - Parameter title: 태그에 표시될 문자열.
     */
    init(title: String) {
        super.init(frame: .zero)
        
        tagLabel.text = title
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemGray5
        layer.cornerRadius = 12
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(tagLabel)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            tagLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            tagLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            tagLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            tagLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
}

/**
 썸네일, 영상 길이를 표시하는 뷰 컴포넌트.
 */
final class MediaContentView: UIView {
    
    private let thumbnailImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .systemGray4
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 12
        return image
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .white
        label.backgroundColor = .black.withAlphaComponent(0.4)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     뷰를 주어진 데이터로 설정함.
     - Parameters:
       - thumbnailURL: 불러올 썸네일 이미지의 URL 주소.
       - videoLength: 영상 길이 (초단위).
     */
    func configure(
        thumbnailURL: String,
        videoLength: Double
    ) {
        thumbnailImageView.loadImage(from: thumbnailURL)
        
        let minutes = Int(videoLength) / 60
        let seconds = Int(videoLength) % 60
        durationLabel.text = String(format: " %02d:%02d ", minutes, seconds)
    }
    
    /**
     썸네일 이미지를 초기화함.
     */
    func resetImage() {
        thumbnailImageView.image = nil
    }
    
    private func setupUI() {
        addSubview(thumbnailImageView)
        addSubview(durationLabel)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            durationLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: -8),
            durationLabel.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -8)
        ])
    }
}

/**
 날짜, 썸네일, 영상 길이를 표시하는 뷰 컴포넌트.
 */
final class MediaDateContentView: UIView {
    
    private let contentVStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let thumbnailImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .systemGray4
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 12
        image.clipsToBounds = true
        return image
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .white
        label.backgroundColor = .black.withAlphaComponent(0.4)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     뷰를 주어진 데이터로 설정함.
     - Parameters:
       - date: 표시할 날짜.
       - thumbnailURL: 불러올 썸네일 이미지의 URL 주소.
       - videoLength: 영상 길이 (초단위).
     */
    func configure(
        date: Date,
        thumbnailURL: String,
        videoLength: Double
    ) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy/MM/dd"
        dateLabel.text = dateFormatter.string(from: date)
        
        thumbnailImageView.loadImage(from: thumbnailURL)
        
        let minutes = Int(videoLength) / 60
        let seconds = Int(videoLength) % 60
        durationLabel.text = String(format: " %02d:%02d ", minutes, seconds)
    }
    
    private func setupUI() {
        addSubview(contentVStack)
        thumbnailImageView.addSubview(durationLabel)
        
        contentVStack.addArrangedSubview(dateLabel)
        contentVStack.addArrangedSubview(thumbnailImageView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            contentVStack.topAnchor.constraint(equalTo: topAnchor),
            contentVStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentVStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentVStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            durationLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: -8),
            durationLabel.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -8)
        ])
    }
    
    /**
     썸네일 이미지를 초기화함.
     */
    func resetImage() {
        thumbnailImageView.image = nil
    }
}

/**
 상단의 액션 버튼과 하단의 태그 목록을 포함하는 뷰.
 */
final class ActionableTagsView: UIView {

    private lazy var likeButton: UIButton = {
        let button = UIButton()
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium, scale: .default)
        let symbolImage = UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)

        button.setImage(symbolImage, for: .normal)
        button.tintColor = .systemPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let tagsView = HorizontalTagsView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     태그 목록을 주어진 문자열 배열로 설정함.
     - Parameter tags: 표시할 태그 문자열의 배열.
     */
    func configure(with tags: [String]) {
        tagsView.configure(with: tags)
    }
    
    private func setupUI() {
        addSubview(likeButton)
        addSubview(tagsView)
    }
    
    private func setupLayout() {
        tagsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: self.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            tagsView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            tagsView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tagsView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}

/**
 여러 태그를 가로로 스크롤하여 보여주는 뷰.
 */
final class HorizontalTagsView: UIView {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let tagsHStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(horizontal: 16)
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     태그 목록을 주어진 문자열 배열로 설정함.
     
     기존에 표시되던 모든 태그를 제거하고 새로운 태그로 교체.
     - Parameter tags: 표시할 태그 문자열의 배열.
     */
    func configure(with tags: [String]) {
        tagsHStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for tagName in tags {
            let tagView = TagView(title: tagName)
            tagsHStack.addArrangedSubview(tagView)
        }
    }
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(tagsHStack)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            tagsHStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            tagsHStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            tagsHStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            tagsHStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            
            tagsHStack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }
}

/**
 미디어 콘텐츠와 수평 태그 목록을 조합한 히스토리 셀 뷰.
 */
final class MediaHistoryCellView: UIView {
    
    private let mainHStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal

        stack.alignment = .bottom
        return stack
    }()
    
    private let mediaDateContentView = MediaDateContentView()
    private let tagsView = HorizontalTagsView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     셀 뷰를 주어진 데이터로 설정함.
     - Parameters:
       - date: 표시할 날짜.
       - thumbnailURL: 불러올 썸네일 이미지의 URL 주소.
       - videoLength: 영상 길이 (초단위).
       - tags: 표시할 태그 문자열의 배열.
     */
    func configure(
        date: Date,
        thumbnailURL: String,
        videoLength: Double,
        tags: [String]
    ) {
        mediaDateContentView
            .configure(
                date: date,
                thumbnailURL: thumbnailURL,
                videoLength: videoLength
            )
        tagsView.configure(with: tags)
    }
    
    private func setupUI() {
        mainHStack.addArrangedSubview(mediaDateContentView)
        mainHStack.addArrangedSubview(tagsView)
        
        addSubview(mainHStack)
    }
    
    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainHStack.topAnchor.constraint(equalTo: topAnchor),
            mainHStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainHStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainHStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            mediaDateContentView.widthAnchor.constraint(equalTo: mainHStack.safeAreaLayoutGuide.widthAnchor, multiplier: 0.6),
            mediaDateContentView.heightAnchor.constraint(equalTo: mainHStack.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
            tagsView.widthAnchor.constraint(equalTo: mainHStack.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4)
        ])
    }
    
    /**
     셀의 모든 콘텐츠를 초기화함.
     
     `prepareForReuse`에서 호출될 것을 대비한 메서드.
     */
    func resetContents() {
        mediaDateContentView.resetImage()
        tagsView.configure(with: [])
    }
}

/**
 미디어 콘텐츠와 액션 버튼 및 태그 목록을 조합한 '좋아요' 셀 뷰.
 */
final class LikeCellView: UIView {
    
    private let mainHStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        return stack
    }()
    
    private let mediaContentView = MediaContentView()
    private let actionabletagsView = ActionableTagsView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     셀 뷰를 주어진 데이터로 설정함.
     - Parameters:
       - date: 표시할 날짜.
       - thumbnailURL: 불러올 썸네일 이미지의 URL 주소.
       - videoLength: 영상 길이 (초단위).
       - tags: 표시할 태그 문자열의 배열.
     */
    func configure(
        date: Date,
        thumbnailURL: String,
        videoLength: Double,
        tags: [String]
    ) {
        mediaContentView
            .configure(
                thumbnailURL: thumbnailURL,
                videoLength: videoLength
            )
        actionabletagsView.configure(with: tags)
    }
    
    
    private func setupUI() {
        mainHStack.addArrangedSubview(mediaContentView)
        mainHStack.addArrangedSubview(actionabletagsView)
        
        addSubview(mainHStack)
    }
    
    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainHStack.topAnchor.constraint(equalTo: topAnchor),
            mainHStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainHStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainHStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            mediaContentView.widthAnchor.constraint(equalTo: mainHStack.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            actionabletagsView.widthAnchor.constraint(equalTo: mainHStack.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5)
        ])
    }
    
    /**
     셀의 모든 콘텐츠를 초기화함.
     
     `prepareForReuse`에서 호출될 것을 대비한 메서드.
     */
    func resetContents() {
        mediaContentView.resetImage()
        actionabletagsView.configure(with: [])
    }
}


final class HorizontalTwoItemStackView : UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .horizontal
        self.distribution = .equalSpacing
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: topAnchor),
            self.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    
    func configure(
        leftItem: UIView,
        rightItem: UIView
    ) {
        self.addArrangedSubview(leftItem)
        self.addArrangedSubview(rightItem)
    }
}
