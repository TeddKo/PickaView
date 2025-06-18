//
//  Components.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/11/25.
//

import UIKit

/// 해시태그 하나를 표시하는 UI 컴포넌트.
final class TagView: UIView {
    
    /// 태그의 이름을 표시하는 UILabel.
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    /// 주어진 제목으로 `TagView`를 초기화함.
    /// - Parameter title: 태그에 표시될 문자열.
    init(title: String) {
        super.init(frame: .zero)
        
        tagLabel.text = title
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 뷰의 배경색, 테두리 등 외형을 설정함.
    private func setupUI() {
        backgroundColor = .tagBackground
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(named: "SubColor")?.cgColor
        layer.cornerRadius = 17
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(tagLabel)
    }
    
    /// 하위 뷰의 레이아웃 제약조건을 설정함.
    private func setupLayout() {
        NSLayoutConstraint.activate([
            tagLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            tagLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            tagLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            tagLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }
}

/// 썸네일과 영상 길이를 표시하는 UI 컴포넌트.
final class MediaContentView: UIView {
    
    /// 비디오 썸네일을 표시하는 `UIImageView`.
    private let thumbnailImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .systemGray4
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 12
        return image
    }()
    
    /// 비디오의 총 길이를 표시하는 `UILabel`.
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
    
    /// 뷰를 주어진 데이터로 설정함.
    /// - Parameters:
    ///   - thumbnailURL: 불러올 썸네일 이미지의 URL 주소.
    ///   - videoLength: 영상 길이 (초단위).
    func configure(
        thumbnailURL: String,
        videoLength: Double
    ) {
        thumbnailImageView.loadImage(from: thumbnailURL)
        
        let minutes = Int(videoLength) / 60
        let seconds = Int(videoLength) % 60
        durationLabel.text = String(format: " %02d:%02d ", minutes, seconds)
    }
    
    /// 썸네일 이미지를 초기화하여 셀 재사용 시 기존 이미지가 남는 것을 방지함.
    func resetImage() {
        thumbnailImageView.image = nil
    }
    
    /// 하위 뷰들을 뷰 계층에 추가함.
    private func setupUI() {
        addSubview(thumbnailImageView)
        addSubview(durationLabel)
    }
    
    /// 하위 뷰의 레이아웃 제약조건을 설정함.
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

/// 날짜, 썸네일, 영상 길이를 수직으로 표시하는 UI 컴포넌트.
final class MediaDateContentView: UIView {
    
    /// 하위 뷰들을 수직으로 정렬하는 `UIStackView`.
    private let contentVStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    /// 날짜를 표시하는 `UILabel`.
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    /// 썸네일을 표시하는 `UIImageView`.
    private let thumbnailImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .systemGray4
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 12
        image.clipsToBounds = true
        return image
    }()
    
    /// 영상 길이를 표시하는 `UILabel`.
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
    
    /// 뷰를 주어진 데이터로 설정함.
    /// - Parameters:
    ///   - date: 표시할 날짜.
    ///   - thumbnailURL: 불러올 썸네일 이미지의 URL 주소.
    ///   - videoLength: 영상 길이 (초단위).
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
    
    /// 하위 뷰들을 뷰 계층에 추가함.
    private func setupUI() {
        addSubview(contentVStack)
        thumbnailImageView.addSubview(durationLabel)
        
        contentVStack.addArrangedSubview(dateLabel)
        contentVStack.addArrangedSubview(thumbnailImageView)
    }
    
    /// 하위 뷰의 레이아웃 제약조건을 설정함.
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
    
    /// 썸네일 이미지를 초기화함.
    func resetImage() {
        thumbnailImageView.image = nil
    }
}

/// 상단의 액션 버튼과 하단의 태그 목록을 포함하는 뷰.
final class ActionableTagsView: UIView {
    
    /// 버튼이 탭되었을 때 실행될 클로저.
    private var buttonAction: (() -> Void)?
    
    /// '좋아요' 상태를 나타내는 `UIButton`.
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium, scale: .default)
        let symbolImage = UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)

