//
//  ViewController.swift
//  BackgroundTask
//
//  Created by Priyam Dutta on 23/05/20.
//
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTextView.backgroundColor = .systemGray6
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LoggerSetup.getLogs { [weak self] (logs) in
            if let weakSelf = self {
                weakSelf.logTextView.text = logs
            }
        }
    }

    @IBAction func actionClearLog(_ sender: Any) {
        do {
            try "".write(to: LoggerSetup.logFile, atomically: false, encoding: .utf8)
            self.logTextView.text = ""
        } catch {
            print(error)
        }
    }
}

