//
//  DataFileManager.swift
//  SampleStatistics
//
//  Created by Stacy Zeder on 3/19/21.
//

import Foundation

// TODO: DEPRECATE - used for development. Could also re-structure by having a DataFileManagerProtocol which differrent file managers could conform to. But this is out of the scope of the project.


/// DataFileManager class - Retrieves file from internet
class DataFileManager2: NSObject, URLSessionDownloadDelegate {
  
  // MARK: Properties

  weak var delegate: SampleDataDelegate?
  
  
  // MARK: Conform to URLSessionDownloadDelegate
  
  internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    guard let url = downloadTask.originalRequest?.url else { return }
    readData(url: url)
  }
  
  
  // MARK: Methods
  
  private func readData(url: URL) {
    do {
      let data = try Data(contentsOf: url)
      delegate?.didReceiveData(data: data)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  public func downloadFile(url: URL) -> Void {
    let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    let downloadTask = urlSession.downloadTask(with: url)
        
    downloadTask.resume()
  }
  
}
