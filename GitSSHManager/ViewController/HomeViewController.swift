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

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func btnAddProfile(_ sender: Any) {
        guard let storyboard = self.storyboard else { return }
        guard let nextViewController = storyboard.instantiateController(withIdentifier: "AddProfileViewController") as? AddProfileViewController else { return }
        self.view.window?.contentViewController = nextViewController
    }
}

