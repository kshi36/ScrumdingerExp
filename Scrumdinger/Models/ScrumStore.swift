//
//  ScrumStore.swift
//  Scrumdinger
//
//  Used as data model for app
//  Created by Kevin on 6/23/22.
//

import Foundation
import SwiftUI

class ScrumStore: ObservableObject {
    @Published var scrums: [DailyScrum] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("scrums.data")      //URL of file named scrums.data
    }
    
    // async version of load fn. (async/await API)
    static func load() async throws -> [DailyScrum] {
        //withChecked... suspends load fn., passes a continuation closure into a provided closure
        //continuation is a value that reps. code after an awaited fn. (think monad result)
        try await withCheckedThrowingContinuation { continuation in
            load { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let scrums):
                    continuation.resume(returning: scrums)
                }
            }
        }
    }
    
    ///Loads data from scrums.data file
    ///accepts completion closure that is called async. w/ an array of scrums or error
    static func load(completion: @escaping (Result<[DailyScrum], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                // try getting file URL of scrums.data
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                // decode scrums list from scrums.data file
                let dailyScrums = try JSONDecoder().decode([DailyScrum].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(dailyScrums))
                }
            }
            catch {
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult
    static func save(scrums: [DailyScrum]) async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            save(scrums: scrums) { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let scrumsCount):
                    continuation.resume(returning: scrumsCount)
                }
            }
        }
    }
    
    ///Save scrums list into scrums.data file.
    ///accepts completion closure that accepts # of saved scrums of error
    static func save(scrums: [DailyScrum], completion: @escaping (Result<Int, Error>)->Void) {
        do {
            // encode the scrums data
            let data = try JSONEncoder().encode(scrums)
            
            // write to scrums.data file
            let outFile = try fileURL()
            try data.write(to: outFile)
            DispatchQueue.main.async {
                completion(.success(scrums.count))
            }
        }
        catch {
            completion(.failure(error))
        }
    }
}
