//
//  CallBackgroundSettingController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 9/17/25.
//

import UIKit
import EaseCallUIKit

class CallBackgroundSettingController: UIViewController {
    
    // MARK: - UI Components
    private let gradientLayer = UIImageView()
    private let navigationBar = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let confirmButton = UIButton(type: .system)
    
    private let centerContentView = UIView()
    private let leftArrowButton = UIButton(type: .system)
    private let rightArrowButton = UIButton(type: .system)
    private let backgroundTitleLabel = UILabel()
    private let instructionLabel = UILabel()
    
    private let bottomControlsView = UIView()
    private let hangUpButton = UIButton(type: .system)
    private let answerButton = UIButton(type: .system)
    private let hangUpLabel = UILabel()
    private let answerLabel = UILabel()
    
    private let homeIndicator = UIView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSavedBackground()
        setupConstraints()
        setupActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    // MARK: - Setup Methods
    private func loadSavedBackground() {
        // Load previously saved background
        currentBackgroundIndex = UserDefaults.standard.integer(forKey: "selectedCallBackgroundIndex")
        
        // Update display to show the correct background immediately
        backgroundTitleLabel.text = backgroundOptions[currentBackgroundIndex]
    }
    
    private func setupUI() {
        self.view.addSubview(gradientLayer)
        
        // Hide default navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        // Setup gradient background
        setupGradientBackground()
        
        // Setup navigation bar
        setupNavigationBar()
        
        // Setup center content
        setupCenterContent()
        
        // Setup bottom controls
        setupBottomControls()
        
        // Setup home indicator
        setupHomeIndicator()
    }
    
    private func setupGradientBackground() {
        gradientLayer.image = CallAppearance.backgroundImage
    }
    
    private func setupNavigationBar() {
        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Back button
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        navigationBar.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        titleLabel.text = "CallBackground".localized()
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleLabel.textAlignment = .center
        navigationBar.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Confirm button
        confirmButton.setTitle("确认", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        navigationBar.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupCenterContent() {
        view.addSubview(centerContentView)
        centerContentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Left arrow
        leftArrowButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        leftArrowButton.tintColor = .white
        leftArrowButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        leftArrowButton.layer.cornerRadius = 20
        centerContentView.addSubview(leftArrowButton)
        leftArrowButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Right arrow
        rightArrowButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        rightArrowButton.tintColor = .white
        rightArrowButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        rightArrowButton.layer.cornerRadius = 20
        centerContentView.addSubview(rightArrowButton)
        rightArrowButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Background title
        backgroundTitleLabel.text = "梦幻"
        backgroundTitleLabel.textColor = .white
        backgroundTitleLabel.font = UIFont.systemFont(ofSize: 48, weight: .medium)
        backgroundTitleLabel.textAlignment = .center
        centerContentView.addSubview(backgroundTitleLabel)
        backgroundTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Instruction label
        instructionLabel.text = "左右滑动查看更多"
        instructionLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        instructionLabel.font = UIFont.systemFont(ofSize: 14)
        instructionLabel.textAlignment = .center
        centerContentView.addSubview(instructionLabel)
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupBottomControls() {
        view.addSubview(bottomControlsView)
        bottomControlsView.translatesAutoresizingMaskIntoConstraints = false
        
        // Hang up button
        hangUpButton.backgroundColor = UIColor.callTheme.secondaryColor4
        hangUpButton.layer.cornerRadius = 35
        hangUpButton.setImage(UIImage(systemName: "phone.down.fill"), for: .normal)
        hangUpButton.tintColor = .white
        bottomControlsView.addSubview(hangUpButton)
        hangUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Hang up label
        hangUpLabel.text = "挂断"
        hangUpLabel.textColor = .white
        hangUpLabel.font = UIFont.systemFont(ofSize: 14)
        hangUpLabel.textAlignment = .center
        bottomControlsView.addSubview(hangUpLabel)
        hangUpLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Answer button
        answerButton.backgroundColor = UIColor.theme.errorColor6
        answerButton.layer.cornerRadius = 35
        answerButton.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        answerButton.tintColor = .white
        bottomControlsView.addSubview(answerButton)
        answerButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Answer label
        answerLabel.text = "接听"
        answerLabel.textColor = .white
        answerLabel.font = UIFont.systemFont(ofSize: 14)
        answerLabel.textAlignment = .center
        bottomControlsView.addSubview(answerLabel)
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupHomeIndicator() {
        homeIndicator.backgroundColor = .white
        homeIndicator.layer.cornerRadius = 2.5
        view.addSubview(homeIndicator)
        homeIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        // Navigation bar constraints
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Back button constraints
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Title constraints
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor)
        ])
        
        // Confirm button constraints
        NSLayoutConstraint.activate([
            confirmButton.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -16),
            confirmButton.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor)
        ])
        
