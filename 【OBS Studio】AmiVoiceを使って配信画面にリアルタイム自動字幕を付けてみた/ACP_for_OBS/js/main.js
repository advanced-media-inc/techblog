//-----------------------------------------------------
// サニタイズ処理
//-----------------------------------------------------
function sanitize(text) {
    return text.replace(/&/g, '&amp;').replace(/</g, '&lt;')
        .replace(/>/g, '&gt;').replace(/'/g, '&apos;').replace(/"/g, '&quot;');
}

//-----------------------------------------------------
// メイン関数
//-----------------------------------------------------
window.onload = function () {
    // メッセージ関連
    const messageColorTable = { OBSEVENT: "blue", ACPEVENT: "green", ERROR: "red" };
    const showTextMessage = (text, color = "black") => {
        let messagesElement = document.getElementById("messages");
        if (messagesElement.childNodes.length >= 20) {
            messagesElement.removeChild(messages.lastChild);
        }
        messagesElement.insertBefore(document.createElement("div"), messages.firstChild).innerHTML = text;
        messagesElement.firstChild.style.borderBottom = "1px #ddd solid";
        messagesElement.firstChild.style.color = color ? color : "black";
    };
    const showEventMessage = (kind, msg) => {
        showTextMessage(`${kind}: ${msg}`, messageColorTable[kind]);
    };

    //音声認識サーバ接続ボタン要素
    let resumePauseButtonElement = document.getElementById("resumePauseButton"); // resumePauseButtonElement
    let recTextElement = document.getElementById("recText"); // recTextElement
    //OBS STUDIO接続ボタン要素
    let obsConnectButtonElement = document.getElementById("obsConnectButton"); // obsConnectButtonElement
    let obsTextElement = document.getElementById("obsText"); //  obsTextElement

    const obsConnector = new OBSConnector();
    const amivoice = Wrp; // 暫定処置

    // OBS STUDIOライブラリの設定
    document.getElementById("portNumber").addEventListener('change', (event) => {
        obsConnector.setting.port = event.target.value;
    });
    document.getElementById("maxLineWidth").addEventListener('change', (event) => {
        obsConnector.setting.maxLineWidth = event.target.value;
    });
    document.getElementById("sourceName").addEventListener('change', (event) => {
        obsConnector.setting.source = event.target.value;
    });

    // 音声認識ライブラリの変更時のプロパティ要素の設定 ※wrp.js（7/2現在）の仕様に準じています
    document.getElementById("authorization").addEventListener('change', (event) => {
        amivoice.authorization = event.target.value;
    });
    document.getElementById("resultUpdatedInterval").addEventListener('change', (event) => {
        amivoice.resultUpdatedInterval = event.target.value * 1000;
    });
    document.getElementById("checkIntervalTime").addEventListener('change', (event) => {
        amivoice.checkIntervalTime = event.target.value * 1000;
    });

    // 音声認識ライブラリのイベントハンドラの設定
    amivoice.connectStarted = () => { // 音声認識サーバへの接続処理が開始した時に呼び出されます。
        showEventMessage("ACPEVENT", "音声認識サーバへの接続処理を開始しました。");
        resumePauseButtonElement.disabled = true; // ボタンの制御
    };
    amivoice.connectEnded = () => { // 音声認識サーバへの接続処理が完了した時に呼び出されます。
        showEventMessage("ACPEVENT", "音声認識サーバへの接続処理が完了しました。");
    };
    amivoice.disconnectStarted = () => { // 音声認識サーバからの切断処理が開始した時に呼び出されます。
        showEventMessage("ACPEVENT", "音声認識サーバからの切断処理が開始しました。");
    };
    amivoice.disconnectEnded = () => { // 音声認識サーバからの切断処理が完了した時に呼び出されます。
        showEventMessage("ACPEVENT", "音声認識サーバからの切断処理が完了しました。");
        // ボタンの制御
        recTextElement.innerHTML = "録音の開始";
        resumePauseButtonElement.disabled = false;
        resumePauseButtonElement.classList.remove("sending");
    };
    amivoice.connectFailed = (message) => { // 音声認識サーバへの音声データの供給処理が失敗した時に呼び出されます。
        showEventMessage("ERROR", message);
    };
    amivoice.feedDataResumeEnded = () => { // 音声認識サーバへの音声データの供給開始処理が完了した時に呼び出されます。
        // ボタンの制御
        recTextElement.innerHTML = "音声データの録音中...";
        resumePauseButtonElement.disabled = false;
        resumePauseButtonElement.classList.add("sending");
    };
    amivoice.feedDataPauseStarted = () => { // 音声認識サーバへの音声データの供給終了処理が開始した時に呼び出されます。
        resumePauseButtonElement.disabled = true;
    };
    // amivoice.resultCreated = () => {}; // 認識処理が開始された時に呼び出されます
    amivoice.resultUpdated = (result) => { // 認識処理中に呼び出されます
        let json = JSON.parse(result);
        obsConnector.sendText((json.text) ? sanitize(json.text) : "...");// 確定したテキストをOBSへ送信する
    };
    amivoice.resultFinalized = (result) => { // 認識処理が確定した時に呼び出されます。
        let json = JSON.parse(result);
        if (json.code != 'o') { // 'o' は、認識結果全体の信頼度が信頼度しきい値を下回ったために認識に失敗したことを表す
            let resultText = (json.text) ? sanitize(json.text) : `<font color='gray'>(${(json.message) ? json.message : "無し"})</font>`;
            let confidence = (json.results && json.results[0]) ? json.results[0].confidence : -1.0; // 認識結果の信頼度
            if (typeof resultText === 'string') {
                showTextMessage(resultText + " <font color=\"darkgray\">(信頼度: " + confidence * 100 + "％)</font>");
                obsConnector.sendText(resultText); // 確定したテキストを OBS へ送信する
            }
        }
    };
    // デバッグ用メッセージです。必要な際にコメントアウトを外してください。
    // amivoice.TRACE = (message) => {
    //     showEventMessage("DEBUG", message);
    //  };

    // 録音ライブラリのプロパティ要素の設定
    document.getElementById("maxRecordingTime").addEventListener('change', (event) => {
        Recorder.maxRecordingTime = event.target.value * 60000;
    });
    // 録音ライブラリのイベントハンドラの設定
    Recorder.resumeFailed = (message) => { // 録音ライブラリへの音声データの供給処理が失敗した時に呼び出されます。
         showEventMessage("ERROR", message);
    };
    // デバッグ用メッセージです。必要な際にコメントアウトを外してください。
    // recorder.TRACE = (message) => {
    //     showEventMessage("DEBUG", message);
    //  };

    // OBS-websocketライブラリのイベントハンドラの設定
    obsConnector.onConnected = () => {
        showEventMessage("OBSEVENT", "OBS Studioとの接続が完了しました。");
        obsTextElement.innerHTML = "OBSと接続中...";
        obsConnectButtonElement.disabled = false;
        obsConnectButtonElement.classList.add("sending");
    };
    obsConnector.onConnectFailed = () => {
        showEventMessage("ERROR", "起動中のOBS Studioが見つかりませんでした。");
        obsTextElement.innerHTML = "OBSと接続";
        obsConnectButtonElement.disabled = false;
        obsConnectButtonElement.classList.remove("sending");
    };
    obsConnector.onDisconnected = () => {
        showEventMessage("OBSEVENT", "OBS Studioとの接続の切断が完了しました。");
        obsTextElement.innerHTML = "OBSと接続";
        obsConnectButtonElement.disabled = false;
        obsConnectButtonElement.classList.remove("sending");
    };

    // 音声認識ライブラリ／録音ライブラリのメソッドの画面要素への登録
    resumePauseButtonElement.onclick = function () {
        // 音声認識サーバへの音声データの供給中かどうかのチェック
        if (amivoice.isActive()) {
            // 音声認識サーバへの音声データの供給の停止
            amivoice.feedDataPause();
        } else {
            // 音声認識サーバへの音声データの供給の開始
            amivoice.feedDataResume();
        }
    };

    // OBS接続ボタンの制御
    obsConnectButtonElement.onclick = function () {
        obsConnectButtonElement.disabled = true; // ボタンの制御
        if (obsConnector.isConnected() === true) {
            obsConnector.disconnect(); // OBSWebsocket を切断
            showEventMessage("OBSEVENT", "OBS Studioとの接続を切断します。");
        } else {
            obsConnector.connect();// OBSWebsocketを接続
            showEventMessage("OBSEVENT", "OBS Studioとの接続を開始します。");
        }
    };
};
