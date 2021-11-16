//
//  NewLocationViewController.swift
//  WeatherApp
//
//  Created by 林煜凱 on 11/12/21.
//
import CoreLocation
import UIKit

class NewLocationViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func Cancel(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    var weathersList: [Weather] = []
    var locationName: [String] = []
    var coordinate: Coordinate?
    var weatherAndCityNameCombineList: [WeatherAndCityNameCombine] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
        collectionView.dataSource = self
        
        getWeather()
    }
    override func viewDidLayoutSubviews() {
        view.backgroundColor = .mySkyblueColor
        collectionView.backgroundColor = .mySkyblueColor
        
    }
    func createLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        section.orthogonalScrollingBehavior = .continuous
        return UICollectionViewCompositionalLayout(section: section)
    }
    func getWeather() {
        guard let coordinate = coordinate else {
            return
        }

        WeatherApi.getWeather(coordinate: (lat: coordinate.lat, lon: coordinate.lon)){ result in
            switch result {
            case .success(let weatherInfo):
                self.weathersList.append(weatherInfo)
                
            case .failure(let error):
                print("vc...\(error)")
            }
            self.findCityNameFromCoordinate()
        }
    }
   
    func findCityNameFromCoordinate() {
        
        guard let coordinate = coordinate else {
            return
        }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.lat, longitude: coordinate.lon), preferredLocale: .current) { placemarks, error in
            print("new location vc placemarks \(placemarks)")
                if error == nil, let placemarks = placemarks?[0] {
                    var locationName: String
                    if placemarks.subAdministrativeArea != nil {
                        locationName = placemarks.subAdministrativeArea!
                    } else if placemarks.administrativeArea != nil {
                        locationName = placemarks.administrativeArea!
                    } else {
                        locationName = placemarks.country!
                    }
             
                    self.locationName.append(locationName)
                    self.weatherAndCityNameCombineList.append(WeatherAndCityNameCombine(weather: self.weathersList[0], cityName: locationName))
                }
            self.collectionView.reloadData()
        }
        
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let VC = segue.destination as! MainViewController
        VC.allCoordinate.insert(self.coordinate!)
        VC.weatherAndCityNameCombineList.append(contentsOf: self.weatherAndCityNameCombineList)
        VC.layoutType = 1
    }
}
extension NewLocationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherAndCityNameCombineList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        let weather = weatherAndCityNameCombineList[indexPath.row]
        cell.setupData(with: weather)
        
        return cell
    }
}
