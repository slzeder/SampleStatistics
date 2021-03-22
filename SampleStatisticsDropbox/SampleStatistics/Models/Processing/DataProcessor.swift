//
//  DataProcessor.swift
//  SampleStatistics
//
//  Created by Stacy Zeder on 3/19/21.
//

import Foundation


class DataProcessor {
  
  // MARK: Properties
  
  ///  TODO: FUTURE use -
  ///  samples - property to store all sample packets. Not currently used.
  //var samples: [SampleDataModel] = []
  
  var statistics: StatisticsModel = StatisticsModel()
  
  // MARK: Init/Deinit
  init() {
  }
  
  // MARK: Methods
  
  /// calculateStatistics - calculates the number of missing samples and the number of batches of the sample data
  ///
  /// This function accepts objects conforming to the StringProtocol, thus it can accept both String and Substrings
  /// - Parameter sequences: Array of sample data, each element in array represents a data sample in hex. The data is 20 bytes long, with the first byte being the sequence number
  /// - Returns: void
  func calculateStatistics<S: StringProtocol>(sequences: [S]) -> Void {
    // Make copy so can remove invalid data
    var sampleSequences = sequences
    
    // Reset results
    statistics = StatisticsModel()
    
    // Validate
    // Simplistic: ensure each line is 40 chars long
    // Fuller validation: !!! NOTE !!! CAUTION !!!
    // There is not enough information to accurately count the number of missing samples. At the boundary between two batches, if the end of one batch is missing, and the beginning of the next batch is missing, it is possible the the sequence numbers will appear in order. Thus, a time-stamp or some other finer sequencing scheme is needed in order to identify this use case.
    let numChars = sampleSequences.map{ $0.utf8.count }
    let numWithIncorrectNumberOfBytes = numChars.filter{$0 != 40}
    
    // Get indices of bad data, remove them from the data.
    let invalidIndices = numChars.indices.filter{numChars[$0] != 40}
    for i in invalidIndices.reversed() {
      sampleSequences.remove(at: i)
    }
    
    // Grab the sequence number portion of the sample, convert to base 16
    let sequenceNumbers = sampleSequences.map{ $0.prefix(2) }
    var sequenceNumberValues = sampleSequences.map { Int($0.prefix(2), radix: 16) ?? 0 }
    // To calculate last batch correctly, append 0 at end
    sequenceNumberValues.append(0)
    
    // Array of differences
    let differences = zip(sequenceNumberValues.dropFirst(), sequenceNumberValues).map(-)

    // Number of missing samples
    let missingAtBatchBoundary = differences.filter { $0 <= 0 }.map {$0 + 16 - 1}
    let allOtherMissing = differences.filter { $0 > 1 }.map{ $0 - 1 }
    let locationOfBoundaries = differences.indices.filter { differences[$0] <= 0 }
    let sizeOfBatches = zip(locationOfBoundaries.dropFirst(), locationOfBoundaries).map(-)
    let totalNumBatches = locationOfBoundaries.count
    var countIfFirstBatchComplete = 0
    if let firstBatch = locationOfBoundaries.first {
      countIfFirstBatchComplete = (firstBatch < 15 ? 1 : 0)
    }
    let numIncompleteBatches = sizeOfBatches.filter{ $0 < 15 }.count + countIfFirstBatchComplete
    let sumMissingAtBatchBoundary = missingAtBatchBoundary.reduce(0, +)
    let sumAllOtherMissing = allOtherMissing.reduce(0, +)
    let numMissingSamples = sumMissingAtBatchBoundary + sumAllOtherMissing
    let numBatches = differences.filter { $0 < 0 }.count
    
    // Populate member property
    statistics.numSamples = sampleSequences.count
    statistics.missingSamples = numMissingSamples
    statistics.numCompleteBatches = totalNumBatches
    statistics.numIncompleteBatches = numIncompleteBatches
        
    debugPrint ("numWithIncorrectNumberOfBytes: \(numWithIncorrectNumberOfBytes)")
    debugPrint ("invalidIndices: \(invalidIndices)")
    debugPrint ("sampleSequences.count: \(sampleSequences.count)")
    debugPrint ("sequenceNumbers.count: \(sequenceNumbers.count)")
//    debugPrint ("sequenceNumberValues: \(sequenceNumberValues)")
//    debugPrint ("differences: \(differences)")
//    debugPrint ("missingAtBatchBoundary: \(missingAtBatchBoundary)")
//    debugPrint ("allOtherMissing: \(allOtherMissing)")
//    debugPrint ("locationOfBoundaries: \(locationOfBoundaries)")
//    debugPrint ("sizeOfBatches: \(sizeOfBatches)")
    debugPrint ("totalNumBatches: \(totalNumBatches)")
    debugPrint ("numIncompleteBatches: \(numIncompleteBatches)")
    debugPrint ("sumMissingAtBatchBoundary: \(sumMissingAtBatchBoundary)")
    debugPrint ("sumAllOtherMissing: \(sumAllOtherMissing)")
    debugPrint ("Total num missing samples: \(numMissingSamples)")
    debugPrint ("numBatches: \(numBatches)")
  }
  
}
