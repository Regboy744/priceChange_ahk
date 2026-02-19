#Requires AutoHotkey >=v2.0

; ============================================================================
; PDF UTILITIES
; Shells out to the TypeScript pdfParser to extract label data from PDFs.
; Requires Node.js and a built pdfParser (npm run build).
; ============================================================================

/**
 * Parse a PDF file and return an array of label objects.
 * Each label has: description, price, ean, page.
 * 
 * @param pdfPath  Absolute path to the PDF
 * @returns {Array} Array of label objects (empty on failure)
 */
ParsePDFFile(pdfPath) {
    if (!FileExist(pdfPath)) {
        LogError("PDF file not found: " . pdfPath)
        return []
    }

    parserDir := ProjectPath("tools\pdfParser")
    outputFile := parserDir . "\temp_output.json"
    distIndex := parserDir . "\dist\index.js"

    ; Ensure parser is built
    if (!FileExist(distIndex)) {
        LogError("PDF parser not built. Run 'npm run build' in tools/pdfParser folder.")
        ShowError("PDF parser not built!`n`nPlease run:`ncd tools/pdfParser`nnpm run build")
        return []
    }

    ; Remove stale output
    if (FileExist(outputFile)) {
        try FileDelete(outputFile)
    }

    ; Execute the Node.js parser
    cmd := A_ComSpec . ' /c cd /d "' . parserDir . '" && node "dist\index.js" "' . pdfPath . '" "' . outputFile . '"'
    LogInfo("Running PDF parser: " . cmd)

    try {
        RunWait(cmd, parserDir, "Hide")
    } catch as e {
        LogError("Failed to run PDF parser: " . e.Message)
        ShowError("Failed to run PDF parser!`n`nMake sure Node.js is installed.")
        return []
    }

    ; Read result
    if (!FileExist(outputFile)) {
        LogError("PDF parser did not create output file")
        ShowError("PDF parsing failed — no output generated")
        return []
    }

    jsonData := ReadJSONFile(outputFile)

    if (jsonData == "") {
        LogError("Failed to parse JSON output")
        return []
    }

    if (!jsonData.HasProp("labels")) {
        LogError("JSON output missing 'labels' property")
        return []
    }

    labels := jsonData.labels
    LogInfo("Parsed " . labels.Length . " labels from PDF")
    return labels
}

; ── Readiness checks ──────────────────────────────────────────────────────

/** @returns true if Node.js is on PATH */
CheckNodeInstalled() {
    try {
        result := RunWait('node --version', , "Hide")
        return (result == 0)
    } catch {
        return false
    }
}

/**
 * Verify that the PDF parser exists and is built.
 * @returns {Object}  { ready: bool, error: string }
 */
CheckPDFParserReady() {
    parserDir := ProjectPath("tools\pdfParser")
    distIndex := parserDir . "\dist\index.js"
    packageJson := parserDir . "\package.json"

    if (!FileExist(packageJson))
        return { ready: false, error: "PDF parser not found" }

    if (!FileExist(distIndex))
        return { ready: false, error: "PDF parser not built. Run 'npm run build' in tools/pdfParser folder." }

    if (!CheckNodeInstalled())
        return { ready: false, error: "Node.js not installed" }

    return { ready: true, error: "" }
}
