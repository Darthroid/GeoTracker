//
//  NetworkManager.swift
//  gpstracky
//
//  Created by Oleg Komaristy on 04.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager {
    private enum APIAction {
        static var select: String { return "?action=select" }
        
    }
    
    public static func fetchTrackers(completion: @escaping ([String: [TrackerPoint]]?) -> Void)  {
        DispatchQueue.global(qos: .utility).async {
            Alamofire.request(API_URL + APIAction.select).responseJSON { responseData in
                guard let response = responseData.result.value else { completion(nil); return }
                let json = JSON(response)
                var data = [String: [TrackerPoint]]()
                for index in 0...json.count-1 {
                    let item = json[index]
                    
                    // TODO: refactor this
                    
                    if data[item["objectID"].stringValue] == nil {
                        data[item["objectID"].stringValue] = []
                    }
                    
                    data[item["objectID"].stringValue]?.append(TrackerPoint(latitude: item["latitude"].doubleValue, longitude: item["longitude"].doubleValue, date: item["date"].int64Value))
                }
                completion(data)
            }
        }
    }
}
