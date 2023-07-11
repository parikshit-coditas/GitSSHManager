//
//  AddProfileViewController.swift
//  GitSSHManager
//
//  Created by Coditas on 04/07/23.
//

import Cocoa

class AddProfileViewController: NSViewController {
    
    @IBOutlet weak var fieldSSHKeyPath: NSTextField!
    @IBOutlet weak var fieldEmailAddress: NSTextField!
    @IBOutlet weak var fieldUsername: NSTextField!
    
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
                self.handleSelectedFileURL(url)
            }
        }
    }
    
    func handleSelectedFileURL(_ fileURL: URL) {
        let filePath = fileURL.path
        print("Selected file path: \(filePath)")
        fieldSSHKeyPath.stringValue = filePath
    }
    
    @IBAction func btnAddProfileClick(_ sender: Any) {
        let sshKeyPath = fieldSSHKeyPath.stringValue
        let emailAddress = fieldEmailAddress.stringValue
        let username = fieldUsername.stringValue
        
        if sshKeyPath.isEmpty || emailAddress.isEmpty || username.isEmpty {
            displayErrorDialog()
        } else {
            addProfile()
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigateToProfileViewController()
    }
    
    private func addProfile(){
        let realmManager = RealmManager.shared
        let gitProfile = GitProfile()
        gitProfile.userName = fieldUsername.stringValue
        gitProfile.userEmail = fieldEmailAddress.stringValue
        gitProfile.sshProfilePath = fieldSSHKeyPath.stringValue
        
        realmManager.addObject(gitProfile)
        displaySuccessDialog()
        
    }
    
    private func displayErrorDialog() {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = "One or more fields are empty."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func displaySuccessDialog(completionHandler: (() -> Void)? = nil) {
        let alert = NSAlert()
        alert.messageText = "Profile added successfully"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        
        if let window = view.window {
            alert.beginSheetModal(for: window) { (response) in
                self.navigateToProfileViewController()
            }
        } else {
            alert.runModal()
            completionHandler?()
        }
    }
    
    private func navigateToProfileViewController() {
        NavigationManager.shared.showProfileViewController()
    }
    
}