        button.setImage(symbolImage, for: .normal)
        button.tintColor = .systemPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    /// 태그 목록을 수평으로 표시하는 뷰.
    private let tagsView = HorizontalTagsView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        likeButton.addTarget(
            self,
            action: #selector(handleButtonTap),
            for: .touchUpInside
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 태그 목록을 주어진 `Set<Tag>`으로 설정함.
    /// - Parameter tags: 표시할 `Tag` 객체의 `Set`.
    func configure(with tags: Set<Tag>) {
        tagsView.configure(with: tags)
    }
    
    /// 하위 뷰들을 뷰 계층에 추가함.
    private func setupUI() {
        addSubview(likeButton)
        addSubview(tagsView)
    }
    
    /// 버튼 탭 이벤트를 처리함.
    @objc private func handleButtonTap() {
        guard let buttonAction = buttonAction else { return }
        buttonAction()
    }
    
    /// 버튼 탭 시 실행될 클로저를 외부에서 설정함.
    /// - Parameter action: 버튼 탭 시 실행될 클로저.
    func setButtonTapAction(action: @escaping () -> Void) {
        self.buttonAction = action
    }
    
    /// 하위 뷰의 레이아웃 제약조건을 설정함.
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

/// 여러 태그를 가로로 스크롤하여 보여주는 뷰.
final class HorizontalTagsView: UIView {
    
    /// 수평 스크롤을 담당하는 `UIScrollView`.
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    /// 태그들을 수평으로 나열하는 `UIStackView`.
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
    
    /// 태그 목록을 주어진 `Set<Tag>`으로 설정함.
    ///
    /// 기존에 표시되던 모든 태그를 제거하고 새로운 태그로 교체함.
    /// - Parameter tags: 표시할 `Tag` 객체의 `Set`.
    func configure(with tags: Set<Tag>) {
        tagsHStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for tag in tags {
            guard let name = tag.name else { continue }
            let tagView = TagView(title: name)
            tagsHStack.addArrangedSubview(tagView)
        }
    }
    
    /// 하위 뷰들을 뷰 계층에 추가함.
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(tagsHStack)
    }
    
    /// 하위 뷰의 레이아웃 제약조건을 설정함.
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

/// 미디어 콘텐츠(날짜, 썸네일)와 수평 태그 목록을 조합한 히스토리 셀 뷰.
final class MediaHistoryCellView: UIView {
    
    /// 하위 뷰들을 수평으로 정렬하는 메인 `UIStackView`.
    private let mainHStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .bottom
        return stack
    }()
    
    /// 날짜와 미디어 콘텐츠를 표시하는 뷰.
    private let mediaDateContentView = MediaDateContentView()
    /// 태그 목록을 수평으로 표시하는 뷰.
    private let tagsView = HorizontalTagsView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 셀 뷰를 주어진 데이터로 설정함.
    /// - Parameters:
    ///   - date: 표시할 날짜.
    ///   - thumbnailURL: 불러올 썸네일 이미지의 URL 주소.
    ///   - videoLength: 영상 길이 (초단위).
    ///   - tags: 표시할 `Tag` 객체의 `Set`.
    func configure(
        date: Date,
        thumbnailURL: String,
        videoLength: Double,
        tags: Set<Tag>
    ) {
        mediaDateContentView
            .configure(
                date: date,
                thumbnailURL: thumbnailURL,
                videoLength: videoLength
            )
        tagsView.configure(with: tags)
    }
    
    /// 하위 뷰들을 뷰 계층에 추가함.
    private func setupUI() {
        mainHStack.addArrangedSubview(mediaDateContentView)
        mainHStack.addArrangedSubview(tagsView)
        
        addSubview(mainHStack)
    }
    
    /// 하위 뷰의 레이아웃 제약조건을 설정함.
    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainHStack.topAnchor.constraint(equalTo: topAnchor),
            mainHStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainHStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainHStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            mediaDateContentView.widthAnchor.constraint(equalTo: mainHStack.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            mediaDateContentView.heightAnchor.constraint(equalTo: mainHStack.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
            tagsView.widthAnchor.constraint(equalTo: mainHStack.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5)
        ])
    }
    
