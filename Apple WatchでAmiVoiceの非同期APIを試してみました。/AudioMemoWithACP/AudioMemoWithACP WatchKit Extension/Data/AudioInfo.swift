//
//  AudioInfo.swift
//  AudioMemoWithACP WatchKit Extension
//
//  Created by 林 政樹 on 2021/10/10.
//

import Foundation

struct AudioInfo:Codable {
    var url: URL
    var time: Date
    var recogText: String = ""
    var sessionId: String = ""
}
