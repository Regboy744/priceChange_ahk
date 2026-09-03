"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.parsePdf = parsePdf;
const node_fs_1 = __importDefault(require("node:fs"));
const groupItems_1 = require("./groupItems");
const heuristics_1 = require("./heuristics");
const PDFJS_MODULE = "pdfjs-dist/legacy/build/pdf.mjs";
function kmeans1d(values, k) {
    const sorted = [...values].sort((a, b) => a - b);
    const centers = [];
    for (let i = 0; i < k; i += 1) {
        const idx = Math.floor(((i + 0.5) / k) * (sorted.length - 1));
        centers.push(sorted[idx]);
    }
    let assignments = new Array(values.length).fill(0);
    for (let iter = 0; iter < 20; iter += 1) {
        let moved = false;
        for (let i = 0; i < values.length; i += 1) {
            const v = values[i];
            let best = 0;
            let bestDist = Math.abs(v - centers[0]);
            for (let c = 1; c < k; c += 1) {
                const dist = Math.abs(v - centers[c]);
                if (dist < bestDist) {
                    best = c;
                    bestDist = dist;
                }
            }
            if (assignments[i] !== best) {
                assignments[i] = best;
                moved = true;
            }
        }
        const sums = new Array(k).fill(0);
        const counts = new Array(k).fill(0);
        for (let i = 0; i < values.length; i += 1) {
            sums[assignments[i]] += values[i];
            counts[assignments[i]] += 1;
        }
        for (let c = 0; c < k; c += 1) {
            if (counts[c] > 0)
                centers[c] = sums[c] / counts[c];
        }
        if (!moved)
            break;
    }
    let sse = 0;
    for (let i = 0; i < values.length; i += 1) {
        const d = values[i] - centers[assignments[i]];
        sse += d * d;
    }
    return { centers, assignments, sse };
}
function splitItemsIntoColumns(items) {
    if (items.length === 0)
        return [];
    const xs = items.map((item) => item.x);
    let bestK = 1;
    let bestAssignments = new Array(items.length).fill(0);
    let bestCenters = [xs[0] ?? 0];
    let prevSse = Number.POSITIVE_INFINITY;
    for (let k = 1; k <= 3; k += 1) {
        const result = kmeans1d(xs, k);
        const counts = new Array(k).fill(0);
        result.assignments.forEach((a) => (counts[a] += 1));
        const minCount = Math.max(5, Math.floor(items.length * 0.02));
        const tooSmall = counts.some((count) => count < minCount);
        if (tooSmall && k > 1)
            break;
        const improvement = prevSse === Number.POSITIVE_INFINITY ? 1 : (prevSse - result.sse) / prevSse;
        if (k > 1 && improvement < 0.2)
            break;
        bestK = k;
        bestAssignments = result.assignments;
        bestCenters = result.centers;
        prevSse = result.sse;
    }
    const columns = new Array(bestK).fill(0).map(() => []);
    for (let i = 0; i < items.length; i += 1) {
        columns[bestAssignments[i]].push(items[i]);
    }
    const ordered = columns
        .map((col, idx) => ({ col, center: bestCenters[idx] ?? 0 }))
        .sort((a, b) => a.center - b.center)
        .map((entry) => entry.col);
    return ordered;
}
async function parsePdf(filePath) {
    const pdfjsImport = (await import(PDFJS_MODULE));
    const pdfjsLib = pdfjsImport.default ?? pdfjsImport;
    const fileBuffer = node_fs_1.default.readFileSync(filePath);
    const data = new Uint8Array(fileBuffer);
    const pdf = await pdfjsLib.getDocument({ data }).promise;
    const labels = [];
    for (let pageIndex = 0; pageIndex < pdf.numPages; pageIndex += 1) {
        const page = await pdf.getPage(pageIndex + 1);
        const content = await page.getTextContent();
        const items = content.items
            .map((item) => {
            const [a, , , d, e, f] = item.transform;
            const text = String(item.str ?? "").trim();
            return {
                text,
                x: e,
                y: f,
                width: item.width ?? Math.abs(a),
                height: item.height ?? Math.abs(d),
            };
        })
            .filter((item) => item.text.length > 0);
        const columns = splitItemsIntoColumns(items);
        for (const column of columns) {
            const columnLines = (0, groupItems_1.groupItemsIntoLines)(column);
            let descriptionLines = [];
            let price = null;
            let ean = null;
            const flushLabel = () => {
                if (!descriptionLines.length && price === null && ean === null)
                    return;
                labels.push({
                    description: (0, heuristics_1.normalizeDescription)(descriptionLines),
                    price,
                    ean,
                    page: pageIndex + 1,
                });
                descriptionLines = [];
                price = null;
                ean = null;
            };
            for (const line of columnLines) {
                if (!line.text)
                    continue;
                const lineText = line.text;
                const linePrice = price === null ? (0, heuristics_1.extractPrice)(lineText) : null;
                const digitsCount = lineText.replace(/\D/g, "").length;
                const hasLetters = /[A-Za-z]/.test(lineText);
                const isDateLine = /\b\d{1,2}\.\d{2}\b/.test(lineText);
                const isBarcodeLine = digitsCount >= 8 && !hasLetters && !isDateLine && linePrice === null;
                const lineEan = (0, heuristics_1.extractEan)(lineText);
                if (linePrice !== null && price === null) {
                    price = linePrice;
                    continue;
                }
                if (lineEan) {
                    ean = lineEan;
                    flushLabel();
                    continue;
                }
                if (isBarcodeLine && price !== null) {
                    flushLabel();
                    continue;
                }
                if (price === null && !isBarcodeLine && !isDateLine) {
                    descriptionLines.push(lineText);
                }
            }
            flushLabel();
        }
    }
    return labels.filter((label) => label.description || label.price !== null || label.ean !== null);
}