    /// 셀의 모든 콘텐츠를 초기화함. 셀 재사용을 위함.
    func resetContents() {
        mediaDateContentView.resetImage()
        tagsView.configure(with: [])
    }
}

/// 미디어 콘텐츠와 액션 버튼 및 태그 목록을 조합한 '좋아요' 셀 뷰.
final class LikeCellView: UIView {
    
    /// 하위 뷰들을 수평으로 정렬하는 메인 `UIStackView`.
    private let mainHStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        return stack
    }()
    
    /// 미디어 콘텐츠를 표시하는 뷰.
    private let mediaContentView = MediaContentView()
    /// 액션 버튼과 태그 목록을 표시하는 뷰.
    private let actionabletagsView = ActionableTagsView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// `actionabletagsView`의 버튼 액션을 설정함.
    /// - Parameter action: 버튼 탭 시 실행될 클로저.
    func setButtonAction(action: @escaping () -> Void) {
        actionabletagsView.setButtonTapAction(action: action)
    }
    
    /// 셀 뷰를 주어진 데이터로 설정함.
    /// - Parameters:
    ///   - thumbnailURL: 불러올 썸네일 이미지의 URL 주소.
    ///   - videoLength: 영상 길이 (초단위).
    ///   - tags: 표시할 `Tag` 객체의 `Set`.
    func configure(
        thumbnailURL: String,
        videoLength: Double,
        tags: Set<Tag>
    ) {
        mediaContentView
            .configure(
                thumbnailURL: thumbnailURL,
                videoLength: videoLength
            )
        actionabletagsView.configure(with: tags)
    }
    
    /// 하위 뷰들을 뷰 계층에 추가함.
    private func setupUI() {
        mainHStack.addArrangedSubview(mediaContentView)
        mainHStack.addArrangedSubview(actionabletagsView)
        
        addSubview(mainHStack)
    }
    
    /// 하위 뷰의 레이아웃 제약조건을 설정함.
    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainHStack.topAnchor.constraint(equalTo: topAnchor),
            mainHStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainHStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainHStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            mediaContentView.widthAnchor.constraint(equalTo: mainHStack.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            mediaContentView.heightAnchor.constraint(equalTo: mainHStack.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
            actionabletagsView.widthAnchor.constraint(equalTo: mainHStack.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5)
        ])
    }
    
    /// 셀의 모든 콘텐츠를 초기화함. 셀 재사용을 위함.
    func resetContents() {
        mediaContentView.resetImage()
        actionabletagsView.configure(with: [])
    }
}

/// 두 개의 아이템을 수평으로, 양 끝에 배치하는 `UIStackView`의 서브클래스.
final class HorizontalTwoItemStackView : UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 스택뷰의 기본 속성을 설정함.
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
    
    /// 스택뷰에 왼쪽과 오른쪽 아이템을 추가함.
    func configure(
        leftItem: UIView,
        rightItem: UIView
    ) {
        self.addArrangedSubview(leftItem)
        self.addArrangedSubview(rightItem)
    }
}

/// 데이터가 없을 때 사용자에게 표시할 내용을 담는 뷰.
///
/// 예: '좋아요' 목록이 비어있을 경우 "No liked items yet" 메시지를 표시함.
final class EmptyView: UIView {
    
    /// 하위 뷰들을 수직으로 정렬하는 `UIStackView`.
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    /// 아이콘을 표시하는 `UIImageView`.
    private let imageView = UIImageView()
    
    /// 주 제목을 표시하는 `UILabel`.
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    /// 부가 설명을 표시하는 `UILabel`.
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    /// 하위 뷰들을 추가하고 레이아웃을 설정함.
    private func setupLayout() {
        self.addSubview(stackView)
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3),
            imageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3),
        ])
    }
    
    /// 뷰에 표시될 이미지, 제목, 설명을 설정함.
    /// - Parameters:
    ///   - systemName: 표시할 SF Symbol 이름.
    ///   - title: 주 제목 문자열.
    ///   - description: 부가 설명 문자열.
    func configure(
        systemName: String,
        title: String,
        description: String
    ) {
        imageView.image = UIImage(systemName: systemName)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintColor = .main
        titleLabel.text = title
        descriptionLabel.text = description
    }
}
