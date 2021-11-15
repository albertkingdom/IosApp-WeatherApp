//
//  TestCollectionViewCell.swift
//  WeatherApp
//
//  Created by 林煜凱 on 11/11/21.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    // current weather
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    // collection view for hourly weather
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentWeather: CurrentWeather?
    var dailyWeather: [DailyWeather]?
    var hourlyWeather: [HourlyWeather]?
    
    

    override func layoutSubviews() {
        super.layoutSubviews()
        topView.backgroundColor = .mySkyblueColor
        tableView.backgroundColor = .mySkyblueColor
        collectionView.backgroundColor = .mySkyblueColor
        
        collectionView.addTopBorder(with: UIColor.white, andWidth: 1)
        collectionView.addBottomBorder(with: UIColor.white, andWidth: 1)
        tableView.addBottomBorder(with: UIColor.white, andWidth: 1)
    }
    func setupData(with weatherInfo: WeatherAndCityNameCombine) {
        self.currentWeather = weatherInfo.weather.current
        self.dailyWeather = weatherInfo.weather.daily
        self.hourlyWeather = weatherInfo.weather.hourly
        //print("cell..daily weather..\(self.dailyWeather)")
        self.setupCurrentWeather()
        self.locationLabel.text = weatherInfo.cityName
        
        //
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "DailyForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "DailyForecastTableViewCell"
        )
        scrollView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        tableView.separatorStyle = .none
        scrollView.showsVerticalScrollIndicator = false
        collectionView.setCollectionViewLayout(self.createLayout(), animated: false)
        collectionView.register(UINib(nibName: "HourlyForecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HourlyForecastCollectionViewCell")

     
    }
    func setupCurrentWeather() {
        DispatchQueue.main.async {
            self.currentTempLabel.text = String(format: "%.0fº", self.currentWeather?.temp ?? 0)
            self.weatherDescriptionLabel.text = self.currentWeather?.weather[0].description
            
        }
    }
}

extension MainCollectionViewCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
   
        let offset = scrollView.contentOffset


        
        if offset.y > 150 {
            topViewHeight.constant = 100
           
        } else if offset.y > 0 {
            topViewHeight.constant = 250 - offset.y
            
        }
        

    }
}

extension MainCollectionViewCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return dailyWeather?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: "DailyForecastTableViewCell", for: indexPath) as! DailyForecastTableViewCell
            if let dailyWeather = dailyWeather{
                cell.configure(with: dailyWeather[indexPath.row])
            }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("section: \(indexPath.section), row: \(indexPath.row)")
    }
}


extension MainCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func createLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/5), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        section.orthogonalScrollingBehavior = .continuous
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyForecastCollectionViewCell", for: indexPath) as! HourlyForecastCollectionViewCell
        if let hourlyWeather = hourlyWeather{
            cell.configure(with: hourlyWeather[indexPath.row])
        }
        
        return cell
    }
}
