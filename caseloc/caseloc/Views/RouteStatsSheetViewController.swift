//
//  views.swift
//  caseloc
//
//  Created by Toygun Çil on 18.03.2025.
//

import UIKit
import CoreLocation

class RouteStatsSheetViewController: UIViewController {
    
    // MARK: - UI Components
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let distanceLabel = UILabel()
    private let speedLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    // MARK: - Properties
    private var routeData: RouteStatistics
    
    // MARK: - Initialization
    init(routeData: RouteStatistics) {
        self.routeData = routeData
        super.init(nibName: nil, bundle: nil)
        
        if #available(iOS 15.0, *) {
            if let sheet = sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateStats()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        view.addSubview(contentView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = Constants.Messages.routeStatsTitle
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 16)
        timeLabel.numberOfLines = 0
        contentView.addSubview(timeLabel)
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.font = UIFont.systemFont(ofSize: 16)
        distanceLabel.numberOfLines = 0
        contentView.addSubview(distanceLabel)
        
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        speedLabel.font = UIFont.systemFont(ofSize: 16)
        speedLabel.numberOfLines = 0
        contentView.addSubview(speedLabel)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Kapat", for: .normal)
        closeButton.backgroundColor = .systemBlue
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 10
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        contentView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            distanceLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 15),
            distanceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            distanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            speedLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 15),
            speedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            speedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            closeButton.topAnchor.constraint(greaterThanOrEqualTo: speedLabel.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 120),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func updateStats() {
        timeLabel.attributedText = createAttributedString(
            title: "🕒 Toplam Süre: ",
            value: formatDuration(routeData.totalDuration)
        )
        
        distanceLabel.attributedText = createAttributedString(
            title: "📏 Toplam Mesafe: ",
            value: formatDistance(routeData.totalDistance)
        )
        
        speedLabel.attributedText = createAttributedString(
            title: "⚡ Ortalama Hız: ",
            value: formatSpeed(routeData.averageSpeed)
        )
    }
    
    // MARK: - Helper Methods
    private func createAttributedString(title: String, value: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: title, attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
        ])
        
        attributedString.append(NSAttributedString(string: value, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
        ]))
        
        return attributedString
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours) saat \(minutes) dakika"
        } else {
            return "\(minutes) dakika"
        }
    }
    
    private func formatDistance(_ meters: CLLocationDistance) -> String {
        if meters >= 1000 {
            let kilometers = meters / 1000
            return String(format: "%.2f km", kilometers)
        } else {
            return String(format: "%.0f m", meters)
        }
    }
    
    private func formatSpeed(_ metersPerSecond: Double) -> String {
        let kmPerHour = metersPerSecond * 3.6
        return String(format: "%.2f km/sa", kmPerHour)
    }
    
    // MARK: - Action Methods
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}
