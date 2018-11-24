//
//  Article.swift
//  NYTimes
//
//  Created by CHETUMAC043 on 11/20/18.
//  Copyright © 2018 CHETUMAC043. All rights reserved.
//

import UIKit

class Article: NSObject, ClassServiceDelegate {
    var serviceClass:ServiceClass? = ServiceClass()
    var completionHandler:((_ ArticleList:ArticleListDataModel, _ status: Bool)->Void)?
    

    func getArticleList(compHandler: @escaping(_ ArticleList: ArticleListDataModel?, _ status: Bool)->Void) {
        let url = "https://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/7.json"
        serviceClass?.delegate = self
        serviceClass?.callAPI(url: url, dictionary: [:])
        completionHandler = compHandler
    }
    
    //MARK:- delegate methods
    func getResponse(response: Dictionary<String, Any>) {
        Loader.hide()
        print("response is \(response)")
        let data = ArticleListDataModel.init(json: response)
        completionHandler?(data, true)
    }
    
    func getError(error: String) {
        Loader.hide()
        alertShowOnWindowWithTitleAndMessage(title: "Error!", message: error)
    }
    //MARK:- Alert
    // show alert above the ui window screen with level plus 1
     func alertShowOnWindowWithTitleAndMessage(title: String, message: String){
        
        let alert = UIAlertController(title: NSLocalizedString(title, comment: ""), message: NSLocalizedString(message, comment: ""), preferredStyle: .alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        // show alert
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
}


//MARK:- parse data
struct ArticleListDataModel {
    
    var arrArticle:[ArticleData] = [ArticleData]()
    
    init(json:[String: Any]) {
        if let data = json["results"] as? [[String:Any]] {
            for item in data {
                let articleInfo = ArticleData.init(json: item)
                arrArticle.append(articleInfo)
            }
        }
    }
}

struct ArticleData {
    var title:String? = ""
    var url:String? = ""
    var publishedDate:String? = ""
    var source:String? = ""
    var section:String? = ""
    
    init(json: [String: Any]) {
        self.title = json["title"] as? String
        self.url = json["url"] as? String
        self.publishedDate = json["published_date"] as? String
        self.source = json["source"] as? String
        self.section = json["section"] as? String
    }
}
