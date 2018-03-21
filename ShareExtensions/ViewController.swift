//
//  ViewController.swift
//  ShareExtensions
//
//  Created by Oscar Rodriguez Garrucho on 20/3/18.
//  Copyright © 2018 oscargarrucho.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var allFiles: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "customCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "customCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,selector: #selector(refresh),name: Notification.Name(rawValue: "did-become-active"),object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refresh()
    }

    @objc func refresh() {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.oscargarrucho.myapp")
        if let fileContainer = containerURL {
            var directoryContentsGroup : [URL] = []
            var fileName = ""
            var isDir : ObjCBool = false
            let fileManager = FileManager.default
            
            do {
                directoryContentsGroup = try FileManager.default.contentsOfDirectory(at: fileContainer, includingPropertiesForKeys: nil, options: [])
                directoryContentsGroup = try FileManager.default.contentsOfDirectory(at: fileContainer, includingPropertiesForKeys: [.contentModificationDateKey], options:.skipsHiddenFiles)
                
                for item in directoryContentsGroup {
                    
                    // We are going to copy each new file imported here!
                    if (fileManager.fileExists(atPath: item.path, isDirectory: &isDir)) {
                        if (!isDir.boolValue) {
                            fileName = item.lastPathComponent
                            let appGroupshared = URL(fileURLWithPath: "\(fileContainer.path)/\(fileName)", isDirectory: false)
                            let copiedFile = URL(fileURLWithPath: "\(documentsDirectory.path)/\(fileName)", isDirectory: false)
                            
                            if (fileManager.fileExists(atPath: appGroupshared.path)) {  // if exist in AppGroup, copy and remove
                                do {
                                    try fileManager.copyItem(at: appGroupshared, to: copiedFile)
                                    try fileManager.removeItem(atPath: appGroupshared.path)
                                }
                                catch {
                                    print(error)
                                }
                            }
                            
                        }
                    }
                }
            } catch { }
        }
        getAllFiles()
        
    }
    
    @objc func getAllFiles() {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var directoryContents : [URL] = []
        do {
            directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: [.contentModificationDateKey], options:.skipsHiddenFiles)
            
            var directoryContentsWithDate : [(URL, Date)] = []
            directoryContentsWithDate = directoryContents.map { url in
                (url, (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast)
                }
                .sorted(by: { $0.1 > $1.1 })
            
            allFiles = [String]()
            for item in directoryContentsWithDate {
                allFiles.append(item.0.lastPathComponent)
            }
        } catch { }
        
        tableView.reloadData()
    }


}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFiles.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // nothing here
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomCell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomCell
        
        cell.configure(text: allFiles[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
}































