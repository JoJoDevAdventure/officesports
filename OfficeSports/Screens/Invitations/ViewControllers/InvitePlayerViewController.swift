//
//  InvitePlayerViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 25/05/2022.
//

import UIKit
import Combine

private let kBackgroundMaxFade: CGFloat = 0.6
private let kBackgroundMinFade: CGFloat = 0
private let kAnimDuration: TimeInterval = 0.15
private let kAnimDelay: TimeInterval = 0

private let profileImageDiameter: CGFloat = 100
private let profileImageRadius: CGFloat = profileImageDiameter / 2

final class InvitePlayerViewController: UIViewController {
    
    private lazy var backgroundView: UIView = {
        let view = UIView.createView(.black)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(tapRecognizer)
        view.alpha = 0
        return view
    }()
    
    private lazy var dialogView: UIView = {
        let view = UIView.createView(.white)
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var contentWrap: UIView = {
        return UIView.createView(.clear)
    }()
    
    private lazy var profileImageWrap: UIView = {
        let imageWrap = UIView.createView(.white)
        imageWrap.applyCornerRadius(profileImageRadius)
        imageWrap.applyMediumDropShadow(.black)
        return imageWrap
    }()
    
    private lazy var profileImageBackground: UIView = {
        let profileColor = UIColor.OS.hashedProfileColor(nickname: player.nickname)
        let profileImageBackground = UIView.createView(profileColor)
        profileImageBackground.applyCornerRadius((profileImageDiameter - 16) / 2)
        return profileImageBackground
    }()
    
    private lazy var profileEmjoiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 60)
        return label
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 26, weight: .medium)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var totalScoreLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.subtitle, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 24)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var inviteButton: UIButton = {
        let button = UIButton.createButton(UIColor.OS.General.main, .white, title: "Invite to match")
        button.addTarget(self, action: #selector(inviteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
    }()
    
    private lazy var dialogBottomConstraint: NSLayoutConstraint = {
        let constraint = dialogView.topAnchor.constraint(equalTo: view.bottomAnchor)
        constraint.constant = dialogHideConstant
        return constraint
    }()
    
    private let dialogHideConstant: CGFloat = 0
    private var dialogShowConstant: CGFloat {
        return -dialogView.frame.height
    }
    
    private var subscribers: [AnyCancellable] = []
    
    private let viewModel: InvitePlayerViewModel
    private let player: OSPlayer
    private let sport: OSSport
    
    init(viewModel: InvitePlayerViewModel, player: OSPlayer, sport: OSSport) {
        self.viewModel = viewModel
        self.player = player
        self.sport = sport
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        configureUI()
        
        // setup subscribers
        viewModel.$shouldToggleLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isHidden, on: inviteButton)
            .store(in: &subscribers)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleDialog(enabled: true)
    }
    
    private func setupChildViews() {
        view.addSubview(backgroundView)
        view.addSubview(dialogView)
        dialogView.addSubview(contentWrap)
        contentWrap.addSubview(profileImageWrap)
        contentWrap.addSubview(nicknameLabel)
        contentWrap.addSubview(totalScoreLabel)
        contentWrap.addSubview(inviteButton)
        profileImageWrap.addSubview(profileImageBackground)
        
        NSLayoutConstraint.pinToView(profileImageBackground, profileEmjoiLabel)
        
        NSLayoutConstraint.activate([
            backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dialogView.leftAnchor.constraint(equalTo: view.leftAnchor),
            dialogView.rightAnchor.constraint(equalTo: view.rightAnchor),
            dialogBottomConstraint,
            contentWrap.leftAnchor.constraint(equalTo: dialogView.leftAnchor),
            contentWrap.rightAnchor.constraint(equalTo: dialogView.rightAnchor),
            contentWrap.topAnchor.constraint(equalTo: dialogView.topAnchor),
            contentWrap.bottomAnchor.constraint(equalTo: dialogView.safeAreaLayoutGuide.bottomAnchor),
            profileImageWrap.widthAnchor.constraint(equalToConstant: profileImageDiameter),
            profileImageWrap.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 32),
            profileImageWrap.heightAnchor.constraint(equalTo: profileImageWrap.widthAnchor),
            profileImageWrap.centerXAnchor.constraint(equalTo: contentWrap.centerXAnchor),
            profileImageBackground.leftAnchor.constraint(equalTo: profileImageWrap.leftAnchor, constant: 8),
            profileImageBackground.rightAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: -8),
            profileImageBackground.topAnchor.constraint(equalTo: profileImageWrap.topAnchor, constant: 8),
            profileImageBackground.bottomAnchor.constraint(equalTo: profileImageWrap.bottomAnchor, constant: -8),
            nicknameLabel.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            nicknameLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            nicknameLabel.topAnchor.constraint(equalTo: profileImageWrap.bottomAnchor, constant: 16),
            totalScoreLabel.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            totalScoreLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            totalScoreLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 6),
            inviteButton.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            inviteButton.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            inviteButton.topAnchor.constraint(equalTo: totalScoreLabel.bottomAnchor, constant: 32),
            inviteButton.bottomAnchor.constraint(equalTo: contentWrap.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            inviteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
        profileEmjoiLabel.text = player.emoji
        nicknameLabel.text = player.nickname
    }
    
    private func toggleDialog(enabled: Bool) {
        if enabled {
            dialogBottomConstraint.constant = dialogShowConstant
        } else {
            dialogBottomConstraint.constant = dialogHideConstant
        }
        toggleBackgroundView(enabled: enabled)
        UIView.animate(
            withDuration: kAnimDuration,
            delay: kAnimDelay,
            options: [.curveEaseOut]) {
                self.view.layoutIfNeeded()
            } completion: {_ in
                if !enabled {
                    self.dismiss()
                }
            }
    }
    
    private func toggleBackgroundView(enabled: Bool) {
        UIView.animate(withDuration: kAnimDuration) {
            self.backgroundView.alpha = enabled ? kBackgroundMaxFade : kBackgroundMinFade
        }
    }
    
    private func dismiss() {
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Button Handling
    
    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        toggleDialog(enabled: false)
    }
    
    @objc private func inviteButtonTapped(_ sender: UIButton) {
        viewModel.invitePlayer(player, sport: sport)
    }
}

// MARK: - Invite Player Delegate Conformance

extension InvitePlayerViewController: InvitePlayerViewModelDelegate {
    
    func invitePlayerSuccess() {
        let message = OSMessage("You have invited \(player.nickname) to a game of \(sport.humanReadableName)", .success)
        Coordinator.global.showMessage(message)
        dismiss()
    }
    
    func invitePlayerFailed(with error: Error) {
        Coordinator.global.showMessage(OSMessage(error.localizedDescription, .failure))
    }
}
