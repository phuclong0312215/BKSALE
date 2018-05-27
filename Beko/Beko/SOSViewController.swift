//
//  SOSViewController.swift
//  Aqua
//
//  Created by PHUCLONG on 10/24/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit
extension String {
    public func indexOfCharacter(_ char: Character) -> Int? {
        if let idx = self.characters.index(of: char) {
            return self.characters.distance(from: self.startIndex, to: idx)
        }
        return nil
    }
}
class SOSViewController: UIViewController,UIPageViewControllerDataSource {
    var pageViewController : UIPageViewController!
   
    var arrProduct: [SOSModel] = []
    var arrCategory: [SOSModel] = []
    var sosProvider: SOSProvider = SOSProvider()
    var PARAMATER: UserDefaults = UserDefaults()
    var AUDITID: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
       
        AUDITID = PARAMATER.object(forKey: "AUDITID") as? Int
        
        self.pageViewController	 = self.storyboard?.instantiateViewController(withIdentifier: "sosPageViewController") as! UIPageViewController
        
        self.pageViewController.dataSource = self
        
        loadData()
        
        
        let startVC = self.viewControllerAtIndex(0) as SOSItemViewController
        
        let viewControllers = [startVC]
        
        
        
        // self.pageViewController.set(viewControllers as [AnyObject] as [AnyObject], direction: .Forward, animated: true, completion: nil)
        self.pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        
        self.pageViewController.view.frame = CGRect(x: 0, y: 30, width: self.view.frame.width, height: self.view.frame.size.height)
        
        
        
        self.addChildViewController(self.pageViewController)
        
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.didMove(toParentViewController: self)
        
        
        
    }
    func loadData(){
        
        arrCategory = sosProvider.getCategory()!
        
    }
    func setGroupByProduct(_ arrSOS: [SOSResultModel]){
        var headerGroup: String = ""
        for p in arrSOS {
            let index = p.CompetitorName?.indexOfCharacter("_")
            let MarketCompetitor = p.CompetitorName![p.CompetitorName!.characters.index(p.CompetitorName!.startIndex, offsetBy: 0)...p.CompetitorName!.characters.index(p.CompetitorName!.startIndex, offsetBy: index!-1)]
            if(headerGroup.contains(MarketCompetitor)){
                continue
            }
            else{
                headerGroup += MarketCompetitor + ";"
                p.GroupBy = MarketCompetitor
            }
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! SOSItemViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound){
            return nil
        }
        
        index += 1
        
        if (index == self.arrCategory.count){
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        
        
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! SOSItemViewController
        
        var index = vc.pageIndex as Int
        
        if (index == 0 || index == NSNotFound)
            
        {
            
            return nil
            
        }
        
        index -= 1
        
        return self.viewControllerAtIndex(index)
        
    }
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return arrCategory.count
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    func viewControllerAtIndex(_ index : Int) -> SOSItemViewController {
        if ((self.arrCategory.count == 0) || (index >= self.arrCategory.count)) {
            
            return SOSItemViewController()
            
        }
        let vc: SOSItemViewController = self.storyboard?.instantiateViewController(withIdentifier: "frmSOSItem") as! SOSItemViewController
        
        
        if(vc.arrSOS != nil){
            vc.lbTitle = self.arrCategory[index].CatName!
            vc.arrSOS = sosProvider.getByCategory(self.arrCategory[index].CatName!,AuditId: AUDITID!)
            setGroupByProduct(vc.arrSOS!)
            vc.pageIndex = index
        }
        
        return vc
        
    }

}
