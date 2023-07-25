//
//  NavigationManager.swift
//  GitSSHManager
//
//  Created by Coditas on 11/07/23.
//


import Foundation
import Cocoa

class NavigationManager {
    static let shared = NavigationManager()
    private let storyboard: NSStoryboard?
    
    private init() {
        storyboard = NSStoryboard(name: "Main", bundle: nil)
    }
    
    func showAddProfileViewController() {
        guard let storyboard = storyboard else { return }
        guard let addProfileViewController = storyboard.instantiateController(withIdentifier: "AddProfileViewController") as? AddProfileViewController else { return }
        NSApplication.shared.windows.first?.contentViewController = addProfileViewController
    }
    
    func showProfileViewController(completionHandler: (() -> Void)? = nil) {
        guard let storyboard = storyboard else { return }
        guard let profileViewController = storyboard.instantiateController(withIdentifier: "ProfileViewController") as? ProfileViewController else { return }
        NSApplication.shared.windows.first?.contentViewController = profileViewController
        completionHandler?()
    }
    
    func showHomeViewController() {
        guard let storyboard = storyboard else { return }
        guard let homeViewController = storyboard.instantiateController(withIdentifier: "HomeViewController") as? HomeViewController else { return }
        NSApplication.shared.windows.first?.contentViewController = homeViewController
    }
    
    func showGenerateSSHViewController() {
        guard let storyboard = storyboard else { return }
        guard let homeViewController = storyboard.instantiateController(withIdentifier: "GenerateSSHKeyViewController") as? GenerateSSHKeyViewController else { return }
        NSApplication.shared.windows.first?.contentViewController = homeViewController
    }
}
