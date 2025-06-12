//
//  LaunchScreenViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/5/25.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        
        Task {
            do {
                // Network
                // CoreData

                await MainActor.run {
                    self.performSegue(withIdentifier: "ReplaceSegue", sender: nil)
                }
            } catch {
                print("SplashView fetch Error: \(error)")
            }
        }
    }
    
    // MARK: - UI Configuration
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "PICK A VIEW"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Layout
    
    /// 기본 UI 컴포넌트의 제약조건을 설정.
    private func setupLayout() {
        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(titleLabel)
        view.addSubview(stackView)

        view.backgroundColor = .systemBackground

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),

            logoImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.8),
            logoImageView.widthAnchor.constraint(equalTo: logoImageView.heightAnchor, multiplier: 2.0)
        ])
    }
}
