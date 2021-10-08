//
//  ShareViewController.swift
//  TBC
//
//  Created by 近藤大伍 on 2021/09/26.
//

import UIKit

class ShareViewController: UIViewController {


    @IBOutlet weak var screenshotImageView: UIImageView!
    
    var screenShotImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
  
    
    @IBAction func dismissView(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    

    @IBAction func imageShareButton(_ sender: Any) {
        
      
        
        let items = [screenShotImage] as [Any]
        
        //アクティビティビューに載せてシェア
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        present(activityVC, animated: true, completion: nil)
        
        
    }
    
    @IBAction func shareButton(_ sender: Any) {
        
        
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
