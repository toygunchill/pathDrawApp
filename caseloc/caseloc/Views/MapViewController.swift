//
//  ViewController.swift
//  caseloc
//
//  Created by Toygun Çil on 16.03.2025.
//

import UIKit
import MapKit
import CoreLocation

final class MapViewController: UIViewController {
    
    // MARK: - UI Components
    private let mapView = MKMapView()
    private let locationButton = UIButton(type: .system)
    private let resetRouteButton = UIButton(type: .system)
    private let routeButton = UIButton(type: .system)
    private let trackingSwitch = UISwitch()
    private let trackingLabel = UILabel()
    
    // MARK: - Properties
    private var viewModel: MapViewModel
    private var shouldCenterOnLocation = false
    
    // MARK: - Initialization
    init(viewModel: MapViewModel = MapViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MapViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupLocationButton()
        setupResetRouteButton()
        setupRouteButton()
        setupTrackingSwitch()
        
        viewModel.delegate = self
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.requestLocationPermission()
    }
    
    // MARK: - Setup Methods
    private func setupMapView() {
        mapView.frame = view.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        view.addSubview(mapView)
    }
    
    private func setupLocationButton() {
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        locationButton.backgroundColor = .white
        locationButton.tintColor = .systemBlue
        locationButton.layer.cornerRadius = Constants.UI.buttonCornerRadius
        locationButton.layer.shadowColor = UIColor.black.cgColor
        locationButton.layer.shadowOpacity = 0.3
        locationButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        locationButton.layer.shadowRadius = 4
        
        view.addSubview(locationButton)
        
        NSLayoutConstraint.activate([
            locationButton.widthAnchor.constraint(equalToConstant: Constants.UI.buttonSize),
            locationButton.heightAnchor.constraint(equalToConstant: Constants.UI.buttonSize),
            locationButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.UI.standardPadding),
            locationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.UI.standardPadding)
        ])
        
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
    }
    
    private func setupResetRouteButton() {
        resetRouteButton.translatesAutoresizingMaskIntoConstraints = false
        resetRouteButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        resetRouteButton.backgroundColor = .white
        resetRouteButton.tintColor = .systemRed
        resetRouteButton.layer.cornerRadius = Constants.UI.buttonCornerRadius
        resetRouteButton.layer.shadowColor = UIColor.black.cgColor
        resetRouteButton.layer.shadowOpacity = 0.3
        resetRouteButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        resetRouteButton.layer.shadowRadius = 4
        
        view.addSubview(resetRouteButton)
        
        NSLayoutConstraint.activate([
            resetRouteButton.widthAnchor.constraint(equalToConstant: Constants.UI.buttonSize),
            resetRouteButton.heightAnchor.constraint(equalToConstant: Constants.UI.buttonSize),
            resetRouteButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.UI.standardPadding),
            resetRouteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.UI.standardPadding)
        ])
        
        resetRouteButton.addTarget(self, action: #selector(resetRouteButtonTapped), for: .touchUpInside)
    }
    
    private func setupTrackingSwitch() {
        trackingLabel.translatesAutoresizingMaskIntoConstraints = false
        trackingLabel.text = Constants.Messages.trackingOn
        trackingLabel.textColor = .black
        trackingLabel.backgroundColor = .white
        trackingLabel.layer.cornerRadius = 8
        trackingLabel.clipsToBounds = true
        trackingLabel.textAlignment = .center
        trackingLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        trackingSwitch.translatesAutoresizingMaskIntoConstraints = false
        trackingSwitch.isOn = true
        trackingSwitch.onTintColor = .systemBlue
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = Constants.UI.containerCornerRadius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        
        containerView.addSubview(trackingLabel)
        containerView.addSubview(trackingSwitch)
        
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: Constants.UI.switchContainerHeight),
            containerView.widthAnchor.constraint(equalToConstant: Constants.UI.switchContainerWidth),
            
            trackingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            trackingLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            trackingSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            trackingSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            trackingSwitch.leadingAnchor.constraint(equalTo: trackingLabel.trailingAnchor, constant: 8)
        ])
        
        trackingSwitch.addTarget(self, action: #selector(trackingSwitchChanged), for: .valueChanged)
    }
    
    @objc private func routeButtonTapped() {
        viewModel.toggleRouteVisibility()
    }
    
    private func setupRouteButton() {
        routeButton.translatesAutoresizingMaskIntoConstraints = false
        routeButton.setImage(UIImage(systemName: "map.fill"), for: .normal)
        routeButton.backgroundColor = .white
        routeButton.tintColor = .systemGreen
        routeButton.layer.cornerRadius = Constants.UI.buttonCornerRadius
        routeButton.layer.shadowColor = UIColor.black.cgColor
        routeButton.layer.shadowOpacity = 0.3
        routeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        routeButton.layer.shadowRadius = 4
        
        view.addSubview(routeButton)
        
        NSLayoutConstraint.activate([
            routeButton.widthAnchor.constraint(equalToConstant: Constants.UI.buttonSize),
            routeButton.heightAnchor.constraint(equalToConstant: Constants.UI.buttonSize),
            routeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            routeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.UI.standardPadding)
        ])
        
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
    }
    
    private func showPermissionAlert(message: String) {
        let alert = UIAlertController(
            title: Constants.Messages.permissionTitle,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ayarlar", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Action Methods
    @objc private func trackingSwitchChanged(_ sender: UISwitch) {
        viewModel.setTracking(enabled: sender.isOn)
    }
    
    @objc private func locationButtonTapped() {
        shouldCenterOnLocation = true
        
        if let userLocation = viewModel.getCurrentLocation() {
            centerMapOnUserLocation(location: userLocation)
        } else {
            viewModel.checkLocationPermission()
        }
    }
    
    @objc private func resetRouteButtonTapped() {
        let alertController = UIAlertController(
            title: Constants.Messages.resetRouteTitle,
            message: Constants.Messages.resetRouteMessage,
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Sıfırla", style: .destructive) { _ in
            self.viewModel.resetRoute()
        })
        
        present(alertController, animated: true)
    }
    
    // MARK: - Helper Methods
    private func centerMapOnUserLocation(location: CLLocation) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: Constants.Map.initialZoomSpan
        )
        mapView.setRegion(region, animated: true)
    }
    
    private func updateMap(with markers: [MKPointAnnotation]) {
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        mapView.addAnnotations(markers)
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = Constants.UI.toastCornerRadius
        toastLabel.clipsToBounds = true
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.UI.toastBottomMargin),
            toastLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 150),
            toastLabel.heightAnchor.constraint(equalToConstant: Constants.UI.toastHeight)
        ])
        
        UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

