//
//  ImageCollectionController.swift
//  BackgroundTask
//
//  Created by Priyam Dutta on 23/05/20.
//
//

import UIKit
import BackgroundTasks

class ImageCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let logger = LoggerSetup.logger
    private var imagesArray: [UIImage] = []
    private lazy var imageUrls: [URL] = { getImageUrls() }()
    private let dispatchGroup: DispatchGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "doc.plaintext"), style: .plain, target: self, action: #selector(gotoLogs))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain, target: self, action: #selector(startDownload))
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIScene.didEnterBackgroundNotification, object: nil)
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "in.backgroundTask.fetch", using: nil) { (task) in
            self.logger.debug("👾 Task Identifier \(task.identifier)")
            self.handleBackgroundDownloadTask(task: task as! BGAppRefreshTask)
        }
    }
    
    @objc private func gotoLogs() {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let logVC = storyBoard.instantiateViewController(withIdentifier: "ViewController")
        self.present(logVC, animated: true, completion: nil)
    }
    
    private func getImageUrls() -> [URL] {
        if let plistFile = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let dictInfo = NSDictionary(contentsOfFile: plistFile), let urlStrings = dictInfo["ImageUrls"] as? [String] {
                return urlStrings.compactMap({URL(string: $0)})
            }
        }
        return []
    }
    
    @objc private func startDownload()  {
        for item in imageUrls {
            dispatchGroup.enter()
            NetworkManager.downloadImage(fromUrl: item) { [weak self] (image) in
                self?.dispatchGroup.leave()
                self?.addImageToCollection(image)
            }
        }
    }
    
    @objc func didEnterBackground() {
        scheduleBackgroundFetchTask()
    }
}

extension ImageCollectionController {
    
    private func handleBackgroundDownloadTask(task: BGAppRefreshTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
            NetworkManager.urlSession.invalidateAndCancel()
        }
        startDownload()
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.logger.debug("🍻 All download completed")
            task.setTaskCompleted(success: true)
        }
    }
    
    private func scheduleBackgroundFetchTask() {
        let backgroundTask = BGAppRefreshTaskRequest(identifier: "in.backgroundTask.fetch")
        backgroundTask.earliestBeginDate = Date(timeIntervalSinceNow: 60)
        do {
            try BGTaskScheduler.shared.submit(backgroundTask)
            logger.debug("🗂 Submitted schedule")
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ImageCollectionController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { imagesArray.count }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.cellImageView.image = imagesArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.bounds.width / 2.0) - 10.0
        return CGSize(width: width, height: width)
    }
}

extension ImageCollectionController {
    
    func addImageToCollection(_ image: UIImage) {
        
        func getCroppedImage(_ image: UIImage) -> UIImage {
            let width = (self.view.bounds.width / 2.0) - 10.0
            return UIImage(cgImage: (image.cgImage?.cropping(to: CGRect(x: 0.0, y: 0.0, width: width, height: width)))!)
        }
        
        imagesArray.append(getCroppedImage(image))
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: [IndexPath(item: imagesArray.count - 1, section: 0)])
        }, completion: nil)
    }
}
