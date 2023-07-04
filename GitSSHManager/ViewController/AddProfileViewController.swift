//
//  AddProfileViewController.swift
//  GitSSHManager
//
//  Created by Coditas on 04/07/23.
//

import Cocoa

class AddProfileViewController: NSViewController {
    
    @IBOutlet weak var fieldSSHKeyPath: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fieldSSHKeyPath.isEditable = false
    }
    
    @IBAction func btnSelectSHHKey(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        
        openPanel.begin { (result) in
            if result == .OK, let url = openPanel.urls.first {
                // Handle the selected file URL
                self.handleSelectedFileURL(url)
            }
        }
    }
    
    func handleSelectedFileURL(_ fileURL: URL) {
        let filePath = fileURL.path
        print("Selected file path: \(filePath)")
        fieldSSHKeyPath.stringValue = filePath
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        guard let storyboard = self.storyboard else { return }
        guard let nextViewController = storyboard.instantiateController(withIdentifier: "HomeViewController") as? HomeViewController else { return }
        self.view.window?.contentViewController = nextViewController
    }
}
