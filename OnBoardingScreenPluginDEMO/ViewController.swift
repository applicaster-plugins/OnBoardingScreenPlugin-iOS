//
//  ViewController
//  OnBoardingScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 4/3/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit
import CopaAmericaStatsScreenPlugin

class ViewController: UIViewController {
    @IBOutlet weak var configurationTextField: UITextField!
    @IBOutlet weak var parametersTextField: UITextField!
    var myPlugin: CopaAmericaStatsScreenPlugin?
    
    @IBAction func initializePluginClicked(_ sender: Any) {
        if let data = configurationTextField.text?.data(using: String.Encoding.utf8),
            let configuration = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
            myPlugin = CopaAmericaStatsScreenPlugin(nibName: nil, bundle: nil)
        } else {
            let alert = UIAlertController(title: nil, message: "Please enter a valid json in the configuration field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func handleURLSchemeClicked(_ sender: Any) {
        if let myPlugin = myPlugin {
            if let data = parametersTextField.text?.data(using: String.Encoding.utf8),
                let params = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary,
                let dictionaryParams = params {
                myPlugin.handleUrlScheme(dictionaryParams)
            } else {
                let alert = UIAlertController(title: nil, message: "Please enter a valid json in the configuration field", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: nil, message: "Please first initialize a plugin", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

