/**
 * OBS-SpeechRecognition Javascript (obs-Connector-js) v0.5.0
 * @Author: Advanced Media.Inc
 * @License: Free
 */
const OBSConnector = function () { //OBSConnector.
    const obs = new OBSWebSocket();//OBSWebsocketをインスタンス化
    let connected = false;

    let self = {
        //-------------------------------------------
        // デフォルトのOBS Studio側の設定
        //-------------------------------------------
        setting: {
            host: "localhost",
            port: "4444", // OBS のポート番号
            maxLineWidth: "30", // 1 行の最大文字数
            source: "Acp", // OBS の字幕ソース名
        },
        //-------------------------------------------
        // OBS プロセスと接続する
        //-------------------------------------------
        connect: () => {
            if ((typeof self.setting.port !== "string") || (self.setting.source.porth == 0)) {
                console.log("ポート番号を指定してください");
                return;
            }

            obs.connect({ address: `${self.setting.host}:${self.setting.port}` })
                .then(() => {
                    connected = true;
                    console.log(`Success! We're connected & authenticated.`);
                    if (self.onConnected) self.onConnected(true);
                })
                .catch(err => {
                    connected = false;
                    console.log(err);
                    if (self.onConnectFailed) self.onConnectFailed(err);
                });
        },
        //-------------------------------------------
        // OBS プロセスとの接続状態を調べる
        //-------------------------------------------
        isConnected: () => {
            return connected;
        },
        //-------------------------------------------
        // OBS プロセスとの接続を解除する
        //-------------------------------------------
        disconnect: () => {
            connected = false;
            obs.disconnect();
            if (self.onDisconnected) self.onDisconnected();
        },
        //-------------------------------------------
        // OBS プロセスにテキストを送る
        //-------------------------------------------
        sendText: (text) => {
            if ((typeof self.setting.source !== "string") || (self.setting.source.length == 0)) {
                console.log("source を指定してください");
                return;
            }
            if ((typeof self.setting.maxLineWidth !== "string") || (self.setting.maxLineWidth.length == 0)) {
                console.log("maxLineWidth を指定してください");
                return;
            }

            if (text.length >= self.setting.maxLineWidth) {   //字幕自動改行関連
                let wCount = self.setting.maxLineWidth;
                if (wCount <= 0) wCount = 1; //1以下の値は入らない

                if (text.indexOf("。")) {
                    text = text.replace(/。/g, '。\n');//読点に改行を加える
                }
                // maxLineWidthの数値に応じて自動改行する
                let sliceStr = text;
                let addBreakStr = "";
                for (let i = 0; i < text.length / wCount; i++) {
                  let str1 = sliceStr.slice(0, wCount);
                  let str2 = sliceStr.slice(wCount);
                  addBreakStr += str1 + '\n';
                  sliceStr = str2;
                }
                text = addBreakStr;
            }

            //OBSの字幕ソースに認識結果を流し込む
            obs.send("SetTextGDIPlusProperties", { source: self.setting.source, text: text });
        },
        //-------------------------------------------
        // イベントハンドラ
        //-------------------------------------------
        onConnected: undefined, // OBS プロセスとの接続に成功した時に呼ばれる
        onConnectFailed: undefined, // OBS プロセスとの接続に失敗した時に呼ばれる
        onDisconnected: undefined // OBS プロセスとの接続を解除した時に呼ばれる
    };

    return self;
};
