#SingleInstance Force
#Requires AutoHotkey v2.0
#Include supportFunctions.ahk
#Include lib\uiUtils.ahk
#Include lib\csvUtils.ahk

sections := [
    "S0001", "S0002", "S0003", "S0004", "S0005", "S0006", "S0007", "S0008", "S0009", "S0010", "S0011", "S0012", "S0013",
    "S0014", "S0015", "S0016", "S0017", "S0018", "S0019", "S0020", "S0021", "S0022", "S0023", "S0024", "S0025", "S0026",
    "S0233", "S0235",
    "S0236", "S0246", "S0247", "S0248", "S0050", "S0051", "S0052", "S0053", "S0234", "S0245"
]

f1:: { ; Start session once
    if (true) {
        ; Initialize CSV file at start of session
        InitializeCsvFile()

        ; Get total rows in column A (column 1)
        totalRows := sections.Length

        MsgBox "Found " . totalRows . " rows with data"

        ; Your loop here
        loop totalRows {
            ; Clik on the text box Article Code and fill it up with the first value
            clickSomething(712, 135, sections[A_Index])
            Sleep(400)

            ; Run the alt + t to search for the article code
            Send("!t")
            Sleep(6000)

            ; Wait till the spinnier desapear
            if (!WaitForColorToDisappear(623, 653, "CCCCCC", 600000, 200)) {
                LogDebug('Error wating for spinner desapear')
                return false
            }
            Sleep 1500

            ; Click on the green arrow to open options
            clickSomething(1174, 274)
            Sleep(1000)

            ; Click on the copy current data
            Send("{Down 4}")
            Sleep(500)

            ; Press enter to copy the data
            Send("{Enter}")
            Sleep(400)

            ; Append clipboard data to CSV with section code
            itemsAdded := AppendClipboardToCsv(sections[A_Index])
            LogDebug("Section " . sections[A_Index] . ": " . itemsAdded . " items added to CSV")
        }

        ; Show completion message
        MsgBox "Export complete!`n`nCSV saved to:`n" . GetCsvFilePath()
    }

}
