//
//  RealmManager.swift
//  GitSSHManager
//
//  Created by Coditas on 10/07/23.
//

import Foundation

import RealmSwift

class RealmManager {
    
    private let realm: Realm
    
    static let shared = RealmManager()
    
    private init() {
        // Create a Realm instance
        realm = try! Realm()
    }
    
    // MARK: - Add Object
    func addObject(_ object: Object) {
        try! realm.write {
            realm.add(object)
        }
    }
    
    // MARK: - Fetch Objects
    func fetchObjects() -> Results<GitProfile> {
        return realm.objects(GitProfile.self)
    }
    
    // MARK: - Update Object
    func updateObject(_ object: Object, with dictionary: [String: Any?]) {
        try! realm.write {
            for (key, value) in dictionary {
                object.setValue(value, forKey: key)
            }
        }
    }
    
    func deleteAllObjects() {
        let objects = fetchObjects()
        
        try! realm.write {
            realm.delete(objects)
        }
    }
    
    // MARK: - Delete Object with Username and User Email
    func deleteObjectWithUsernameAndEmail(_ username: String, _ userEmail: String) {
        let objects = fetchObjects().filter("userName = %@ AND userEmail = %@", username, userEmail)
        
        if let objectToDelete = objects.first {
            try! realm.write {
                realm.delete(objectToDelete)
            }
        }
    }
}



