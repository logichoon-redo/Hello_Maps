//
//  ViewController.swift
//  MapsTest
//
//  Created by 이치훈 on 2023/04/07.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    //MARK: - Prooerties
    
    var locationManager = CLLocationManager()
    var mapView: MKMapView!
    var mapSegment: UISegmentedControl!
    var addAnnotation: UIButton!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        setLocationManager()
        
        configureSubviews()
    }

    //MARK: setLocationManager
    func setLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone //업데이트를 위한 이동해야하는 최소거리, kCLDistanceFilterNone을 설정함으로서 위치가 변경될 때 마다 업데이트됨
         
        locationManager.startUpdatingLocation()
    }
    
  //test  1
    
    @objc func changedMapStyl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.mapView.mapType = .standard
        case 1:
            self.mapView.mapType = .satellite
        case 2:
            self.mapView.mapType = .hybrid
        default:
            self.mapView.mapType = .standard
        }
    }
    
    @objc func addAnnotationButtonPressed() {
        let annotation = Annotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude:  36.3164, longitude: 127.4444)
        annotation.title = "My Annotatiom"
        annotation.subtitle = "subtitle"
        //annotation.imageURL = "pin@x3"
        mapView.addAnnotation(annotation)
    }
    
    private func configureView(_ annotationView: MKAnnotationView?) {
        
        let snapShotSize = CGSize(width: 200, height: 200)
        
        let snapShotView = UIView(frame: CGRect.zero)
        snapShotView.translatesAutoresizingMaskIntoConstraints = false
        snapShotView.widthAnchor.constraint(equalToConstant: snapShotSize.width).isActive = true
        snapShotView.heightAnchor.constraint(equalToConstant: snapShotSize.height).isActive = true
        
        let options = MKMapSnapshotter.Options()
        options.size = snapShotSize
        options.mapType = .satelliteFlyover
        options.camera = MKMapCamera(lookingAtCenter: (annotationView?.annotation?.coordinate)!, fromDistance: 10, pitch: 65, heading: 0)
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            
            if let snapshot = snapshot {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: snapShotSize.width, height: snapShotSize.height))
                imageView.image = snapshot.image
                snapShotView.addSubview(imageView)
            }
        }
        
        annotationView?.detailCalloutAccessoryView = snapShotView
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        view.subviews.forEach { subView in
            subView.removeFromSuperview()
        }
        
    }
    
}

//MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
}

//MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    /*
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        
        mapView.setRegion(region, animated: true)
    }*/
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { //사용자 위치엔 적용을 배재하기위한 로직
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Annotation") as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Annotation")
//            annotationView?.glyphText = "✈️"
//            annotationView?.glyphImage //imgae 삽입옵션
//            annotationView?.markerTintColor = .blue
//            annotationView?.glyphTintColor = .white //annotation안의 텍스트의 색상옵션
            
            annotationView?.canShowCallout = false
        }else{
            annotationView?.annotation = annotation
        }
        
//        if let isAnnotation = annotation as? Annotation {
//            annotationView?.image = UIImage(imageLiteralResourceName: isAnnotation.imageURL)
//        }
        
        //configureView(annotationView)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation as? Annotation else {
            return
        }
        
        let customCalloutView = UIView(frame: CGRect.zero)
        customCalloutView.translatesAutoresizingMaskIntoConstraints = false
        customCalloutView.layer.cornerRadius = 10.0
        customCalloutView.layer.masksToBounds = true
        customCalloutView.backgroundColor = .blue
        
        view.addSubview(customCalloutView)
        
        customCalloutView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -5).isActive = true
        customCalloutView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        customCalloutView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        customCalloutView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.textColor = .white
        titleLabel.text = annotation.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        customCalloutView.addSubview(titleLabel)
        
        titleLabel.centerXAnchor.constraint(equalTo: customCalloutView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: customCalloutView.centerYAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    
}

//MARK: - ConfigureSubviewsCase

extension ViewController: ConfigureSubviewsCase {
    func configureSubviews() {
        createSubviews()
        addSubviews()
        setupLayouts()
    }
    
    func createSubviews() {
        mapView = MKMapView(frame: view.frame)
        mapSegment = UISegmentedControl(items: ["Maps", "Satellite", "Hybrid"])
        addAnnotation = UIButton()
    }
    
    func addSubviews() {
        view.addSubview(mapView)
        view.addSubview(mapSegment)
        view.addSubview(addAnnotation)
    }
    
    func setupLayouts() {
        setupSubviewsLayouts()
        setupSubviewsConstraints()
    }
    
    
}

extension ViewController: SetupSubviewsLayouts {
    func setupSubviewsLayouts() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        mapSegment.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        mapSegment.selectedSegmentIndex = 0
        mapSegment.addTarget(self, action: #selector(changedMapStyl), for: .valueChanged)
        
        addAnnotation.setTitle("Add Annotation", for: .normal)
        addAnnotation.backgroundColor = .systemBlue
        addAnnotation.tintColor = .white
        addAnnotation.layer.cornerRadius = 10
        addAnnotation.addTarget(self, action: #selector(addAnnotationButtonPressed), for: .touchUpInside)
    }
    
    
}

extension ViewController: SetupSubviewsConstraints {
    func setupSubviewsConstraints() {
        mapSegment.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapSegment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapSegment.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            mapSegment.widthAnchor.constraint(equalToConstant: 200),
            mapSegment.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        addAnnotation.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addAnnotation.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            addAnnotation.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
}
