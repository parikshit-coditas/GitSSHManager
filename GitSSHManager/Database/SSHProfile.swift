//
//  SSHProfile.swift
//  GitSSHManager
//
//  Created by Coditas on 10/07/23.
//

import Foundation
import RealmSwift

class GitProfile: Object {
    @Persisted var userName: String = ""
    @Persisted var userEmail: String = ""
    @Persisted var sshProfilePath: String = ""
}
