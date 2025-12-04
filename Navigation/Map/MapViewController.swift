//
//  MapViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.10.2025.
//

import UIKit
import MapKit
import CoreLocation

/// Экран с картой и построением маршрута от текущего местоположения до точки по долгому тапу.
final class MapViewController: UIViewController {

    // MARK: - UI

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.mapType = .mutedStandard
        map.showsUserLocation = true
        map.pointOfInterestFilter = .excludingAll
        map.showsScale = true
        map.showsCompass = true
        map.showsTraffic = false
        map.showsBuildings = true
        return map
    }()

    private let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Моё местоположение", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = AppFonts.bodyBold()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppColors.buttonBlue
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 4
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        return button
    }()

    // MARK: - Location

    private let locationManager = CLLocationManager()
    private var destinationCoordinate: CLLocationCoordinate2D?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Карта"
        view.backgroundColor = AppColors.background

        setupMapView()
        setupLocationButton()
        setupGestures()
        setupNavigationItems()
        configureLocationManager()
        checkLocationAuthorization()
    }

    // MARK: - Setup UI

    private func setupMapView() {
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        mapView.delegate = self
        mapView.cameraZoomRange = MKMapView.CameraZoomRange(
            minCenterCoordinateDistance: 500,
            maxCenterCoordinateDistance: 10_000
        )
    }

    private func setupLocationButton() {
        view.addSubview(locationButton)

        NSLayoutConstraint.activate([
            locationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        locationButton.addTarget(self, action: #selector(centerToUserLocation), for: .touchUpInside)
    }

    private func setupGestures() {
        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(addPin(_:))
        )
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
    }

    private func setupNavigationItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Очистить",
            style: .plain,
            target: self,
            action: #selector(clearAllPins)
        )
    }

    // MARK: - Location

    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Доступ к геолокации запрещён пользователем или ограничен")
        @unknown default:
            break
        }
    }

    // MARK: - Actions

    @objc private func addPin(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        let location = gesture.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

        destinationCoordinate = coordinate

        clearAllPins()

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Точка маршрута"
        mapView.addAnnotation(annotation)

        drawRoute(to: coordinate)
    }

    @objc private func clearAllPins() {
        let annotationsToRemove = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(annotationsToRemove)
        mapView.removeOverlays(mapView.overlays)
        destinationCoordinate = nil
    }

    @objc private func centerToUserLocation() {
        guard let location = locationManager.location else { return }

        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 1_000,
            longitudinalMeters: 1_000
        )
        mapView.setRegion(region, animated: true)
    }

    // MARK: - Routing

    private func drawRoute(to destinationCoordinate: CLLocationCoordinate2D) {
        guard let userLocation = locationManager.location?.coordinate else {
            print("Не удалось получить текущее местоположение")
            return
        }

        let sourcePlacemark = MKPlacemark(coordinate: userLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }

            if let error = error {
                print("Ошибка при построении маршрута: \(error.localizedDescription)")
                return
            }

            guard let route = response?.routes.first else {
                print("Маршрут не найден")
                return
            }

            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(route.polyline)

            self.mapView.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 40, left: 20, bottom: 80, right: 20),
                animated: true
            )
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 1_000,
            longitudinalMeters: 1_000
        )
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView,
                 rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = AppColors.accent
        renderer.lineWidth = 4
        return renderer
    }
}
