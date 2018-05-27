//
//  ProductViewController.swift
//  Panasonic
//
//  Created by PHUCLONG on 9/21/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController,UIPageViewControllerDataSource{
  
    var pageViewController : UIPageViewController!
    var arrProduct: [ProductModel] = []
    var arrCategory: [ProductModel] = []
    var productProvider: ProductProvider = ProductProvider()
    var PARAMATER: UserDefaults = UserDefaults()
    var AUDITID: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AUDITID = PARAMATER.object(forKey: "AUDITID") as? Int
        
        self.pageViewController	 = self.storyboard?.instantiateViewController(withIdentifier: "productPageViewController") as! UIPageViewController
        
        self.pageViewController.dataSource = self
        
        loadData()

        
        let startVC = self.viewControllerAtIndex(0) as productItemViewController
        
        let viewControllers = [startVC]
        
        
        
        // self.pageViewController.set(viewControllers as [AnyObject] as [AnyObject], direction: .Forward, animated: true, completion: nil)
        self.pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        
        self.pageViewController.view.frame = CGRect(x: 0, y: 30, width: self.view.frame.width, height: self.view.frame.size.height)
        
        
        
        self.addChildViewController(self.pageViewController)
        
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.didMove(toParentViewController: self)
       
        

    }
    
    func loadData(){
        
        arrCategory = productProvider.getCategory()!
        
    }
    func setGroupByProduct(_ arrProduct: [AuditSKUModel]){
        var headerGroup: String = ""
        for p in arrProduct {
            
            if(headerGroup.contains(p.MarketCode)){
                continue
            }
            else{
                headerGroup += p.MarketCode + ";"
                p.GroupBy = p.MarketCode
            }
            
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! productItemViewController
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
       
            let vc = viewController as! productItemViewController
            
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
    func viewControllerAtIndex(_ index : Int) -> productItemViewController {
        if ((self.arrCategory.count == 0) || (index >= self.arrCategory.count)) {
            
            return productItemViewController()
            
        }
        let vc: productItemViewController = self.storyboard?.instantiateViewController(withIdentifier: "frmProductItem") as! productItemViewController
        
        
        if(vc.arrProduct != nil){
            vc.lbTitle = self.arrCategory[index].CatName
            vc.arrProduct = productProvider.getbyCategory(self.arrCategory[index].CatCode,auditId: AUDITID!)
           // setGroupByProduct(vc.arrProduct!)
            vc.pageIndex = index
        }
        
        return vc
        
    }


}
