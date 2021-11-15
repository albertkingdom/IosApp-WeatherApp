//
//  MainTableViewCell.swift
//  WeatherApp
//
//  Created by 林煜凱 on 11/12/21.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var currentWeather: CurrentWeather?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .mySkyblueColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setupData(with weatherInfo: WeatherAndCityNameCombine) {
        let time = formatTime(time: weatherInfo.weather.current.dt)
        self.currentWeather = weatherInfo.weather.current
        self.tempLabel.text = String(format: "%.0fº", self.currentWeather?.temp ?? 0)
        self.cityNameLabel.text = weatherInfo.cityName
        self.timeLabel.text = time
    }
    
    func formatTime(time: Double) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_TW")


        dateFormatter.dateFormat = "a h:mm"

        //dateFormatter.amSymbol = "am"
        //dateFormatter.pmSymbol = "pm"

        var dateStr = dateFormatter.string(from: Date(timeIntervalSince1970: time))
        
        return dateStr
    }
}
