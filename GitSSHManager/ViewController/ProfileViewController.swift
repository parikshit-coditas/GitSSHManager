//
//  ProfileViewController.swift
//  GitSSHManager
//
//  Created by Coditas on 06/07/23.
//

import Cocoa
import RealmSwift

class ProfileViewController: NSViewController {
    
    var objects: Results<GitProfile>?
    let realmManager = RealmManager.shared
    let navigationManager = NavigationManager.shared
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
        let profiles = realmManager.fetchObjects()
        objects = profiles
        
        if profiles.isEmpty {
            DispatchQueue.main.async {
                self.navigateToHomeViewController()
            }
        } else {
            tableView.reloadData()
        }
    }
    
    @IBAction func btnAddProfile(_ sender: Any) {
        navigationManager.showAddProfileViewController()
    }
    
    func navigateToHomeViewController() {
        navigationManager.showHomeViewController()
    }
}

extension ProfileViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if(objects?.count == 0) {
            navigateToHomeViewController()
        }
        return objects?.count ?? 0
    }
}

extension ProfileViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "profileCell"), owner: self) as? ProfileTableCellView else {
            return nil
        }
        if let object = objects?[row] {
            configureCell(with: object, cell: cell)
        }
        cell.btnAdd.target = self
        cell.btnAdd.action = #selector(btnAddProfileToGit(_:))
        
        cell.btnDelete.target = self
        cell.btnDelete.action = #selector(btnDeleteProfile(_:))
        return cell
    }
    
    private func configureCell(with object: GitProfile, cell: ProfileTableCellView) {
        let userName = object.userName
        let userEmail = object.userEmail
        
        let userNamePrefix = "User Name: "
        let userNameString = "\(userNamePrefix)   \(userName)"
        let userNameAttributedString = NSMutableAttributedString(string: userNameString)
        let userNamePrefixRange = (userNameString as NSString).range(of: userNamePrefix)
        let userNameRemainingTextRange = NSRange(location: userNamePrefixRange.length, length: userNameString.count - userNamePrefixRange.length)
        
        let userNamePrefixFont = NSFont.systemFont(ofSize: 12)
        let userNameRemainingTextFont = NSFont.systemFont(ofSize: 14)
        
        userNameAttributedString.addAttribute(.font, value: userNamePrefixFont, range: userNamePrefixRange)
        userNameAttributedString.addAttribute(.font, value: userNameRemainingTextFont, range: userNameRemainingTextRange)
        
        cell.userNameLabel?.attributedStringValue = userNameAttributedString
        
        let userEmailPrefix = "User Email: "
        let userEmailString = "\(userEmailPrefix)    \(userEmail)"
        let userEmailAttributedString = NSMutableAttributedString(string: userEmailString)
        let userEmailPrefixRange = (userEmailString as NSString).range(of: userEmailPrefix)
        let userEmailRemainingTextRange = NSRange(location: userEmailPrefixRange.length, length: userEmailString.count - userEmailPrefixRange.length)
        
        let userEmailPrefixFont = NSFont.systemFont(ofSize: 12)
        let userEmailRemainingTextFont = NSFont.systemFont(ofSize: 14)
        
        userEmailAttributedString.addAttribute(.font, value: userEmailPrefixFont, range: userEmailPrefixRange)
        userEmailAttributedString.addAttribute(.font, value: userEmailRemainingTextFont, range: userEmailRemainingTextRange)
        
        cell.userEmailLabel?.attributedStringValue = userEmailAttributedString
    }
}

class ProfileTableCellView: NSTableCellView {
    @IBOutlet weak var userNameLabel: NSTextField!
    @IBOutlet weak var userEmailLabel: NSTextField!
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnDelete: NSButton!
}

extension ProfileViewController {
    @objc func btnAddProfileToGit(_ sender: NSButton) {
        let row = tableView.row(for: sender)
        guard let object = objects?[row] else {
            return
        }
        let userName = object.userName
        let userEmail = object.userEmail
        let sshPath = object.sshProfilePath
        showAlertWithConfirmation(userName: userName, userEmail: userEmail, sshPath: sshPath)
    }
    
    @objc func btnDeleteProfile(_ sender: NSButton) {
        let row = tableView.row(for: sender)
        guard let object = objects?[row] else {
            return
        }
        let userEmail = object.userEmail
        let userName = object.userName
        realmManager.deleteObjectWithUsernameAndEmail(userName, userEmail)
        tableView.reloadData()
    }
}

func showAlertWithConfirmation(userName: String, userEmail: String, sshPath: String) {
    let alert = NSAlert()
    alert.messageText = "Confirm Git Configuration"
    alert.informativeText = "Are you sure you want to set the Git user name to \(userName)?"
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    
    let response = alert.runModal()
    
    if response == .alertFirstButtonReturn {
        createBashScript(userName: userName, userEmail: userEmail, sshPath: sshPath)
    }
}

func createBashScript(userName: String, userEmail: String, sshPath: String) {
    
    let scriptContent = """
    #!/bin/bash
    ssh-add -D
    git config --global user.name "\(userName)"
    git config --global user.email "\(userEmail)"
    ssh-add \(sshPath)
    """
    
    let fileManager = FileManager.default
    let downloadsDirectory = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first
    
    if let scriptDirectory = downloadsDirectory?.appendingPathComponent("SSHProfileScripts") {
        do {
            try fileManager.createDirectory(at: scriptDirectory, withIntermediateDirectories: true, attributes: nil)
            
            let scriptFileURL = scriptDirectory.appendingPathComponent("\(userName).sh")
            try scriptContent.write(to: scriptFileURL, atomically: true, encoding: .utf8)
            
            executeBashScript(scriptFileURL: scriptFileURL)
        } catch {
            print("Failed to create or write the bash script: \(error)")
        }
    }
}

func executeBashScript(scriptFileURL: URL) {
    
    let task = Process()
    task.launchPath = "/bin/bash"
    
    let scriptPath = scriptFileURL.path
    let command = "chmod +x \"\(scriptPath)\" && \"\(scriptPath)\""
    task.arguments = ["-c", command]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    
    task.launch()
    task.waitUntilExit()
    
    let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: outputData, encoding: .utf8) {
        print("Script output:\n\(output)")
    }
    
}





