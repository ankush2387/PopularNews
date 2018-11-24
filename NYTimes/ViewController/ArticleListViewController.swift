//
//  ViewController.swift
//  NYTimes
//
//  Created by CHETUMAC043 on 11/20/18.
//  Copyright © 2018 CHETUMAC043. All rights reserved.
//

import UIKit

class ArticleListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var objArticle:Article = Article()
    var objDataModel:ArticleListDataModel?   
    
    //MARK:- lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "NY Times Most popular"
        // call api to get article list
        getArticleList()
    }
    

    //MARK:- custom methods
    func getArticleList()  {
        Loader.show(animated: true)
        objArticle.getArticleList {[weak self] (response, status) in
            Loader.hide()
            if status {
                self?.objDataModel = response
                self?.tableView.reloadData()
                print("success")
            } else {
                print("error occur")
            }
        }
    }
}

//MARK:- Tableview datasource and delegate
extension ArticleListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objDataModel?.arrArticle.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ArticleCell else {
            return UITableViewCell()
        }
        
        let objData = self.objDataModel?.arrArticle[indexPath.row]
        
        cell.lblTitle.text = objData?.title
        cell.lblSource.text = objData?.source
        cell.lblSection.text = objData?.section
        cell.lblPublishedDate.text = objData?.publishedDate
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.imgView.downLoadImage(withUrlString: objData?.url ?? "", withPlaceHolderImage: "placeholder_image")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row clicked")
        
        if let objVC = self.storyboard?.instantiateViewController(withIdentifier: "ArticleDetailViewController") as? ArticleDetailViewController {
            self.navigationController?.pushViewController(objVC, animated: true)
            let url = self.objDataModel?.arrArticle[indexPath.row].url
            objVC.urlString = url
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


extension UIImageView
{
    func downLoadImage(withUrlString :String,withPlaceHolderImage : String)
    {
        let url = NSURL.init(string: withUrlString)
        
        if let image = url?.cachedImage
        {
            print("Image already downloaded")
            self.image = image
        }
        else{
            self.image = UIImage(named: withPlaceHolderImage)
            url?.fetchImage(completion: { (image) in
                self.image = image
            })
        }
    }
}

extension NSURL {
    
    typealias ImageCacheCompletion = (UIImage) -> Void
    
    /// Retrieves a pre-cached image, or nil if it isn't cached.
    /// You should call this before calling fetchImage.
    var cachedImage: UIImage? {
        return MyImageCache.sharedCache.object(
            forKey: absoluteString as AnyObject) as? UIImage
    }
    
    /// Fetches the image from the network.
    /// Stores it in the cache if successful.
    /// Only calls completion on successful image download.
    /// Completion is called on the main thread.
    func fetchImage(completion: @escaping ImageCacheCompletion) {
        let task = URLSession.shared.dataTask(with: self as URL) {
            data, response, error in
            if error == nil {
                if let  data = data,
                    let image = UIImage(data: data) {
                    MyImageCache.sharedCache.setObject(
                        image,
                        forKey: self.absoluteString as AnyObject,
                        cost: data.count)
                    DispatchQueue.main.async() {
                        completion(image)
                    }
                }
            }
        }
        task.resume()
    }
    
}

class MyImageCache {
    
    static let sharedCache: NSCache = { () -> NSCache<AnyObject, AnyObject> in
        let cache = NSCache<AnyObject, AnyObject>()
        cache.name = "MyImageCache"
        cache.countLimit = 50// Max 20 images in memory.
        cache.totalCostLimit = 15*1024*1024 // Max 10MB used.
        return cache
    }()
    
    
}
