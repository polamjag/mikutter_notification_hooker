# mikutter notification hooker: みくったー通知フックプラグイン

## 導入方法
`cd ~/.mikutter/plugin ; git clone https://github.com/polamjag/mikutter_notification_hooker.rb`

## つかいかた
* 設定画面に表示される "コマンドフック" ペインで，実行したいコマンドを入力します．

## 高度な機能
* "フォーマット置換" オプションを有効にすると，各コマンド内で以下のフレーズが該当イベントのツイートやユーザ名に置き換わります．**この機能を使うときは，なるべく「ツイート内のバッククオートを排除する」を有効にしてください．**
	1. フレンドタイムライン，リプライ，ダイレクトメッセージ受信
		* #<<user>> が ツイート・DMの送信者名
		* #<<post>> が ツイート・DMの本文
	1. フォローされたとき，フォロー解除されたとき
		* #<<user>> が フォロー (解除) したユーザ名
	1. ふぁぼられたとき，リツイートされたとき
		* #<<user>> が ふぁぼった・RTしたユーザ名
		* #<<post>> が ふぁぼられた・RTされたツイートの本文
	例: フレンドタイムラインで，`echo "#<<user>> tweeted: #<<post>>"` とすると，mikutter を起動した時のコンソールの標準出力にツイートが表示されます．
**警告: フォーマット置換機能により，コマンドのパターンによっては OS コマンドインジェクションが可能になります．たとえば，フレンドタイムラインに "#<<post>>" というコマンドをフックすると，OS のコマンドとして解釈可能なツイートが流れてきた時にそのまま実行されてしまいます．**
**これを防ぐため，バッククオートを排除する機能を有効にしてください．**

## 使用方法の例
1. mikutter 起動時のタイムラインをログに取る
    `echo "#<<user>>: #<<post>>" >> ~/mikutter_timeline_log` をフレンドタイムラインにフック，フォーマット置換を有効

## 参考
mikutter/core/plugin/notify.rb