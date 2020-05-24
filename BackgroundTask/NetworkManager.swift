//
//  NetworkManager.swift
//  BackgroundTask
//
//  Created by Priyam Dutta on 23/05/20.
//      
//

import Foundation
import UIKit

class NetworkManager {
    
    private static let logger = LoggerSetup.logger
    static let urlSession: URLSession = URLSession(configuration: .default)
    
    static func downloadImage(fromUrl url: URL, completion: @escaping (_ image: UIImage) -> Void) {
        let task = urlSession.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                Self.logger.debug("✅ Download from: \(response!.url!.absoluteString)")
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
        task.resume()
    }
}
