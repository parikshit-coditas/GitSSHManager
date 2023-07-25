//
//  ViewController.swift
//  GitSSHManager
//
//  Created by Coditas on 04/07/23.
//

import Cocoa

class HomeViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        }
    }

    @IBAction func btnAddProfile(_ sender: Any) {
        navigateToAddProfileViewController()
    }
    
    private func navigateToAddProfileViewController() {
        NavigationManager.shared.showAddProfileViewController()
    }
}

