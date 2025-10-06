//
//  MapViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.10.2025.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private var destinationCoordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Карта"
        view.backgroundColor = .white

        setupMapView()
        checkLocationAuthorization()

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPin(_:)))
        mapView.addGestureRecognizer(longPressGesture)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Очистить",
            style: .plain,
            target: self,
            action: #selector(clearAllPins)
        )

        let locationButton = UIButton(type: .system)
        locationButton.setTitle("Моё местоположение", for: .normal)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.addTarget(self, action: #selector(centerToUserLocation), for: .touchUpInside)
        view.addSubview(locationButton)

        NSLayoutConstraint.activate([
            locationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            locationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupMapView() {
        mapView.frame = view.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.mapType = .mutedStandard
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsTraffic = false
        mapView.showsBuildings = true
        view.addSubview(mapView)
        mapView.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 500, maxCenterCoordinateDistance: 10000)
    }

    private func checkLocationAuthorization() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }

    @objc private func addPin(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

            clearAllPins()

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Точка маршрута"
            mapView.addAnnotation(annotation)

            drawRoute(to: coordinate)
        }
    }

    @objc private func clearAllPins() {
        let annotationsToRemove = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(annotationsToRemove)
        mapView.removeOverlays(mapView.overlays)
    }

    @objc private func centerToUserLocation() {
        guard let location = locationManager.location else { return }
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }

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
                edgePadding: UIEdgeInsets(top: 40, left: 20, bottom: 60, right: 20),
                animated: true
            )
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 4
        return renderer
    }
}
