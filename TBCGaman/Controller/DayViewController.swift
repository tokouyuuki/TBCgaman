//
//  DayViewController.swift
//  TBC
//
//  Created by 近藤大伍 on 2021/09/26.
//

import UIKit

class DayViewController: UIViewController {
    
    @IBOutlet weak var swipeCard: UIView!
    @IBOutlet weak var kinenButton: UIButton!
    @IBOutlet weak var kitsuenButton: UIButton!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var swipeView: UIView!
    var buttonAnimated = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipeRecognizer = UISwipeGestureRecognizer(target:self, action: #selector(leftSwipe(_:)))
        leftSwipeRecognizer.direction = .left
        kitsuenButton.addGestureRecognizer(leftSwipeRecognizer)
        
        let rightSwipeRecognizer = UISwipeGestureRecognizer(target:self, action: #selector(rightSwipe(_:)))
        rightSwipeRecognizer.direction = .right
        kinenButton.addGestureRecognizer(rightSwipeRecognizer)
        
        swipeCard.layer.cornerRadius = 10
        swipeCard.layer.shadowOffset = CGSize(width: 0, height: 1)
        swipeCard.layer.shadowOpacity = 0.5
        swipeCard.layer.shadowRadius = 1.0
        swipeView.layer.cornerRadius = 10
        
        numberView.isHidden = true
        
//        kinenButton.addTarget(self,action: #selector(tapKinenButton(_ :)),for: .touchDown)
//        kitsuenButton.addTarget(self,action: #selector(tapKitsuenButton(_ :)),for: .touchDown)

        
        
    }
    
//    @objc func tapKinenButton(_ sender: UIButton){
//
//        UIView.animate(withDuration: 0.1,delay: 0.0,options:UIView.AnimationOptions.curveEaseIn,
//            animations: {() -> Void in
//                self.swipeCard.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//                self.swipeCard.alpha = 0.7
//
//            }
//            ,completion: nil
//        )
//
//    }

//    @objc func tapKitsuenButton(_ sender:UIButton){
//
//        UIView.animate(withDuration: 0.1,delay: 0.0,options:UIView.AnimationOptions.curveEaseIn,
//            animations: {() -> Void in
//                let transform = CGAffineTransform(translationX: 174, y: 0)
//                self.swipeCard.transform = transform
//                self.swipeCard.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//                self.swipeCard.alpha = 0.7
//
//            }
//            ,completion: nil
//        )
//
//    }
//    func returnAnimation(_ sender:UIView){
//
//    UIView.animate(withDuration:0.1,delay:0.0,options:UIView.AnimationOptions.curveEaseIn,animations: {() -> Void in
//                    sender.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//                    sender.alpha = 1
//                },
//                completion: nil
//            )
//
//    }
    
    func leftAnimation(){
        
        UIView.animate(withDuration: 0.2) {
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.swipeCard.transform = transform
        }
        
    }
    
    func rightAnimation(){
        
        UIView.animate(withDuration: 0.2) {
            let transform = CGAffineTransform(translationX: 174, y: 0)
            self.swipeCard.transform = transform
        }
        
    }
    
    @objc func leftSwipe(_ sender:UISwipeGestureRecognizer){
        
        switch sender.direction {
        
        //左スワイプ時に実行したい処理
        case .left:
            
            leftAnimation()
            numberView.isHidden = true
            
        default:
            break
            
        }
        
    }
    
    @objc func rightSwipe(_ sender:UISwipeGestureRecognizer){
        
        switch sender.direction {
        
        //右スワイプ時に実行したい処理
        case .right:
           
            rightAnimation()
            numberView.isHidden = false
            
        default:
            break
        }
        
    }
    
    
    @IBAction func kitsuenButtonSwipe(_ sender: UISwipeGestureRecognizer) {
        
        leftSwipe(sender)
        
    }
    
    
    @IBAction func kinenButtonSwipe(_ sender: UISwipeGestureRecognizer) {
        
        rightSwipe(sender)
        
    }
    
    @IBAction func kinenButton(_ sender: UIButton) {
        
        leftAnimation()
        numberView.isHidden = true
        
    }
    
    @IBAction func kitsuenButton(_ sender: UIButton) {
        
        rightAnimation()
        numberView.isHidden = false
        
    }
    
    
    @IBAction func dismissButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        
        
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
