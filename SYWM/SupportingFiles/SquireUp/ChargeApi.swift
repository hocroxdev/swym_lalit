//
//  Copyright © 2018 Square, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

class ChargeApi {
    static public func processPayment(_ nonce: String, completion: @escaping (String?, String?) -> Void) {
        let url = URL(string: Square.CHARGE_URL)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        let json = ["nonce": nonce]
        let httpBody = try? JSONSerialization.data(withJSONObject: json)
        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("en", forHTTPHeaderField: "content-language")
        if let token = DataManager.accessToken {
            request.addValue("Authorization", forHTTPHeaderField: "Bearer \(token)")
//            headers["Authorization"] = "Bearer \(token)"
        }
        print("url........\(url)")
        print("nounce........\(json)")
        print("http body.......\(httpBody)")
        print("request.......\(request)")
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if error  != nil{
                completion("", "Something went wrong")
            } else if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    print("Response from payment API.....\(json)")
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        DispatchQueue.main.async {
                            
                            completion("success", nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion("", "Something went wrong")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion("", "Something went wrong")
                    }
                }
            }
        }.resume()
    }
}
