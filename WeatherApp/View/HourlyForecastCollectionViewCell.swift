//
//  HourlyForecastCollectionViewCell.swift
//  WeatherApp
//
//  Created by 林煜凱 on 11/9/21.
//

import UIKit

class HourlyForecastCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .mySkyblueColor
    }

    func configure(with weather: HourlyWeather){
//        backgroundColor = .gray
        frame.size.height = 120
//        self.timeLabel.text = "下午1點"
//        self.tempLabel.text = "19"
        let hour = getHour(time: weather.daytime)
        let url = URL(string: "https://openweathermap.org/img/wn/\(weather.weather[0].icon)@2x.png")
        
        self.timeLabel.text = "\(hour)時"
        self.tempLabel.text = String(format:"%.0fº",weather.temp)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                self.weatherImageView.image = UIImage(data: data!)
            }
        }
    }
    
    func getHour(time: Double)-> String{
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "HH"
           let hour = dateFormatter.string(from: Date(timeIntervalSince1970: time))

           return hour
     }
}
