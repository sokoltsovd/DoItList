//
//  Task.swift
//  DoItList
//
//  Created by Dmitry Sokoltsov on 14.09.2021.
//

import Foundation
import Firebase

struct Task {
    let title: String
    let userId: String
    let ref: DatabaseReference?
    var completed: Bool = false
    
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapShotValue = snapshot.value as! [String: AnyObject]
        title = snapShotValue["title"] as! String
        userId = snapShotValue["userId"] as! String
        completed = snapShotValue["completed"] as! Bool
        ref = snapshot.ref
    }
    func convertToDictionary() -> Any {
        return ["title": title, "userId": userId, "completed": completed]
    }
}
