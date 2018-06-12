//
//  Post.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class Post: Object {
    static let dateFormatter: DateFormatter = DateFormatter()
    dynamic var id : Int = 0
    dynamic var author : User?
    dynamic var headline : String = ""
    dynamic var text : String = ""
    // Perhaps store the date as something else in the future (not sure)
    dynamic var date : Date = Date()
    dynamic var timestamp: Int = 0
    dynamic var image: Image? = nil
    dynamic var isLiked : Bool = false
    dynamic var isDisliked : Bool = false
    dynamic var voteValue: Double = 0
    dynamic var fullURL : String = ""
    dynamic var saved: Bool = false
    
    let comments = List<RealmComment>()
    let relatedLinks = List<Link>()
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["dateFormatter"]
    }
    
    func formattedTimeString() -> String {
        return TimeUtils.getFormattedDateString(date: self.date)
    }
    
}


extension Post {
    static func parseJson(json: [String: Any]) throws -> Post {
        let post = Post()
        post.id = json["id"] as! Int
        if let author = json["author"] as? [String: Any] {
            let user = try User.parseJson(json: author)
            post.author = user
        }
        post.headline = json["title"] as! String
        post.text = json["body"] as! String
        //post.setImageIfExists(json: json)
        
        if let rl = json["related_links"] as? [ [String: Any] ] {
            for obj in rl {
                let l = try Link.parseJson(json: obj)
                post.relatedLinks.append(l)
            }
        }
        if let imageJson = json["image"] as? [String: Any] {
            if let image = try? Image.parseJson(json: imageJson) {
                if let cached_image = RealmManager.instance.getMemRealm().object(ofType: Image.self, forPrimaryKey: image.imageUrl) {
                    post.image = cached_image
                } else {
                    post.image = image
                }
            } else {
                post.image = nil
            }
        } else {
            post.image = nil
        }
        
        guard let vote = json["votes"] as? [String: Any] else { throw SerializationError.missing("votes")}
        guard let like = vote["like"] as? Bool else { throw SerializationError.missing("like")}
        guard let dislike = vote["dislike"] as? Bool else { throw SerializationError.missing("dislike")}
        guard let vote_value = vote["value"] as? Double else { throw SerializationError.missing("value")}
        post.isLiked = like
        post.isDisliked = dislike
        post.voteValue = vote_value
        
        post.fullURL = json["url"] as! String
        guard let commentJson = json["comments"] as? [ [String: Any] ] else { throw SerializationError.missing("comments") }
        for comment in commentJson {
            let c = try RealmComment.parseJson(json: comment)
            post.comments.append(c)
        }
        guard let saved = json["saved"] as? Bool else { throw SerializationError.missing("saved") }
        post.saved = saved
        guard let timestamp = json["timestamp"] as? Double else { throw SerializationError.missing("timestamp") }
        let date = Date(timeIntervalSince1970: timestamp.rounded())
        post.date = date
        
        return post
    }
    static func parsePostPage(json: [String: Any]) throws -> [ Post ] {
        guard let list = json["posts"] as? [ [String: Any] ] else { throw SerializationError.missing("posts") }
        
        var parsedList: [ Post ] = []
        for postJson in list {
            let post = try parseJson(json: postJson)
            parsedList.append(post)
        }
        return parsedList
    }
}
