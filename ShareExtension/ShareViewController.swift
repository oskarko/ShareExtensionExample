//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Oscar Rodriguez Garrucho on 20/3/18.
//  Copyright © 2018 oscargarrucho.com. All rights reserved.
//

import UIKit
import MobileCoreServices
import Social

class ShareViewController: UIViewController {
    
    @IBOutlet weak var importDocumentBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {

        importDocumentBtn.layer.cornerRadius = 5
        cancelBtn.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    @IBAction func copyBtnPressed(_ sender: Any) {
        importFile()
    }
    
    func importFile() {
        
        let fileItem = self.extensionContext!.inputItems.first as! NSExtensionItem
        let textItemProvider = fileItem.attachments!.first as! NSItemProvider
        
        let identifier = kUTTypeContent as String   // files attachment
        let identifier2 = kUTTypeURL as String  // URL files
        
        // from mail and others
        if textItemProvider.hasItemConformingToTypeIdentifier(identifier) {
            
            textItemProvider.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (fileURL, error) in
                if let fileURL = fileURL as? URL {
                    
                    let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.oscargarrucho.myapp")
                    if let fileContainer = containerURL {
                        
                        let fileName = fileURL.lastPathComponent.replacingOccurrences(of: "%20", with: " ")
                        let finale = URL(fileURLWithPath: "\(fileContainer.path)/\(fileName)", isDirectory: false)
                        
                        let fileManager = FileManager.default
                        do {
                            
                            try fileManager.copyItem(at: fileURL, to: finale)
                            self.presentAlert()
                        }
                        catch {
                            print(error)
                        }
                    }
                }
            })
        }
        // from dropbox and others
        if textItemProvider.hasItemConformingToTypeIdentifier(identifier2) {
            
            textItemProvider.loadItem(forTypeIdentifier: identifier2, options: nil, completionHandler: { (fileURL, error) in
                
                if let fileURL = fileURL as? URL {
                    
                    let sessionConfig = URLSessionConfiguration.default
                    let session = URLSession(configuration: sessionConfig)
                    let fileM = URL(string: "\(fileURL.absoluteString)".replacingOccurrences(of: "dl=0", with: "raw=1"))
                    
                    
                    let request = URLRequest(url:fileM!)
                    //print("OSCAR file to download: \(fileURL.absoluteString), fileM \(fileM!.absoluteString)")
                    
                    let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                        if let tempLocalUrl = tempLocalUrl, error == nil {
                            // Success
                            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                                print("Successfully downloaded. Status code: \(statusCode)")
                            }
                            let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.oscargarrucho.myapp")
                            if let fileContainer = containerURL {
                                
                                let fileName = fileURL.lastPathComponent.replacingOccurrences(of: "%20", with: " ")
                                let finale = URL(fileURLWithPath: "\(fileContainer.path)/\(fileName)", isDirectory: false)
                                
                                let fileManager = FileManager.default
                                do {
                                    
                                    try fileManager.moveItem(at: tempLocalUrl, to: finale)
                                    self.presentAlert()
                                }
                                catch {
                                    print(error)
                                }
                            }
                            
                        } else {
                            print("Error took place while downloading a file. Error description: %@", error?.localizedDescription as Any);
                        }
                    }
                    task.resume()
                }
            })
        }
    }
    
    func presentAlert() {
        let alertController = UIAlertController(title: "My App", message: "Your document has been imported correctly", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    
    
    //  Function must be named exactly like this so a selector can be found by the compiler!
    //  Anyway - it's another selector in another instance that would be "performed" instead.
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
    
    
}