// MARK: - MapViewModelDelegate
extension MapViewController: MapViewModelDelegate {
    func viewModel(_ viewModel: MapViewModel, didUpdateMarkers markers: [MKPointAnnotation]) {
        updateMap(with: markers)
    }
    
    func viewModel(_ viewModel: MapViewModel, didChangeTrackingState isTracking: Bool) {
        if trackingSwitch.isOn != isTracking {
            trackingSwitch.setOn(isTracking, animated: true)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.trackingLabel.text = Constants.Messages.trackingOn
            self.trackingLabel.textColor = isTracking ? .black : .gray
        }
    }
    
    func viewModel(didResetRoute viewModel: MapViewModel) {
        updateMap(with: [])
        removeRoutePolyline()
        showToast(message: Constants.Messages.resetDone)
    }
    
    func viewModel(_ viewModel: MapViewModel, needsPermissionAlert message: String) {
        showPermissionAlert(message: message)
    }
    
    func viewModel(_ viewModel: MapViewModel, didToggleRouteVisibility isVisible: Bool, routePolyline: MKPolyline?) {
        if isVisible, let polyline = routePolyline {
            addRoutePolyline(polyline)
            routeButton.tintColor = .systemBlue
            showToast(message: Constants.Messages.routeDisplayed)
        } else {
            removeRoutePolyline()
            routeButton.tintColor = .systemGreen
            if routePolyline == nil && isVisible {
                showToast(message: Constants.Messages.routeNeedsMorePoints)
            } else if !isVisible {
                showToast(message: Constants.Messages.routeHidden)
            }
        }
    }
    
    func viewModel(_ viewModel: MapViewModel, didCalculateRouteStatistics statistics: RouteStatistics) {
        let routeStatsVC = RouteStatsSheetViewController(routeData: statistics)
        
        if #available(iOS 15.0, *) {
            if let sheet = routeStatsVC.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
            present(routeStatsVC, animated: true)
        } else {
            routeStatsVC.modalPresentationStyle = .pageSheet
            present(routeStatsVC, animated: true)
        }
    }
    
    private func addRoutePolyline(_ polyline: MKPolyline) {
        removeRoutePolyline()
        
        mapView.addOverlay(polyline)
        
        mapView.setVisibleMapRect(
            polyline.boundingMapRect,
            edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
            animated: true
        )
    }
    
    private func removeRoutePolyline() {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = Constants.Map.markerIdentifier
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.markerTintColor = .systemBlue
            
            let detailButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = detailButton
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation else { return }
        
        viewModel.getDetailedAddress(for: annotation) { detailedAddress in
            DispatchQueue.main.async {
                let alertController = UIAlertController(
                    title: annotation.title ?? "Konum",
                    message: detailedAddress,
                    preferredStyle: .alert
                )
                
                alertController.addAction(UIAlertAction(title: "Tamam", style: .default))
                self.present(alertController, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
