//
//  SearchLocationViewController.swift
//  WeatherApp
//
//  Created by 林煜凱 on 11/11/21.
//

import UIKit

class SearchLocationViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var searchResults: [LocationResponse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        tableView.delegate = self
        tableView.dataSource = self
        // remove separator for empty cell
        tableView.tableFooterView = UIView()
    }
    

  
}
extension SearchLocationViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            LocationApi.searchCoordinate(locationName: searchText) { result in
                switch result {
                case .success(let location):
                    //print("location...\(location)")
                    self.searchResults = location
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
    
  
}

extension SearchLocationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell",for: indexPath)
        cell.textLabel?.text = searchResults[indexPath.row].name
        cell.detailTextLabel?.text = searchResults[indexPath.row].country
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let NewWeatherVC = storyboard?.instantiateViewController(withIdentifier: "NewLocationViewController") as! NewLocationViewController
        let select = searchResults[indexPath.row]
        NewWeatherVC.coordinate = Coordinate(lat: select.lat, lon: select.lon)
        present(NewWeatherVC, animated: true, completion: nil)
    }
}
