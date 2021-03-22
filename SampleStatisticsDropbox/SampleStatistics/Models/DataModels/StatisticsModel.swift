//
//  StatisticsModel.swift
//  SampleStatistics
//
//  Created by Stacy Zeder on 3/19/21.
//

import Foundation


struct StatisticsModel: Codable {
  var numSamples: Int
  var missingSamples: Int
  var numCompleteBatches: Int
  var numIncompleteBatches: Int
  
  init() {
    self.numSamples = 0
    self.missingSamples = 0
    self.numCompleteBatches = 0
    self.numIncompleteBatches = 0
  }
  
  var description: String {
    var msg = numSamples.description + ", "
    msg = msg + missingSamples.description + ", "
    msg = msg + numCompleteBatches.description + ", "
    msg = msg + numCompleteBatches.description + ", "
    msg = msg + numIncompleteBatches.description + ", "
    return msg
  }
  
}
