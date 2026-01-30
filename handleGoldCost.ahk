#SingleInstance Force
#Requires AutoHotkey >=v2.0
#Include supportFunctions.ahk

SHEET_NAME := "IMPULSE"
START_DATE_NEW_PRICE := "31/01/26"
END_DATE_NEW_PRICE := "01/02/26"

; Usage:
f2:: CloseAllExcelSafely()
; Your main hotkey using the function
f1:: {


    ; Start session once
    if (StartExcelSession()) {
        ; Get total rows in column A (column 1)
        totalRows := GetExcelRowCount(SHEET_NAME, 1, 2)
        MsgBox "Found " . totalRows . " rows with data"

        ; Make the gold window active all the time -  Requires to avoid error.
        WinActivate "GOLD PRD - \\Remote"
        MsgBox "From this point, please do not use the computer!", "Warning", "Icon!"
        Sleep 334

        ; Your loop here
        Loop totalRows {

            ; Get the value from the check price sheet
            ean_code := GetExcelData(SHEET_NAME, 1, A_Index + 1)
            Sleep 1000

            ; Get the new price => round it to 2 decimal digits
            new_price := Round(GetExcelData(SHEET_NAME, 5, A_Index + 1), 2)
            Sleep 1000

            ; Add the Start Date to the new prices
            StartDateOfNewPrice(START_DATE_NEW_PRICE)
            Sleep 333

            ; Clik on the text box Article Code and fill it up with the first value
            clickSomething(349, 136, ean_code)
            Sleep(400)

            ; Run the alt + t to search for the article code
            Send("!t")
            Sleep(6000)

            ; Click on new price text box
            clickSomething(537, 290)
            Sleep(3000)

            ; Write the ne price on the text box
            SendText new_price
            Sleep 333

            ; IF the END_DATE_NEW_PRICE is not empty
            if (END_DATE_NEW_PRICE != "") {
                ; Move to the END_DATE_NEW_PRICE
                Send("{Tab}")
                Sleep 333

                ; Write the END_DATE_NEW_PRICE on the text box
                SendText END_DATE_NEW_PRICE
                Sleep 333
            }

            MsgBox "Skipped the end date -  Regular Price change"


            Sleep 200000
            ; Click on the copy current data
            Send("{Down 4}")


            ; Move to the END_DATE_NEW_PRICE
            Send("{Tab}")
            Sleep 333

            ; Write the END_DATE_NEW_PRICE on the text box
            SendText END_DATE_NEW_PRICE
            Sleep 333


            Sleep 200000
            ; Click on the copy current data
            Send("{Down 4}")
            Sleep(500)

            ; Press enter to copy the data
            Send("{Enter}")
            Sleep(400)

            ; Get the second line with the price data
            priceData := getLine(A_Clipboard, 2)
            Sleep(2000)

            PasteExcelData("GOLD_PRICES", 1, A_Index + 1, ean_code, true)
            Sleep(2000)

            PasteExcelData("GOLD_PRICES", 2, A_Index + 1, priceData, true)
            Sleep(2000)

            ; Go back to beggining Quit alt+b
            Send("!b")
            Sleep(2000)

        }

        ; End session
        EndExcelSession()
    }

}