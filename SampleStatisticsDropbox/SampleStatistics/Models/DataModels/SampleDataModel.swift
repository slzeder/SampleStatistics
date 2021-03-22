//
//  SampleDataModel.swift
//  SampleStatistics
//
//  Created by Stacy Zeder on 3/20/21.
//

import Foundation


// TODO: FUTURE use - save all data in this struct for future requirements to analyze data portion of samples
struct SampleDataModel: Codable {
  let sequenceNumber: Int
  let data: String
  
  var description: String {
    var msg = sequenceNumber.description + ", "
    msg = msg + data + ", "
    return msg
  }
  
}
