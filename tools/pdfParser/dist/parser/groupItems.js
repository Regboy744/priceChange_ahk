"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.groupItemsIntoLines = groupItemsIntoLines;
const DEFAULT_Y_TOLERANCE = 2.5;
function groupItemsIntoLines(items, yTolerance = DEFAULT_Y_TOLERANCE) {
    const sorted = [...items].sort((a, b) => b.y - a.y || a.x - b.x);
    const lines = [];
    for (const item of sorted) {
        const target = lines.find((line) => Math.abs(line.y - item.y) <= yTolerance);
        if (!target) {
            lines.push({ y: item.y, text: item.text, items: [item] });
        }
        else {
            target.items.push(item);
            target.items.sort((a, b) => a.x - b.x);
            target.text = target.items
                .map((i) => i.text)
                .join(' ')
                .replace(/\s+/g, ' ')
                .trim();
        }
    }
    return lines.sort((a, b) => b.y - a.y);
}
