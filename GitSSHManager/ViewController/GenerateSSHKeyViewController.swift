//
//  GenerateSSHKeyViewController.swift
//  GitSSHManager
//
//  Created by Coditas on 25/07/23.
//
import Cocoa

class GenerateSSHKeyViewController: NSViewController {
    
    let navigationManager = NavigationManager.shared
    var sshPublicKey = ""
    
    @IBOutlet weak var inputFieldEmailAddress: NSTextField!
    
    @IBOutlet weak var inputFieldSSHName: NSTextField!
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func onCLickAddSSHKey(_ sender: Any) {
        if (inputFieldEmailAddress.stringValue != "" && inputFieldSSHName.stringValue != "") {
            showAlertWithConfirmation(userEmail: inputFieldEmailAddress.stringValue, sshName: inputFieldSSHName.stringValue)
        } else {
            displayErrorDialog()
        }
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        navigateToAddProfileViewController()
    }
    
    private func navigateToAddProfileViewController() {
        navigationManager.showAddProfileViewController()
    }
    
    private func displayErrorDialog() {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = "One or more fields are empty."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func showAlertWithConfirmation(userEmail: String, sshName: String) {
        let alert = NSAlert()
        alert.messageText = "Confirm Git Configuration"
        alert.informativeText = "Are you sure you want to create the Git ssh key with to \(userEmail)?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            createBashScript(userEmail: userEmail, sshName: sshName)
        }
    }

    func createBashScript(userEmail: String, sshName: String) {
        
        let scriptContent = """
        #!/bin/bash
        SSH_KEY_PATH="$HOME/.ssh/id_\(sshName)"
        if [ -f "$SSH_KEY_PATH" ]; then
            echo "SSH key already exists at $SSH_KEY_PATH"
            exit 1
        fi
        (ssh-keygen -t rsa -b 4096 -C "\(userEmail)" -f "$SSH_KEY_PATH" -N "" <<EOF
        y
        y
        EOF
        )

        eval "$(ssh-agent -s)"
        ssh-add "$SSH_KEY_PATH"
        cat "$SSH_KEY_PATH.pub"
        """
        
        let fileManager = FileManager.default
        let downloadsDirectory = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first
        
        if let scriptDirectory = downloadsDirectory?.appendingPathComponent("SSHProfileScripts") {
            do {
                try fileManager.createDirectory(at: scriptDirectory, withIntermediateDirectories: true, attributes: nil)
                
                let scriptFileURL = scriptDirectory.appendingPathComponent("id_\(sshName).sh")
                try scriptContent.write(to: scriptFileURL, atomically: true, encoding: .utf8)
                let output = executeBashScript(scriptFileURL: scriptFileURL)
                print(output)
                navigationManager.showAddProfileViewController()
                
            } catch {
                print("Failed to create or write the bash script: \(error)")
            }
        }
    }

    func executeBashScript(scriptFileURL: URL) -> String {
        let process = Process()
        let pipe = Pipe()
        
        process.launchPath = "/bin/bash"
        process.arguments = [scriptFileURL.path]
        process.standardOutput = pipe
        process.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .newlines) ?? ""
        process.waitUntilExit()
        
        return output
    }
}
