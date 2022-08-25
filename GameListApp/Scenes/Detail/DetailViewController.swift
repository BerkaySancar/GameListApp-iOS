//
//  DetailViewController.swift
//  GameListApp
//
//  Created by Berkay Sancar on 24.08.2022.
//

import Kingfisher
import SafariServices
import UIKit

final class DetailViewController: UIViewController {
    
    private let detailImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    private let detailName: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.bold)
        label.textColor = .label
        return label
    }()
    private let detailDescription: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .justified
        label.textColor = .label
        return label
    }()
    private let websiteButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.setTitle("Go to official website", for: UIControl.State.normal)
        button.setTitleColor(UIColor.systemRed, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
        return button
    }()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let activityIndicator = UIActivityIndicatorView()
    
    private let viewModel = DetailViewModel()
    
// MARK: - Init
    init(_ gameID: Int) {
        super.init(nibName: nil, bundle: nil)
        
        viewModel.getDetail(with: gameID)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setActivityIndicator()
        activityIndicator.startAnimating()
        
        viewModel.dataRefreshed = { [weak self] in
            self?.design()
            self?.configure()
            self?.activityIndicator.stopAnimating()
        }
        
        viewModel.dataNotRefreshed = { [weak self] in
            self?.errorMessage(title: "WARNING", message: "Game details could not load. Please try again.")
        }
    }
// MARK: - Activity Indicator
    private func setActivityIndicator() {
        view.backgroundColor = .systemBackground
        view.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(view)
            make.width.height.equalTo(68)
        }
    }
// MARK: - Ui Configure
    private func configure() {
        
        navigationItem.title = viewModel.detailName
        navigationController?.navigationBar.tintColor = .label
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(detailImage)
        contentView.addSubview(detailName)
        contentView.addSubview(detailDescription)
        contentView.addSubview(websiteButton)
        websiteButton.addTarget(self, action: #selector(websiteButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        
// MARK: Constraints
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.bottom.equalTo(view)
        }
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalTo(scrollView)
            make.left.right.equalTo(view)
        }
        detailImage.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.left.right.equalTo(contentView)
            make.height.equalTo(detailImage.snp.width)
        }
        detailName.snp.makeConstraints { make in
            make.top.equalTo(detailImage.snp.bottom).offset(10)
            make.centerX.equalTo(detailImage)
        }
        detailDescription.snp.makeConstraints { make in
            make.top.equalTo(detailName.snp.bottom).offset(12)
            make.left.right.equalTo(contentView).inset(20)
        }
        websiteButton.snp.makeConstraints { make in
            make.top.equalTo(detailDescription.snp.bottom).offset(10)
            make.left.right.equalTo(contentView).inset(20)
            make.bottom.equalTo(contentView).offset(-20)
        }
    }
    private func design() {
        
        if let url = URL(string: viewModel.detailBackgroundImage ?? "") {
            detailImage.kf.setImage(with: url)
        }
        detailName.text = viewModel.detailName ?? ""
        let descriptionText = viewModel.detailDescription?
            .replacingOccurrences(of: "<p>", with: "")
            .replacingOccurrences(of: "</p>", with: "")
            .replacingOccurrences(of: "<br>", with: "")
            .replacingOccurrences(of: "<br />", with: "")
        detailDescription.text = descriptionText
    }
// MARK: - Website Button Action & Safari Service
    @objc private func websiteButtonTapped(_ sender: UIButton) {
        
        if let url = URL(string: viewModel.detailWebsite ?? "") {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true)
        }
    }
}
