//
//  JobData.swift
//  AudioMemoWithACP WatchKit Extension
//
//  Created by 林 政樹 on 2021/10/08.
//

import Foundation

struct JobData: Codable {
    // -> Post
    var sessionid: String?
    var text: String?
    // -> Get
    var audio_md5: String?
    var audio_size: Int?
    var session_id: String?
    var service_id: String?
    var status: String?
    // -> if success
    var utteranceid: String?
    var code: String?
    var message: String?
    var results: JobResult?
    // -> if failure
    var error_message: String?
}

struct JobResult: Codable {
    var text: String?
    var results: [Results]?
    
    struct Results: Codable {
        var confidence: Double?
        var starttime: Int?
        var endtime: Int?
        var rulename: String?
        var tags: [Int]?
        var text: String?
        var tokens: [Tokens]?
        
        struct Tokens: Codable {
            var confidence: Double?
            var spoken: String?
            var written: String?
            var starttime: Int?
            var endtime: Int?
            var label: String?
        }
    }
}
