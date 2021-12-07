//
//  AmiHTTP.swift
//  AudioMemoWithACP WatchKit Extension
//
//  Created by 林 政樹 on 2021/10/08.
//

import Foundation

enum AmiHTTP {
    //
    static func postTo(_ urlStr:String, appKey: String, data: Data, completion: @escaping (Either<String, JobData>) -> Void){

        guard let url = URL(string: urlStr) else {
            return completion(.error("URL変換に失敗"))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = String(arc4random() % 10000)

        request.allHTTPHeaderFields = ["Content-Type":"multipart/form-data; boundary=\(boundary)"]
   
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"u\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(appKey)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"d\"\r\n\r\n".data(using: .utf8)!)
        body.append("grammarFileNames=-a-general\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)

        // 音声データの格納
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        
        request.httpBody = body as Data
        
        self.dataTask(with: request) { result in
            completion(result)
        }
    }
    
    // ->
    static func fetchDataFrom(_ urlStr:String, session_id: String, appKey: String, completion: @escaping (Either<String, JobData>) -> Void){
        let urlStr_ =  urlStr + "/" + session_id
        guard let url = URL(string: urlStr_) else {return}
        var request = URLRequest(url: url)

        request.allHTTPHeaderFields = ["Authorization":"Bearer \(appKey)"]
        
        self.dataTask(with: request) { result in
            completion(result)
        }
    }

    // ->
    private static func dataTask(with request:URLRequest, completion: @escaping (Either<String, JobData>) -> Void) {
        // ->
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            //
            if let error = error {
                completion(.error(error.localizedDescription))
                return
            }
            
            guard let data = data else {
                completion(.error("No data"))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let job = try decoder.decode(JobData.self, from: data)
                
                completion(.result(job))
            } catch let error {
                completion(.error(error.localizedDescription))
            }
        }
        task.resume()
    }
}

enum Either<Left, Right> {
    case error(Left)
    case result(Right)
    
    var error: Left? {
        switch self {
        case let .error(x):
            return x
            
        case .result:
            return nil
        }
    }
    
    var result: Right? {
        switch self {
        case .error:
            return nil
            
        case let .result(x):
            return x
        }
    }
}
