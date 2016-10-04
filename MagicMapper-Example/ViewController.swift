//
//  ViewController.swift
//  MagicMapper-Example
//
//  Created by Adrian Mateoaea on 04/10/2016.
//  Copyright © 2016 Magic Mapper. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

extension Date: Mappable {
    
    init?(from: Any) {
        if let value = from as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd'T'HH':'mm':'ss'Z'"
            if let date = formatter.date(from: value) {
                self.init(timeIntervalSince1970: date.timeIntervalSince1970)
                return
            }
        }
        
        self.init()
    }
}

class GithubRepository: NSObject, Mappable {
    
    var id        : String = ""
    var name      : String = ""
    var body      : String = ""
    var url       : String = ""
    var photo     : String = ""
    var createdAt : Date?
    
    var mapFromDictionary: [String : String] {
        return [
            "body"      : "description",
            "photo"     : "owner.avatar_url",
            "createdAt" : "created_at"
        ]
    }
    
    var mapFromDictionaryTypes: [String : Mappable.Type] {
        return [
            "createdAt" : Date.self
        ]
    }
}

class GithubSearch: NSObject, Mappable {
    
    var total : Int = 0
    var items : [GithubRepository] = []
    
    var mapFromDictionary: [String : String] {
        return [
            "total" : "total_count",
        ]
    }
}

class ViewController: UITableViewController {

    fileprivate let APIURL = "https://api.github.com/search/repositories?q=+language:swift"
    
    var feed: GithubSearch? {
        didSet {
            if let feed = feed {
                self.title = "Total: \(feed.total)"
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request(APIURL).responseJSON { (response) in
            if let dictionary = response.result.value as? KeyValue {
                self.feed = GithubSearch(dictionary)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.tag = indexPath.row
        
        if let item = feed?.items[indexPath.row] {
            Alamofire.request(item.photo).responseImage(completionHandler: { (response) in
                DispatchQueue.main.async { [weak cell] in
                    if let image = response.result.value, cell?.tag == indexPath.row {
                        cell?.imageView?.image = image
                        cell?.setNeedsLayout()
                    }
                }
            })
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = item.body
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

}
