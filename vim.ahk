#Requires AutoHotkey v2.0
ProcessSetPriority("Realtime")

class WINDOW {
    __New() {
        editorList := Map(
	        "sakura", "ahk_exe sakura.exe",
        )

        browserList := Map(
            "chrome", "ahk_exe chrome.exe",
        )

        this.props := Map(
            "editor", editorList,
            "browser", browserList
        )
    }

    isFocusAnyWindow() {
        editors := this.props["editor"]
        browsers := this.props["browser"]

        for key, value in editors {
            if (WinActive(value))
                return true
        }

        for key, value in browsers {
            if (WinActive(value))
                return true
        }
       
        return false
    }

    isFocusAnyEditor() {
        for key, value in this.props {
            if(key == "editor" and WinActive(value)) {
                return true
            }
        }
        return false
    }

    isFocusAnyBrowser() {
        for key, value in this.props {
            if(key == "browser" and WinActive(value)) {
                return true
            }
        }
        return false
    }

    isFocusChrome() {
        return WinActive(this.props["browser"]["chrome"])
    }
}

class ModeManager {
    __New() {
        this.visualMode := "visualMode"
        this.scrollMode := "scrollMode"
        this.normalMode := "normalMode"

        this.currentMode := this.normalMode
    }
    
    showToolTip(message) {
        ToolTip(message)
        Sleep 500
        ToolTip("")
    }
   
    onVisualMode() {
        this.currentMode := this.visualMode
        this.showToolTip("Visual Mode ON")
    }

    onScrollMode() {
        this.currentMode := this.scrollMode
        this.showToolTip("Scroll Mode ON")
    }
    
    onNormalMode() {
        this.currentMode := this.normalMode
        this.showToolTip("Normal Mode ON")
    }

    isVisualMode() {
        return this.currentMode == this.visualMode
    }

    isScrollMode() {
        return this.currentMode == this.scrollMode
    }

    isNormalMode() {
        return this.currentMode == this.normalMode
    }
}

global modeMgr
global win
modeMgr := ModeManager()
win := WINDOW()

; vk1D: 無変換キー, vk1C: 変換キー
vk1D::return



#HotIf win.isFocusAnyWindow()

    ; 変換キー+v で Visual Mode のオン/オフをトグル
    vk1D & v::
    {
        global modeMgr
        if(modeMgr.isVisualMode()) {
            modeMgr.onNormalMode()
        } else {
            modeMgr.onVisualMode()
        }
        return
    }

    ; 変換キー+s でスクロールモードをトグル
    vk1D & s::
    {
        global modeMgr
        if(modeMgr.isScrollMode()) {
            modeMgr.onNormalMode()
        } else {
            modeMgr.onScrollMode()
        }
        return
    }

#HotIf

; スクロールモードがオンの場合のホットキー定義
#HotIf win.isFocusAnyWindow() and modeMgr.isScrollMode()
    
	; ここでは、右側のキーはリテラルとして扱うため引用符で囲みます
	h::Send("{WheelLeft}")
	j::Send("{WheelDown}")
	k::Send("{WheelUp}")
	l::Send("{WheelRight}")
#HotIf

; Visual Mode がオンの場合のホットキー
#HotIf win.isFocusAnyWindow() and modeMgr.isVisualMode()
    h::Send("{Shift down}{Left}{Shift up}")
    j::Send("{Shift down}{Down}{Shift up}")
    k::Send("{Shift down}{Up}{Shift up}")
    l::Send("{Shift down}{Right}{Shift up}")
    y::Send("^c")
    
    ; 無変換キー+d：Delete キーで選択文字列を削除し、Visual Mode を終了
    d::
    {
        global visualMode
        Send("{Delete}")
        visualMode := false
        ToolTip("Visual Mode OFF")
        Sleep 500
        ToolTip("")
        return
    }
    ; vk1D & d のキーリリースを抑制する
    d up::return
#HotIf

; NormalModeの時のどうさ
#HotIf win.isFocusAnyWindow() and modeMgr.isNormalMode() 
    vk1D & h::Send("{Left}")
    vk1D & j::Send("{Down}")
    vk1D & k::Send("{Up}")
    vk1D & l::Send("{Right}")
    vk1D & x::Send("{Backspace}")
#HotIf

#HotIf win.isFocusChrome() and modeMgr.isNormalMode()
    vk1D & d::Send("!d") ; alt + d で検索バーへ移動
    vk1D & f::Send("^f") ; ctrl + f でページ内検索
    vk1D & b::Send("!{Left}") ; go
    vk1D & g::Send("!{Right}") ; back
    vk1D & a::Send("^+a") ; 開いているタブの一覧
    vk1D & e::Send("{F12}") ; engineer の略。devツール開く
    vk1D & r::Send("+{F5}") ; スーパーリロード

    vk1D & t::Send("^+t")
#HotIf 
