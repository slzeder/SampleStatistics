//
//  DataFileManager.swift
//  SampleStatistics
//
//  Created by Stacy Zeder on 3/19/21.
//

import Foundation
import Alamofire


protocol SampleDataDelegate: AnyObject {
  func didReceiveData(data: Data)
  func didFailFileDownload(errMsg: String)
  func updateDownloadSpeed(progressRate: Double, runningRate: Double)
}


/// DataFileManager class - Retrieves file from internet
class DataFileManager  {
  
  // MARK: Properties
  
  weak var delegate: SampleDataDelegate?
  
  
  // MARK: Methods
  
  public func downloadFile(url: URL, parameters: [String: String]?) -> Void {
    var progressIncrement = 0
    var startTime = Date()
    var previousTime = startTime
    var endTime = Date()
    
    var startCount: Int64 = 0
    var previousCount: Int64 = 0
    var currentCount: Int64 = 0
    
    AF.download(url,
                method: .post,
                parameters: parameters ,
                encoder: JSONParameterEncoder.default
    ).downloadProgress { [self] progress in
      endTime = Date()
      currentCount = progress.completedUnitCount
      if progressIncrement == 0 {
        previousCount = currentCount
        startCount = currentCount
        previousTime = endTime
        startTime = endTime
      } else {
        let deltaT = endTime.timeIntervalSinceReferenceDate - previousTime.timeIntervalSinceReferenceDate
        let deltaCount = currentCount - previousCount
        let rateKpbs = Double(deltaCount) / (1000.0 * deltaT)
        
        let runningTotalTime = endTime.timeIntervalSinceReferenceDate - startTime.timeIntervalSinceReferenceDate
        let runningTotalCount = Double(currentCount - startCount)
        let runningRateKpbs = runningTotalCount / (1000.0 * runningTotalTime)
        
        previousCount = currentCount
        previousTime = endTime
        
        self.delegate?.updateDownloadSpeed(progressRate: rateKpbs, runningRate: runningRateKpbs)
      }
      
      progressIncrement += 1
    }
    .responseData { response in
      switch response.result {
      case .success(_):
        let responseStatusCode: Int = response.response!.statusCode
        if 200...299 ~= responseStatusCode {
          if let rxData = response.value {
            self.delegate?.didReceiveData(data: rxData)
          }
        } else {
          self.delegate?.didFailFileDownload(errMsg: "HTTP error, status code: \(response.response!.statusCode)")
        }
        break
      case .failure(let error):
        self.delegate?.didFailFileDownload(errMsg: error.localizedDescription)
      }
    }
  }

}
