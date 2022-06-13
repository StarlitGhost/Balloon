Windower4 非公式アドオン　Balloon

■機能
	通常のNPCのセリフを吹き出し表示します。

■コマンド　　Balloon<Bl> 
	//Bl 0
	通常のモードになります。吹き出し無し。ログ表示。
	//Bl 1
	吹き出し表示。ログ非表示。
	//Bl 2
	吹き出し表示。ログ表示。
	//Bl reset
	表示位置初期化。
	//Bl help
	ヘルプ表示

■補足
	表示位置は吹き出しが表示されている間にマウスで調整が可能です。
	現在ログ非表示であっても、ボタン待ちの関係で空白1行分ログが進んでしまいます。

	デフォルトのフォントはSegoeUIになりました。

	[ver 0.8以降のバージョン履歴は、英語のテキストから機械翻訳されています。 読みづらい場合はごめんなさい。] 
------------------------------------------------------------------------
■更新履歴
	ver 0.1　とりあえず完成。
	ver 0.2 UIスケール設定に対応。マウスで位置調整に対応。
	ver 0.3 吹き出しに表示されるゴミを出ないように。
	ver 0.4 さらにゴミ取りを行いました。デフォルトのテキストをしねきゃぷしょんからＭＳ ゴシックへ変更しました。
	ver 0.5 吹き出し位置を変更した時に位置が保存されない不具合の修正。
	ver 0.6 さらにゴミ文字を削除（ご協力eyes様）。色がついた文字に対応。メッセージの位置微調整。
　　　　　　　　対応メッセージを追加。キャラクターが移動すると強制的に吹き出しが閉じる処理を追加。内部処理を変更。
	ver 0.7 英語サポートを追加するためのYukiによる最初の変更。 翻訳されたヘルプテキスト。
		キャラクターをロックしないNPCダイアログが5秒間画面に表示されたまま、移動できるようにする機能が追加されました。
		上記は、進行を促さないダイアログラインを持つカットシーンで機能するはずです。
		追加のイベントタイプが追加されました-インタラクションなしでバックグラウンドで発生するNPCダイアログもバルーンに表示されるようになりました。
		デフォルトのフォントがSegoeUIに変更されました（実行方法：Luaを編集せずにこのユーザーを構成可能にします）。
		Kenshiが提供する文字列チョッピングコード（Kenshiに感謝します！）
	ver 0.8 25/8/21英語クライアント（Yuki）の初公開。
		文字列チョッピングコードを交換して、HandoとKenshiのオリジナル作品をミックスし、カラーコードなどへの置き換えを容易にしました。
		同等のテキストの代わりに要素記号（Synergy Engineerと話す場合など）を追加しました。
		多くの条件付きデバッグ出力を追加しました-バックグラウンドで何が起こっているかを確認したい場合は、// bl debug1または// bl debug2を使用してください。出力はコンソールウィンドウにあります。
		バルーンが表示されるとすぐに閉じていた（おそらく）バグを修正しました。

■作者
	反動
	

------------------------------------------------------------------------

Windower4 unofficial add-on Balloon

■ Function
	The lines of a normal NPC are displayed in a balloon.

■ Command Balloon <Bl>
	//Bl 0
	It will be in normal mode. No balloon. Log display.
	//Bl 1
	Balloon display. Log hidden.
	//Bl 2
	Balloon display. Log display.
	//Bl reset
	Display position initialization.
	//Bl theme <theme>
	Loads the specified theme folder found under themes/
	//Bl scale <scale>
	Scales the size of the balloon by a decimal (eg: 1.5)
	//Bl delay <seconds>
	Delay before closing promptless balloons.
	//Bl move_closes
	Toggles closing balloons on movement.
	//Bl animate
	Toggle advancement prompt animation.
	//Bl portrait
	Toggle character portraits.
	//Bl help
	Help display

■ Supplement
	The display position can be adjusted with the mouse while the balloon is displayed.
	Even if the log is currently hidden, the log will advance by one blank line due to waiting for the button.

	The default font is now Segoe UI for English, and Meiryo for Japanese.

	[Most of this English text is machine translated up to ver 0.6.]
