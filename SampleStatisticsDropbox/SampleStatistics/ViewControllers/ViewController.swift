//
//  ViewController.swift
//  SampleStatistics
//
//  Created by Stacy Zeder on 3/20/21.
//

import UIKit


/// This ViewController allows uses to download a file containing data samples from a given
/// dropbox location. The data retreived is parsed, and analyzed. Download speed is tracked.
class ViewController: UIViewController, SampleDataDelegate {
  
  let customGreen = UIColor(red: 15/255, green: 158/255, blue: 27/255, alpha: 1.0)
  
  // MARK: Constants
  
  // NOTE: While developing test various ways to get data. Also, use
  // test input file with edge cases to confirm logic for statistics.
  // Test files located in bundle
  let frameworkBundleID: String = Bundle.main.bundleIdentifier!
  
  let dropboxURLName: String = "https://dl.dropbox.com/s/xz2kbjglfz5tbwx/duo_data.txt"
  let dropboxParameters: [String: String] = ["dl": "0"]
  
  
  // MARK: Properties
  @IBOutlet weak var selectFileSegmentedControl: UISegmentedControl!
  @IBOutlet weak var retrieveFileButton: UIButton!
  @IBOutlet weak var downloadSpeedTextView: UITextField!
  @IBOutlet weak var sampleTotalTestField: UITextField!
  @IBOutlet weak var sampleMissingTextField: UITextField!
  @IBOutlet weak var batchCompleteTextField: UITextField!
  @IBOutlet weak var batchIncompleteTextField: UITextField!
  
  
  var url: URL? = nil
  var parameters: [String: String]? = nil
  var dataFileManager: DataFileManager!
  var dataProcessor: DataProcessor!
  
  // TODO: DEPRECATE, leave in as part of Coding assignment to demonstrate how this was developed.
  var dataFileManager2: DataFileManager2!
  
  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    clearUI()
    
    // Default URL and parameters
    if let urlFromName = URL(string: dropboxURLName) {
      self.url = urlFromName
    }
    self.parameters = dropboxParameters
    
    // Set self up as delegate
    self.dataFileManager = DataFileManager()
    self.dataFileManager.delegate = self
    
    // TODO: DEPRECATE, leaving in as part of coding assignement review.
    // TEMP: To test from smaller sample in bundle
    self.dataFileManager2 = DataFileManager2()
    self.dataFileManager2.delegate = self
    
    self.dataProcessor = DataProcessor()
  }
  
  
  // MARK: Methods
  private func clearUI() {
    downloadSpeedTextView.text = ""
    downloadSpeedTextView.backgroundColor = UIColor.systemGray6
    downloadSpeedTextView.layer.borderColor = UIColor.clear.cgColor
    downloadSpeedTextView.layer.borderWidth = 2
    downloadSpeedTextView.layer.cornerRadius = 5
    sampleTotalTestField.text = ""
    sampleMissingTextField.text = ""
    batchCompleteTextField.text = ""
    batchIncompleteTextField.text = ""
  }
  
  // MARK: Conform to SampleDataDelegate
  
  func updateDownloadSpeed(progressRate: Double, runningRate: Double) {
    DispatchQueue.main.async() {
      self.downloadSpeedTextView.text = String(format: "%.2f", runningRate)
      if runningRate < 780.0 {
        self.downloadSpeedTextView.layer.borderColor = UIColor.red.cgColor
        self.downloadSpeedTextView.layer.borderWidth = 2
      } else {
        self.downloadSpeedTextView.layer.borderColor = self.customGreen.cgColor
        self.downloadSpeedTextView.layer.borderWidth = 2
      }
    }
  }
  
  func didFailFileDownload(errMsg: String) {
    // Alert
    DispatchQueue.main.async {
      let alert = UIAlertController(title: "FAILURE", message: "File download request failed. Please check that you are connected to the internet.", preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
        print("DEBUG - http request failed. Check internet connection")
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func didReceiveData(data: Data) {
    let str = data.withUnsafeBytes { String(decoding: $0, as: UTF8.self) }
    let sequences = str.split(separator: "\n")
    
    dataProcessor.calculateStatistics(sequences: sequences)
    
    // Ensure all UI goes on main thread
    DispatchQueue.main.async() {
      self.sampleTotalTestField.text = self.dataProcessor.statistics.numSamples.description
      self.sampleMissingTextField.text = self.dataProcessor.statistics.missingSamples.description
      self.batchCompleteTextField.text = self.dataProcessor.statistics.numCompleteBatches.description
      self.batchIncompleteTextField.text = self.dataProcessor.statistics.numIncompleteBatches.description
    }
  }
  
  // MARK: Actions
  
  // Concerns:
  //  * Reading in a very large file
  //    >> memory issues
  //    >> processing time issues
  // TODO: Profile solutions
  
  @IBAction func retrieveFileButton_TouchUpInside(_ sender: UIButton) {
    clearUI()
    
    guard let validURL = url else {
      DispatchQueue.main.async {
        let alert = UIAlertController(title: "FAILURE", message: "Invalid URL. Contact developer.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
          print("DEBUG - Contact developer ")
        }))
        self.present(alert, animated: true, completion: nil)
      }
      return
    }
    
    // NOTE: For development
    // TODO: Remove test for production. Leave in for coding assignment
    switch selectFileSegmentedControl.selectedSegmentIndex
    {
    case 0:
      print("dropbox selected")
      dataFileManager.downloadFile(url: validURL, parameters: parameters)
    case 1:
      print("test bundle file selected")
      dataFileManager2.downloadFile(url: validURL)
    default:
      break
    }
    
  }
  
  @IBAction func selectFileSegmentedControl_ValueChanged(_ sender: UISegmentedControl) {
    // Reset UI
    clearUI()
    
    // Set url
    switch selectFileSegmentedControl.selectedSegmentIndex
    {
    case 0:
      print("dropbox selected")
      if let urlFromName = URL(string: dropboxURLName) {
        url = urlFromName
      }
    case 1:
      print("test bundle file selected")
      let frameworkBundle = Bundle(identifier: Bundle.main.bundleIdentifier!)
      if let file = frameworkBundle?.url(forResource: "dummy", withExtension: "txt") {
        url = file
        parameters = nil
        print(">> dummy << \(url!.absoluteString)")
      }
    default:
      break
    }
  }
  
}

