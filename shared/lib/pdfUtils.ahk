#Requires AutoHotkey >=v2.0

; ============================================================================
; PDF UTILITIES
; Shells out to the TypeScript pdfParser to extract label data from PDFs.
;
; Path resolution: the parser and the Node runtime live in different places
; depending on whether we're running from the dev tree or the compiled build:
;
;   Dev tree                              Compiled build/
;   --------                              ---------------
;   tools/pdfParser/dist/index.js         dist/pdfParser/index.js
;   dist/node/node.exe                    dist/node/node.exe
;
; LocatePDFParser() and LocateNodeExe() probe both layouts, and the bundled
; portable Node is preferred over a system Node on PATH so the parser works
; on a fresh machine without any Node install.
; ============================================================================

/**
 * Find the PDF parser entry point. Tries dev tree first, then the build
 * layout. Returns "" if the parser is unbuilt/missing.
 * @returns Object { parserDir, indexJs } | ""
 */
LocatePDFParser() {
    devDir := ProjectPath("tools\pdfParser")
    if (FileExist(devDir . "\dist\index.js"))
        return { parserDir: devDir, indexJs: devDir . "\dist\index.js" }

    buildDir := ProjectPath("dist\pdfParser")
    if (FileExist(buildDir . "\index.js"))
        return { parserDir: buildDir, indexJs: buildDir . "\index.js" }

    return ""
}

/**
 * Find a Node executable.  Prefers a system Node on PATH because the parser
 * uses pdfjs-dist (ESM-only), and require()-of-ESM is only stable in Node
 * v22+ — the portable Node currently bundled in dist\node\ is v20.x and
 * throws ERR_REQUIRE_ESM at runtime.  If/when dist\node\ is upgraded to v22,
 * the order here can be swapped back so the bundle works on fresh machines
 * without any Node install.
 * @returns {String} Absolute path to node.exe, or "node".
 */
LocateNodeExe() {
    if (CheckNodeInstalled())
        return "node"

    portable := ProjectPath("dist\node\node.exe")
    if (FileExist(portable))
        return portable

    return "node"
}

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

    parser := LocatePDFParser()
    if (parser == "") {
        LogError("PDF parser not found in dev tree (tools\pdfParser\dist\) "
            . "or build layout (dist\pdfParser\)")
        ShowError("PDF parser not built!`n`nPlease run:`n"
            . "cd tools/pdfParser`nnpm run build")
        return []
    }

    nodeExe := LocateNodeExe()
    outputFile := parser.parserDir . "\temp_output.json"

    if (FileExist(outputFile))
        try FileDelete(outputFile)

    ; Wrap in A_ComSpec /c — direct CreateProcess of a quoted exe + args
    ; was unreliable in earlier testing (Node ran but exitCode and child
    ; stdout never made it back).  Going through cmd is what the original
    ; working version did.
    cmd := A_ComSpec . ' /c cd /d "' . parser.parserDir . '" && '
        . '"' . nodeExe . '" "' . parser.indexJs . '" "' . pdfPath . '" "' . outputFile . '"'
    LogInfo("Running PDF parser: " . cmd)

    exitCode := -1
    try {
        exitCode := RunWait(cmd, parser.parserDir, "Hide")
        LogInfo("PDF parser exit code: " . exitCode)
    } catch as e {
        LogError("Failed to run PDF parser: " . e.Message)
        ShowError("Failed to run PDF parser!`n`n" . e.Message)
        return []
    }

    if (!FileExist(outputFile)) {
        LogError("PDF parser did not create output file (exit code: " . exitCode . ")")
        ShowError("PDF parsing failed — no output generated`n`nExit code: " . exitCode
            . "`n`nCheck execution.log for the full command and node path.")
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

/** @returns true if Node.js is reachable on PATH */
CheckNodeInstalled() {
    try {
        result := RunWait('node --version', , "Hide")
        return (result == 0)
    } catch {
        return false
    }
}

/**
 * Verify that the PDF parser exists and a Node executable is available.
 * @returns {Object}  { ready: bool, error: string }
 */
CheckPDFParserReady() {
    parser := LocatePDFParser()
    if (parser == "")
        return { ready: false,
            error: "PDF parser not built. Run 'npm run build' in tools/pdfParser folder." }

    nodeExe := LocateNodeExe()
    if (nodeExe == "node" && !CheckNodeInstalled())
        return { ready: false,
            error: "Node.js not installed and no portable Node bundled in dist\node\" }

    return { ready: true, error: "" }
}