-------------------------------------------------- ----------------------
■ Update history
	ver 0.1 Completed for the time being.
	ver 0.2 Supports UI scale setting. Supports position adjustment with the mouse.
	ver 0.3 Don't let the dust displayed in the balloon come out.
	ver 0.4 We also removed dust. Changed the default text from Shinkyapushon to MS Gothic.
	ver 0.5 Fixed a bug that the position is not saved when the balloon position is changed.
	ver 0.6 Furthermore, garbage characters are deleted (cooperation eyes). Corresponds to colored characters. Fine-tune the position of the message.
		Added a corresponding message. Added a process to forcibly close the balloon when the character moves. Changed internal processing.
	ver 0.7 Initial changes by Yuki to add English language support. Help text translated.
		Added feature where NPC dialogue that doesn't lock your character stays on screen for 5 seconds while still allowing you to move.
		Above should work with cutscenes that have a dialogue line that doesn't prompt for advancement.
		Added additional event types - NPC dialogue that happens in the background with no interaction should now display in a balloon too.
		Default font changed to Segoe UI (To do: make this user configurable without editing the Lua.)
		String chopping code provided by Kenshi (Thanks Kenshi!)
	ver 0.8 25/8/21 First public release of English client (Yuki).
		Swapped out string chopping code to be a mix of original work by Hando and Kenshi to make substituting in colour codes and similar easier.
		Added substitution of elemental symbols (e.g. when you talk to Synergy Engineer) for text equivalents.
		Added lots of conditional debugging output - if you want to see what's happening in the background use //bl debug 1 or //bl debug 2. Output is to the console window.
		Fixed (possibly) bug that was closing balloon as soon as it was displayed.
	ver 0.9 30/3/22 Ghosty's first modifications.
		Added a bunch of FFXIV-like features; animated advancement prompt, background for names, dark balloon with light text for system messages.
		Added the ability to load custom balloons based on NPC names (make a folder called character_balloons and create eg: Iroha.png).
		Added settings and commands for soft maximum line length, promptless close delay, prompt animation, and closing by movement.
		Added a command to generate test balloons.
	ver 0.9.1 27/5/22 Better word wrapping.
		Rewrote the word wrapping function to obey a strict character count, maximum line length is now an actual maximum.
		Improved ellipses and dash handling (no more "......" becoming "... ...").
		Better Japanese language support, by making it switch fonts automatically when first loaded [English: Segoe UI, Japanese: Meiryo] (the font can still be changed in settings.xml afterwards).
	ver 0.10 30/5/22 Theme support.
		Rewrote a large chunk of the addon to support multiple themes, and live-loading of those themes.
		Added FFXI and SNES FF themes.
		Moved line length setting to each individual theme.xml
		Per-character balloons still work, they now go under eg: themes/<theme>/characters/Iroha.png
	ver 0.11 31/5/22 Scaling.
		Added a scale command to increase/decrease the size of the balloon by a decimal multiplier, eg: 1.5
	ver 0.11.1 2/6/22 Scaling fix.
		Fixed image scaling when the balloon image changes.
	ver 0.11.2 3/6/22 FFVII-R Subtitle Theme.
		Added a new theme based on the subtitles in FFVII Remake.
	ver 0.12 8/6/22 Animated text display.
		Added animated text display.
		Added a visible countdown timer for prompt-less balloons.
		Made the scroll lock key hide the balloon, like it does the vanilla UI.
		A *lot* of code cleanup.
	ver 0.13 13/6/22 Character portraits.
		Added character portraits for most of the main story NPCs.
		Toggleable globally with //bl portrait.
		Themes can choose to include support for them or not.
		Themes can also have a slightly different layout with/without portraits.

Send any feedback/questions to Ghosty in the #unofficial-addons channel on the Windower Discord.
Or open an issue on the GitHub repo at https://github.com/StarlitGhost/Balloon

■ Author
	Hando
■ Modified by
	Yuki
	Ghosty