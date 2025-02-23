#Requires AutoHotkey v2.0


t := Map("a", "b")
for key, value in t {
    MsgBox(key ": " value)
}