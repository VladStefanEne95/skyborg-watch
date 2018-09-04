//
//  InterfaceController.swift
//  SkyborgWatch WatchKit Extension
//
//  Created by BJN on 9/3/18.
//  Copyright © 2018 BJN. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    func currentTimeMiliseconds() -> Int64 {
        let currentDate = Date();
        let since1970 = currentDate.timeIntervalSince1970;
        return Int64(since1970)
    }
    @IBOutlet var orders: WKInterfaceLabel!
    @IBOutlet var units: WKInterfaceLabel!
    @IBOutlet var sales: WKInterfaceLabel!
    @IBOutlet var profit: WKInterfaceLabel!
    @IBAction func switchChange(_ value: Bool) {
        
        var request = URLRequest(url: URL(string: "https://staging.skyborg.io:8043/api/users/authorize")!)
        request.httpMethod = "POST"
        var params = ["email":"vlad_stefan95@yahoo.com", "password":"passw0rd#"] as Dictionary<String, String>

        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        var session = URLSession.shared

        //authozire/
        session.dataTask(with: request) {data, response, err in
            if err != nil {
                print(err)
            } else {
                do {
                    var parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    var responseData = parsedData["data"] as! [String:Any]

                    let clientId = responseData["clientId"]
                    let clientSecret = responseData["clientSecret"]

                    //token/
                    request = URLRequest(url: URL(string: "https://staging.skyborg.io:8043/api/oauth/token")!)
                    request.httpMethod = "POST"
                    params = ["grant_type":"password", "username":"vlad_stefan95@yahoo.com","password":"passw0rd#", "client_id":clientId, "client_secret":clientSecret] as! Dictionary<String, String>

                    request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                    session = URLSession.shared
                    session.dataTask(with: request) {data, response, err in
                        if err != nil {
                            print(err)
                        } else {
                            do {
                                var parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                                var accessToken = parsedData["access_token"] as! String

                                request = URLRequest(url: URL(string: "https://staging.skyborg.io:8043/api/organizations")!)
                                request.httpMethod = "GET"

                                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
                                session = URLSession.shared
                                session.dataTask(with: request) {data, response, err in
                                    if err != nil {
                                        print(err)
                                    } else {
                                        do {

                                            var parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                                            var responseData = parsedData["data"] as! [[String:Any]]
                                            let orderRequestUrl:String = "https://staging.skyborg.io:8043/api/orders/stats/beginDate:1536008400%7cendDate:" + String(self.currentTimeMiliseconds()) + "%7ctimeSet:s"
                                            
                                            request = URLRequest(url: URL(string: orderRequestUrl)!)
                                            request.httpMethod = "GET"
                                            
                                            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                            request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
                                            
                                            var marketPlaces = responseData[0]["marketPlaces"] as! [String]
                                            
                                            request.addValue(marketPlaces[2], forHTTPHeaderField: "Skyborg-Marketplace")
                                            request.addValue(responseData[0]["_id"] as! String, forHTTPHeaderField: "Skyborg-Organization")
                                            
                                            
                                            session = URLSession.shared
                                            session.dataTask(with: request) {data, response, err in
                                                if err != nil {
                                                    print(err)
                                                } else {
                                                    do {
                                                        var parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                                                        var responseData = parsedData["data"] as! [String:Any]
                                                        var ordersList = responseData["orders"] as! [String:Any]
                                                        var itemsList = responseData["items"] as! [String:Any]
                                                        self.orders.setText("Orders " + String(ordersList["no"] as! Int))
                                                        self.units.setText("Units " + String(itemsList["no"] as! Int))
                                                        self.profit.setText("Profit $" + String( (ordersList["profit"] as! NSNumber).floatValue ))
                                                        self.sales.setText("Sales $" + String( (ordersList["amount"] as! NSNumber).floatValue))
                                                        print(ordersList)
                                                        
                                                    } catch let error as NSError {
                                                        print(error)
                                                    }
                                                }
                                                }.resume()

                                            
                                            
                                            
                                            
                                            
                                        } catch let error as NSError {
                                            print(error)
                                        }
                                    }
                                    }.resume()

                                } catch let error as NSError {
                                    print(error)
                                }
                            }
                    }.resume()
                } catch let error as NSError {
                    print(error)
                }
            }

            }.resume()

        
    }
    @IBOutlet var textLabel: WKInterfaceLabel!
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
