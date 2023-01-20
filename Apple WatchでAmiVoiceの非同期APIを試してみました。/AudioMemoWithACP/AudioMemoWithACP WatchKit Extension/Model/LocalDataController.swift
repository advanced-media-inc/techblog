//
//  LocalDataController.swift
//  AudioMemoWithACP WatchKit Extension
//
//  Created by 林 政樹 on 2021/10/11.
//

import Foundation

enum LocalDataController {
    
    // MARK: - Set value
    //
    static func setData(audioInfoArr: [AudioInfo]) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(audioInfoArr)
            UserDefaults.standard.set(data, forKey: UDKey.audioInfoArr)
        }
        catch let error {
            print("setData(setupInfo: SetupInfo) Err: ", error.localizedDescription)
        }
    }
    
    
    // MARK: - Get Value
    //
    static func getAudioInfoArr() -> [AudioInfo]? {
        guard let data = UserDefaults.standard.data(forKey: UDKey.audioInfoArr) else {
            print("Failure to get setupinfo data from UserDefaults")
            return nil
        }
        do {
            let decoder = JSONDecoder()
            let infoArr = try decoder.decode([AudioInfo].self, from: data)
            return infoArr
        }
        catch let error {
            print("error: ", error)
            return nil
        }
    }

    // MARK: - Remove
    
    private static func remove(key: String){
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    static func removeAudioInfoArr() {
        // -> 端末内の音声を全消去
        let dir = FileController.getContentsOfDirectory()
        FileController.remove(dir)
        
        // -> 最後に端末内の[AudioInfo]を削除する
        remove(key: UDKey.audioInfoArr)
    }
}

// MARK: - UserDefaults Keys
//
struct UDKey {
    static let audioInfoArr = "audioInfoArr"
}
