//
//  InterfaceController.swift
//  AudioMemoWithACP WatchKit Extension
//
//  Created by 林 政樹 on 2021/10/03.
//

import WatchKit
import Foundation
import AVFoundation

class InterfaceController: WKInterfaceController {
    
    // MARK: - Constant
    let SERV_URL = "https://acp-api-async.amivoice.com/v1/recognitions"
    let APP_KEY = "自分のAPPKEY"
    
    // MARK: - Outlet
    @IBOutlet weak var table: WKInterfaceTable!

    // MARK: - var
    var infoArr = [AudioInfo]() {
        didSet(old) {
            if old.count >= self.infoArr.count {
                return
            }
            DispatchQueue.main.async {
                self.reloadTable(oldCount: old.count)
            }
        }
    }
    
    // MARK: - Lyfe
    
    override func awake(withContext context: Any?) {
        print("awake")
        
        guard let audioInfoArr = LocalDataController.getAudioInfoArr() else {return}
        infoArr = audioInfoArr
    }
    
    override func willActivate() {
        print("willActivate")
        fetchData()
    }
    
    override func didDeactivate() {
        print("didDeactivate")
        LocalDataController.setData(audioInfoArr: infoArr)
    }

    
    // MARK: - Actions
    @IBAction func toRecord() {
        
        if self.infoArr.count > 10 {
            self.presentAlert(message: "10件を超えて記録はできません。全削除しても良いですか？") { isOk in
                if !isOk {return}
                self.removeAllTable()
            }
            return
        }
        
        let date = Date().toString("yyyy-MM-dd HH:mm:ss.SSS")
        let options = [WKAudioRecorderControllerOptionsActionTitleKey: "保存", WKAudioRecorderControllerOptionsMaximumDurationKey:60*20] as [String : Any]
        guard let url = FileController.getURL(file: "\(date).wav") else {return}

        // record start
        presentAudioRecorderController(withOutputURL: url,
                                       preset: .wideBandSpeech,
                                       options: options,
                                       completion: { didSave, error in
                                        if let err = error {
                                            print("Error: ", err.localizedDescription)
                                            self.presentAlert(message: err.localizedDescription)
                                            return
                                        }
                                        
                                        if !didSave {return}
                                        
                                        self.didSaveAudio(url: url)
                                       })
    }
    
    //
    func didSaveAudio(url: URL) {
        
        let info = AudioInfo(url: url, time: Date(), recogText: "...", sessionId: "")
        self.infoArr.append(info)
        
        do {
            let data = try Data(contentsOf: url)
            print("data.count: ", data.count)
            //
            AmiHTTP.postTo(SERV_URL, appKey: APP_KEY, data: data) { result in
                switch result {
                case .error(let err):
                    print("error: ", err)
                    self.presentAlert(message: err)

                case .result(let job):
                    print("jobData: ", job)
                    for (i, info) in self.infoArr.enumerated() {
                        let url_ = info.url
                        if url_ != url {continue}
                        
                        self.infoArr[i].recogText = job.text!
                        self.infoArr[i].sessionId = job.sessionid!
                        
                        return
                    }
                }
            }
        } catch let err{
            print(err)
            self.presentAlert(message: err.localizedDescription)
        }
    }
    
    //
    @IBAction func reload() {
        fetchData()
    }
    
    func fetchData(){
        
        for (j, element) in self.infoArr.enumerated() {
            let sessionId = element.sessionId
            if element.recogText != "" && element.recogText != "..." {continue}
            
            AmiHTTP.fetchDataFrom(SERV_URL, session_id: sessionId, appKey: APP_KEY) { result in
                switch result{
                case .error(let err):
                    print("error: ", err)

                case .result(let job):
                    print("jobData: ", job)
                    
                    if let errorMessage = job.error_message {
                        let text = "--ERROR--\n" + errorMessage
                        self.infoArr[j].recogText = text
                        self.updateTable(index: j, text: text)
                        return
                    }
                    
                    guard
                        let code = job.code,
                        let text = job.text
                    else {return}
                    
                    var text_ = text
                    
                    if code != "" {
                        text_ = "--ERROR--\n" + job.message!
                    }
                    
                    self.infoArr[j].recogText = text_
                    self.updateTable(index: j, text: text_)
                }
            }
        }
    }

    
    // MARK: - WKInterfaceTable
    
    func reloadTable(oldCount: Int){
        let indexSet = IndexSet(integersIn: oldCount..<self.infoArr.count)
        table.insertRows(at: indexSet, withRowType: "Row")
        
        for (j, element) in self.infoArr.enumerated() {
            guard let cell = self.table.rowController(at: j) as? TableRowController else {continue}
            let text = element.recogText
            let time = element.time.toString()
            
            cell.text.setText(text)
            cell.time.setText(time)
        }
    }
    
    func updateTable(index: Int, text: String){
        DispatchQueue.main.async {
            guard let cell = self.table.rowController(at: index) as? TableRowController else {return}
            cell.text.setText(text)
        }
    }
    
    func removeAllTable(){
        //
        let indexSet = IndexSet(integersIn: 0..<self.infoArr.count)
        table.removeRows(at: indexSet)
        
        self.infoArr.removeAll()
        
        LocalDataController.removeAudioInfoArr()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let url = self.infoArr[rowIndex].url
        self.presentMediaPlayerController(with: url, options: nil) { didPlayToEnd, endTime, error in
            if let error = error {
                self.presentAlert(message: error.localizedDescription)
                return
            }
            
            print("didPlayToEnd: ", didPlayToEnd ? "YES" : "NO")
        }
    }
    
    
    // MARK: - Alert
    
    func presentAlert(message: String){
        let action = WKAlertAction(title: "OK", style: .default) {
            print("ok")
        }
        self.presentAlert(withTitle: "---ERROR---", message: message, preferredStyle: .alert, actions: [action])
    }
    
    func presentAlert(message: String, handler: @escaping (Bool) -> Void){
        
        let okAction = WKAlertAction(title: "YES", style: .default) {
            print("ok")
            handler(true)
        }
        let cancelAction = WKAlertAction(title: "NO", style: .cancel) {
            print("cancel")
            handler(false)
        }
        
        self.presentAlert(withTitle: "---ERROR---", message: message, preferredStyle: .alert, actions: [okAction, cancelAction])
    }
}

class TableRowController: NSObject {
    @IBOutlet weak var text: WKInterfaceLabel!
    @IBOutlet weak var time: WKInterfaceLabel!
}
