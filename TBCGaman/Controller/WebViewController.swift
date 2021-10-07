//
//  WebViewController.swift
//  TBC
//
//  Created by 近藤大伍 on 2021/09/26.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    var webView = WKWebView()
    let dismissButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = CGRect(x: 0, y: 80, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(webView)
      
        let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSeLCYhTUUlylzhLihV9uYa104YIFD-qJghLg9u1CXf3xPNK-w/viewform")
        let request = URLRequest(url: url!)
        webView.load(request)
        
        dismissButton.layer.frame = CGRect(x: 8, y: 37, width: 50, height: 50)
        dismissButton.setImage(UIImage(named: "multiply.circle"), for: .normal)
        dismissButton.addTarget(self,action: #selector(dismiss(_ :)),for: .touchUpInside)
        view.addSubview(dismissButton)
    }
    
    @objc func dismiss(_ sender:UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
