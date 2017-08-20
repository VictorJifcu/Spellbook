//
//  MainViewController.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-08-16.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class MainViewController: UIViewController {

    var dataViewController = TabbedViewController()
    @IBOutlet weak var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loadData(_ sender: Any) {
        DBChooser.default().open(for: DBChooserLinkTypeDirect, from: self, completion: {(results: [Any]!) -> Void in
            guard let result = results.first as? DBChooserResult else{
                return
            }
            
            self.showLoadingHUD()
            
            Alamofire.request(result.link).responseString{ response in
                self.dataViewController.loadData(response: response.result.value!)
                self.hideLoadingHUD()
            }
            
        })

    }

    @IBAction func resetData(_ sender: Any) {
        showLoadingHUD()
        dataViewController.loadData(response: nil)
        hideLoadingHUD()
    }
    
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showAdded(to: loadingView, animated: true)
        hud.label.text = "Loading..."
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hide(for: loadingView, animated: true)
    }
    
}
