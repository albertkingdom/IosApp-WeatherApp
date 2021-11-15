//
//  TestViewController.swift
//  WeatherApp
//
//  Created by 林煜凱 on 11/10/21.
//
import CoreLocation
import UIKit

class MainViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var functionBarView: UIView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBAction func searchLocation(_ sender: Any) {
        let searchVC = storyboard?.instantiateViewController(withIdentifier: "SearchLocationViewController") as! SearchLocationViewController
        present(searchVC, animated: true, completion: nil)
    }
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var BigCollectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func changeLayout(_ sender: Any) {

        switchLayout(from: 0, to: 1)
    }
    var layoutType = 0 // 0: default, 1: list
    
    var locationManager = CLLocationManager()
    //var currentLocation: CLLocation?
    var currentLocation: Coordinate?
    var allCoordinate: Set<Coordinate> = [Coordinate(lat: 24.2198468, lon: 120.67568)] {
        
        didSet {
            
            let defaults = UserDefaults.standard

            print("save to user default...\(allCoordinate)")
            do {
                let encodedData = try JSONEncoder().encode(allCoordinate)
                defaults.set(encodedData, forKey: "locationList")
            } catch {
                print(error.localizedDescription)
            }
            
            
        }
    
    }
    var weathersList: [Weather] = []
    var locationName: [String] = []
    var weatherAndCityNameCombineList: [WeatherAndCityNameCombine] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        let defaults = UserDefaults.standard
        if let userDefaultsData = defaults.object(forKey: "locationList") as? Data {

            do {
                let data = try JSONDecoder().decode(Set<Coordinate>.self, from: userDefaultsData)
                if data.count > 0 {
                    print("get from userdefault...\(data)")
                    allCoordinate = data
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        setupLocation()
        BigCollectionView.register(UINib(nibName: "ListTypeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ListTypeCollectionViewCell")
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "TestTableViewCell")
        
        BigCollectionView.setCollectionViewLayout(createLayout(), animated: false)
        
        
        BigCollectionView.dataSource = self
        BigCollectionView.delegate = self

        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.tableFooterView = UIView()
        
        self.searchButton.isHidden = true
        self.listButton.isHidden = false
        
        
       
        pageControl.setIndicatorImage(UIImage(systemName: "location.fill"), forPage: 0)
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.backgroundColor = .mySkyblueColor
        functionBarView.backgroundColor = .mySkyblueColor
        if layoutType == 1 {
         // let the height of tableview adjust with table view content
            tableViewHeight.constant = tableView.contentSize.height
        }
      
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        section.orthogonalScrollingBehavior = .paging
        return UICollectionViewCompositionalLayout(section: section)
    }
    // MARK: detect current location
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("location..\(locations)")
        
        
        if currentLocation == nil {
            let latest = locations.last
            //currentLocation = locations.last
            locationManager.stopUpdatingLocation()
            //print("location",currentLocation?.coordinate)
            let latitude = Double((latest?.coordinate.latitude)!)
            let longitude = Double((latest?.coordinate.longitude)!)
            currentLocation = Coordinate(lat: latitude, lon: longitude, current: true)
            
            requestWeatherInfo(coordinates: allCoordinate)
            

        }
        

        
        
    }
    func requestWeatherInfoForCurrentLocation() {
        guard let currentLocation = currentLocation else {
            return
        }

        WeatherApi.getWeather(coordinate: (lat: currentLocation.lat,lon: currentLocation.lon)) { result in

            switch result {
            case .success(let weatherInfo):
                
                //make sure current location weather is at index = 0
                self.weathersList.insert(weatherInfo, at: 0)
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                self.pageControl.numberOfPages = self.weathersList.count
            }
           
            
            self.findCityNameFromCoordinate()
            
        }
    }
    func requestWeatherInfo(coordinates: Set<Coordinate>) {
        
        WeatherApi.getMultipleWeather(coordinates: coordinates) { results in
          
            for result in results {
                switch result {
                case .success(let weatherInfo):
                    self.weathersList.append(weatherInfo)
                   
                case .failure(let error):
                    break
                }
            }

            self.requestWeatherInfoForCurrentLocation()
        }
    }
    
    func findCityNameFromCoordinate() {

        locationName = []
        weatherAndCityNameCombineList = []
 
        let group = DispatchGroup()
        for location in weathersList {
            group.enter()
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(CLLocation(latitude: location.lat, longitude: location.lon), preferredLocale: .current) { placemarks, error in

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

                    self.weatherAndCityNameCombineList.append(WeatherAndCityNameCombine(weather: location, cityName: locationName))
 
                }

                print("locationName...\(self.locationName)")
                group.leave()
            }
            group.wait()
            
        }
        group.notify(queue: .main) {
            print("complete find city name")
            self.BigCollectionView.reloadData()
            self.tableView.reloadData()
        }
       
        
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return weatherAndCityNameCombineList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        let weather = weatherAndCityNameCombineList[indexPath.row]
        cell.setupData(with: weather)
      
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.item
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherAndCityNameCombineList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestTableViewCell", for: indexPath) as! MainTableViewCell
        
        let weather = weatherAndCityNameCombineList[indexPath.row]
        cell.setupData(with: weather)
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switchLayout(from: 1, to: 0)
        BigCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle{
        case  .delete:
            weatherAndCityNameCombineList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            break
            
        }
    }
}
// MARK: navigation
extension MainViewController {
    @IBAction func unwindSegueBack(segue: UIStoryboardSegue){

        tableView.reloadData()
        
    }
}

extension MainViewController {
    func switchLayout(from currentLayoutType: Int, to targetLayoutType: Int) {
        if  currentLayoutType == 1 && targetLayoutType == 0 {
            layoutType = 0
            UIView.transition(from: tableView, to: BigCollectionView, duration: 0.25, options: [.transitionFlipFromBottom, .showHideTransitionViews], completion: nil)
            
            BigCollectionView.reloadData()
            searchButton.isHidden = true
            listButton.isHidden = false
            pageControl.isHidden = false
            pageControl.numberOfPages = self.weatherAndCityNameCombineList.count
            pageControl.setIndicatorImage(UIImage(systemName: "location.fill"), forPage: 0)
            tableViewHeight.constant = BigCollectionView.frame.height
        } else if currentLayoutType == 0 && targetLayoutType == 1 {
            self.layoutType = 1
            UIView.transition(from: BigCollectionView, to: tableView, duration: 0.25, options: [.transitionFlipFromBottom, .showHideTransitionViews], completion: nil)
            self.searchButton.isHidden = false
            self.listButton.isHidden = true
            tableView.reloadData()
            pageControl.isHidden = true
        }
    }
}
