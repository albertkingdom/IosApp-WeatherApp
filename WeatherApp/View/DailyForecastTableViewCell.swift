//
//  DaylyForecastTableViewCell.swift
//  WeatherApp
//
//  Created by 林煜凱 on 11/9/21.
//

import UIKit

class DailyForecastTableViewCell: UITableViewCell {
    
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var highTempLabel: UILabel!
    @IBOutlet var lowTempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .mySkyblueColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with dailyweather: DailyWeather) {
        
        let weekday = getWeekDay(time: dailyweather.daytime)
        let url = URL(string: "https://openweathermap.org/img/wn/\(dailyweather.weather[0].icon)@2x.png")
        
     
        self.dayLabel.text = weekday
        self.highTempLabel.text = String(format: "%.0f", dailyweather.temp["max"] ?? 30.0)
        self.lowTempLabel.text = String(format: "%.0f", dailyweather.temp["min"] ?? 30.0)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                self.weatherImageView.image = UIImage(data: data!)
            }
        }
    }
    
    func getWeekDay(time: Double)-> String{
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "EEEE"
           let weekDay = dateFormatter.string(from: Date(timeIntervalSince1970: time))

           return weekDay
     }
}
