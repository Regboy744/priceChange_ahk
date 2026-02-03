#Requires AutoHotkey >=v2.0

; ============================================================================
; PDF UTILITIES
; Functions to parse PDF files using the TypeScript pdfParser
; ============================================================================

; Parse a PDF file and return the labels array
; Returns an array of objects with: description, price, ean, page
ParsePDFFile(pdfPath) {
    if (!FileExist(pdfPath)) {
        LogError("PDF file not found: " . pdfPath)
        return []
    }

    ; Define paths
    parserDir := A_ScriptDir . "\pdfParser"
    outputFile := parserDir . "\temp_output.json"
    distIndex := parserDir . "\dist\index.js"

    ; Check if parser is built
    if (!FileExist(distIndex)) {
        LogError("PDF parser not built. Run 'npm run build' in pdfParser folder.")
        ShowError("PDF parser not built!`n`nPlease run:`ncd pdfParser`nnpm run build")
        return []
    }

    ; Delete old output file if exists
    if (FileExist(outputFile)) {
        try FileDelete(outputFile)
    }

    ; Build the command to run the parser
    ; Using cmd /c with cd /d to ensure proper Windows path handling
    ; This mimics: npm run parse -- "pricechange.pdf" "output.json"
    cmd := A_ComSpec . ' /c cd /d "' . parserDir . '" && node "dist\index.js" "' . pdfPath . '" "' . outputFile . '"'

    LogInfo("Running PDF parser: " . cmd)

    ; Run the parser and wait for completion
    try {
        RunWait(cmd, parserDir, "Hide")
    } catch as e {
        LogError("Failed to run PDF parser: " . e.Message)
        ShowError("Failed to run PDF parser!`n`nMake sure Node.js is installed.")
        return []
    }

    ; Check if output was created
    if (!FileExist(outputFile)) {
        LogError("PDF parser did not create output file")
        ShowError("PDF parsing failed - no output generated")
        return []
    }

    ; Read and parse the JSON output
    jsonData := ReadJSONFile(outputFile)

    if (jsonData == "") {
        LogError("Failed to parse JSON output")
        return []
    }

    ; Extract labels array
    if (!jsonData.HasProp("labels")) {
        LogError("JSON output missing 'labels' property")
        return []
    }

    labels := jsonData.labels
    LogInfo("Parsed " . labels.Length . " labels from PDF")

    ; Clean up temp file (optional - keep for debugging)
    ; try FileDelete(outputFile)

    return labels
}

; Check if Node.js is available
CheckNodeInstalled() {
    try {
        result := RunWait('node --version', , "Hide")
        return (result == 0)
    } catch {
        return false
    }
}

; Check if the PDF parser is ready to use
CheckPDFParserReady() {
    parserDir := A_ScriptDir . "\pdfParser"
    distIndex := parserDir . "\dist\index.js"
    packageJson := parserDir . "\package.json"

    ; Check if parser exists
    if (!FileExist(packageJson)) {
        return { ready: false, error: "PDF parser not found" }
    }

    ; Check if built
    if (!FileExist(distIndex)) {
        return { ready: false, error: "PDF parser not built. Run 'npm run build' in pdfParser folder." }
    }

    ; Check Node.js
    if (!CheckNodeInstalled()) {
        return { ready: false, error: "Node.js not installed" }
    }

    return { ready: true, error: "" }
}
