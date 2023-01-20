//
//  FileController.swift
//  AudioMemoWithACP WatchKit Extension
//
//  Created by 林 政樹 on 2021/10/08.
//

import Foundation

enum FileController {
    
    ///
    /// remove data from local data
    ///
    static func remove(_ file_name: String) -> Bool {
        //
        let main = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //
        let path = main.appendingPathComponent(file_name)

        do {
            try FileManager.default.removeItem(at: path)
            return true
        }
        catch let error {
            print("FileControl.read error: ", error)
            return false
        }
    }
    ///
    /// remove data from local data
    ///
    static func remove(_ files: [String]) {
        //
        for file_name in files {
            let res = remove(file_name)
            print("res: ", res)
        }
    }
    
    ///
    /// 指定したディレクトリ内のファイル名を取得する
    ///
    static func getContentsOfDirectory() -> [String]{
        //
        let path = NSHomeDirectory() + "/Documents/"
        
        // -> 該当するフォルダが存在するか。 -> 必要ないかも
        if !FileManager.default.fileExists(atPath: path) {
            return [String]()
        }
        
        // ファイルリストを取得
        do {
            let list = try FileManager.default.contentsOfDirectory(atPath: path)
            return list
        }
        catch let error {
            print("error: ", error)
            return [String]()
        }
    }

    //
    //
    static func getURL(file: String) -> URL?{
        ///  URL to store the recorded audio in ~/Documents/
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }

        return dir.appendingPathComponent(file)
    }

    ///
    /// if exist the url
    ///
    static func isExist(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
}