        // Center content constraints
        NSLayoutConstraint.activate([
            centerContentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerContentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerContentView.widthAnchor.constraint(equalToConstant: 300),
            centerContentView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        // Left arrow constraints
        NSLayoutConstraint.activate([
            leftArrowButton.leadingAnchor.constraint(equalTo: centerContentView.leadingAnchor),
            leftArrowButton.centerYAnchor.constraint(equalTo: centerContentView.centerYAnchor),
            leftArrowButton.widthAnchor.constraint(equalToConstant: 40),
            leftArrowButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Right arrow constraints
        NSLayoutConstraint.activate([
            rightArrowButton.trailingAnchor.constraint(equalTo: centerContentView.trailingAnchor),
            rightArrowButton.centerYAnchor.constraint(equalTo: centerContentView.centerYAnchor),
            rightArrowButton.widthAnchor.constraint(equalToConstant: 40),
            rightArrowButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Background title constraints
        NSLayoutConstraint.activate([
            backgroundTitleLabel.centerXAnchor.constraint(equalTo: centerContentView.centerXAnchor),
            backgroundTitleLabel.topAnchor.constraint(equalTo: centerContentView.topAnchor, constant: 10)
        ])
        
        // Instruction label constraints
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: centerContentView.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: backgroundTitleLabel.bottomAnchor, constant: 8)
        ])
        
        // Bottom controls constraints
        NSLayoutConstraint.activate([
            bottomControlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomControlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomControlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomControlsView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Hang up button constraints
        NSLayoutConstraint.activate([
            hangUpButton.leadingAnchor.constraint(equalTo: bottomControlsView.leadingAnchor, constant: 80),
            hangUpButton.topAnchor.constraint(equalTo: bottomControlsView.topAnchor),
            hangUpButton.widthAnchor.constraint(equalToConstant: 70),
            hangUpButton.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // Hang up label constraints
        NSLayoutConstraint.activate([
            hangUpLabel.centerXAnchor.constraint(equalTo: hangUpButton.centerXAnchor),
            hangUpLabel.topAnchor.constraint(equalTo: hangUpButton.bottomAnchor, constant: 8)
        ])
        
        // Answer button constraints
        NSLayoutConstraint.activate([
            answerButton.trailingAnchor.constraint(equalTo: bottomControlsView.trailingAnchor, constant: -80),
            answerButton.topAnchor.constraint(equalTo: bottomControlsView.topAnchor),
            answerButton.widthAnchor.constraint(equalToConstant: 70),
            answerButton.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // Answer label constraints
        NSLayoutConstraint.activate([
            answerLabel.centerXAnchor.constraint(equalTo: answerButton.centerXAnchor),
            answerLabel.topAnchor.constraint(equalTo: answerButton.bottomAnchor, constant: 8)
        ])
        
        // Home indicator constraints
        NSLayoutConstraint.activate([
            homeIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            homeIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            homeIndicator.widthAnchor.constraint(equalToConstant: 134),
            homeIndicator.heightAnchor.constraint(equalToConstant: 5)
        ])
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        leftArrowButton.addTarget(self, action: #selector(leftArrowTapped), for: .touchUpInside)
        rightArrowButton.addTarget(self, action: #selector(rightArrowTapped), for: .touchUpInside)
        hangUpButton.addTarget(self, action: #selector(hangUpTapped), for: .touchUpInside)
        answerButton.addTarget(self, action: #selector(answerTapped), for: .touchUpInside)
        
        // Add swipe gestures
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeLeft.direction = .left
        centerContentView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeRight.direction = .right
        centerContentView.addGestureRecognizer(swipeRight)
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func confirmButtonTapped() {
        // Save current background selection
        UserDefaults.standard.set("bg\(currentBackgroundIndex + 1)", forKey: "CallBackgroundImageName")
        UserDefaults.standard.set(currentBackgroundIndex, forKey: "selectedCallBackgroundIndex")
        CallAppearance.backgroundImage = UIImage(named: "bg\(currentBackgroundIndex + 1)")
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func leftArrowTapped() {
        // Handle left arrow tap
        switchToPreviousBackground()
    }
    
    @objc private func rightArrowTapped() {
        // Handle right arrow tap
        switchToNextBackground()
    }
    
    @objc private func swipeLeft() {
        switchToNextBackground()
    }
    
    @objc private func swipeRight() {
        switchToPreviousBackground()
    }
    
    @objc private func hangUpTapped() {
        // Handle hang up action
        print("Hang up tapped")
    }
    
    @objc private func answerTapped() {
        // Handle answer action
        print("Answer tapped")
    }
    
    // MARK: - Background Switching
    private let backgroundOptions = ["梦幻", "极光", "银河", "夜曲", "碳纤维", "抽象流体", "虫洞"]
    private var currentBackgroundIndex = 0
    
    private func switchToNextBackground() {
        currentBackgroundIndex = (currentBackgroundIndex + 1) % backgroundOptions.count
        updateBackgroundDisplay()
    }
    
    private func switchToPreviousBackground() {
        currentBackgroundIndex = (currentBackgroundIndex - 1 + backgroundOptions.count) % backgroundOptions.count
        updateBackgroundDisplay()
    }
    
    private func updateBackgroundDisplay() {
        UIView.animate(withDuration: 0.3) {
            self.backgroundTitleLabel.alpha = 0
            self.gradientLayer.image = UIImage(named: "bg\(self.currentBackgroundIndex + 1)")
        } completion: { _ in
            self.backgroundTitleLabel.text = self.backgroundOptions[self.currentBackgroundIndex]
            UIView.animate(withDuration: 0.3) {
                self.backgroundTitleLabel.alpha = 1
            }
        }
    }
    
    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
