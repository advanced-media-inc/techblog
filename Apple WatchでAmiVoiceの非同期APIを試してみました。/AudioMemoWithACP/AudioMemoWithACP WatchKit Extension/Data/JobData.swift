//
//  JobData.swift
//  AudioMemoWithACP WatchKit Extension
//
//  Created by 林 政樹 on 2021/10/08.
//

import Foundation

struct JobData: Codable {
    var sessionid: String?
    var session_id: String?
    var results: JobResult?
    var text: String?
    var audio_size: Int?
    var content_id: String?
    var error_message: String?
    var status: String?
    

    //
}

struct JobResult: Codable {
    var code: String?
    var message: String?
    var text: String?
    var utteranceid: String?
    
    var results: [Results]?
    var segments: [Segments]?
    
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
        }
    }
    
    struct Segments: Codable {
        var code: String?
        var message: String?
        var text: String?
        var results: [Results]?
    }
}
