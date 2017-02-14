//
//  ViewController.swift
//  iMuseum
//
//  Created by Valerie Greer on 2/13/17.
//  Copyright © 2017 Shane Empie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let hostName = "https://data.imls.gov/resource/et8i-mnha.json"
    var reachability :Reachability?
    var masterMuseumArray = [Museum]()
    
    @IBOutlet var museumTableView       :UITableView!
    @IBOutlet var networkStatusLabel    :UILabel!
    
    //MARK: - Core Methods
    
    func parseJson(data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            print("JSON:\(jsonResult)")
            let museumArray = jsonResult as! [[String:Any]]
            masterMuseumArray.removeAll()
            for museumDictionary in museumArray {
                guard let museumName = museumDictionary["commonname"] as? String else {
                    continue
                }
                guard let museumStreet = museumDictionary["location_1_address"] as? String else {
                    continue
                }
                guard let museumCity = museumDictionary["location_1_city"] as? String else {
                    continue
                }
                guard let museumState = museumDictionary["location_1_state"] as? String else {
                    continue
                }
                guard let museumZip = museumDictionary["location_1_zip"] as? String else {
                    continue
                }
                let newMuseum = Museum(museumName: museumName, museumStreet: museumStreet, museumCity: museumCity, museumState: museumState, museumZip: museumZip)
                masterMuseumArray.append(newMuseum)
            }
            DispatchQueue.main.async {
                self.museumTableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
        } catch {
            print("JSON Parsing Error")
        }
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }
    
    func getFile() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = hostName
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let receivedData = data else {
                print("No Data")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            if receivedData.count > 0 && error == nil {
                print("Received Data:\(receivedData)")
                let dataString = String.init(data: receivedData, encoding: .utf8)
                print("Got Data String:\(dataString!)")
                self.parseJson(data: receivedData)
            } else {
                print("Got Data of Length 0")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        task.resume()
    }
    
    //MARK: - Interactivity Methods
    
    @IBAction func getFilePressed(button: UIBarButtonItem) {
//        guard let reach = reachability else {
//            return
//        }
//        if reach.isReachable {
            getFile()
//        } else {
//            print("Host Not Reachable. Turn on the Internet")
//        }
        
    }
    
    //MARK: - Reachability Methods
    
    func setupReachability(hostName: String) {
        reachability = Reachability(hostname: hostName)
        reachability!.whenReachable = { reachability in
            DispatchQueue.main.async {
                self.updatedLabel(reachable: true, reachability: reachability)
            }
        }
        reachability!.whenUnreachable = { reachability in
            
        }
    }
    
    func startReachability() {
        do {
            try reachability!.startNotifier()
        } catch {
            networkStatusLabel.text = "Unable to Start Notifier"
            networkStatusLabel.textColor = .red
            return
        }
    }
    
    func updatedLabel(reachable: Bool, reachability: Reachability) {
        if reachable {
            if reachability.isReachableViaWiFi {
                networkStatusLabel.textColor = .green
            } else {
                networkStatusLabel.textColor = .blue
            }
        } else {
            networkStatusLabel.textColor = .red
        }
        networkStatusLabel.text = reachability.currentReachabilityString
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupReachability(hostName: hostName)
//        startReachability()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

extension ViewController :UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return masterMuseumArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MuseumTableViewCell
        let currentMuseum = masterMuseumArray[indexPath.row]
        cell.museumNameLabel!.text = currentMuseum.museumName
        cell.museumAddressLabel!.text = currentMuseum.museumFullAddress
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
}
