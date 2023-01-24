//
//  ViewController.swift
//  KeychainPracticeApp
//
//  Created by Tringapps on 23/01/23.
//

import UIKit
import Security
import UniformTypeIdentifiers
import KeychainSwift

class ViewController: UIViewController, UIDocumentPickerDelegate {

    let keychain = KeychainSwift()
    var pdfData: Data?
    var pdfArray = [String]()
    var pdfStoredArray = [String]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        retreiveData()
    }


    @IBAction func addBtnTapped(_ sender: UIBarButtonItem) {
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)

    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
       
        guard let selectedFiles = urls.first else { return }
        let fileName = selectedFiles.lastPathComponent
        pdfArray.append(fileName)
        print("PdfArray:\(pdfArray)")
        print("Pdf data :\(fileName)")
        var data = Data()
        do {
            data = try NSKeyedArchiver.archivedData(withRootObject: pdfArray, requiringSecureCoding: true)
        } catch {
            print("archivedData Error");
        }
//        let arrayToData = dataConverter()
//        keychain.set(arrayToData, forKey: "pdfMyKey")
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "MyPdfArray",
            kSecValueData as String: data
        ] as [String : Any]

        SecItemAdd(query as CFDictionary, nil)
        print("Saved succesfully")
    }

    
    @IBAction func retriveBtnTapped(_ sender: UIBarButtonItem) {
//        if let pdfData = keychain.getData("pdfMyKey") {
//
//            do {
//                let arrayFromData = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: pdfData)
//                self.pdfStoredArray = arrayFromData as! [String]
//            } catch {
//                print("unarchivedObject Error");
//            }
//            self.tableView.reloadData()
//        } else {
//            print("No data found in keychain for pdf_files")
//        }
        
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "MyPdfArray",
            kSecReturnData as String: true,
//            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String : Any]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            let data = result as! Data
            print("Data value: \(data)")
            do {
                let arrayData = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data)
                pdfStoredArray = arrayData as! [String] 
            } catch {
                print("unarchivedObject Error")
            }
            self.tableView.reloadData()
        } else {
            print("Error retrieving array from keychain")
        }
        
    }
    
    func retreiveData() {
//        if let pdfData = keychain.getData("pdfMyKey") {
//
//            do {
//                let arrayFromData = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: pdfData)
//                self.pdfStoredArray = arrayFromData as! [String]
//            } catch {
//                print("unarchivedObject Error");
//            }
//            pdfArray.removeAll()
//            pdfArray = pdfStoredArray
//            self.tableView.reloadData()
//        } else {
//            print("No data found in keychain for pdf_files")
//        }
        
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "MyPdfArray",
            kSecReturnData as String: true,
//            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String : Any]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            let data = result as! Data
            do {
                let arrayData = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data)
                pdfStoredArray = arrayData as! [String]
            } catch {
                print("unarchivedObject Error")
            }
            pdfArray.removeAll()
            pdfArray = pdfStoredArray
            self.tableView.reloadData()
        } else {
            print("Error retrieving array from keychain")
        }

    }
    

    func dataConverter() -> Data {
        var data = Data()
            do {
                data = try NSKeyedArchiver.archivedData(withRootObject: pdfArray, requiringSecureCoding: true)
            } catch {
                print("archivedData Error");
            }
            return data
    }
    

    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pdfStoredArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeListTableCell", for: indexPath) as? HomeListTableCell else { return UITableViewCell()}
        cell.pdfNameLabel.text = pdfStoredArray[indexPath.row]
        return cell
    }
    
    
}
