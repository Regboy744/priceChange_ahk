"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const node_fs_1 = __importDefault(require("node:fs"));
const node_path_1 = __importDefault(require("node:path"));
const parsePdf_1 = require("./parser/parsePdf");
function resolveCliOptions() {
    const args = process.argv.slice(2);
    const inputArg = args[0];
    const outputArg = args[1];
    const input = inputArg
        ? node_path_1.default.resolve(process.cwd(), inputArg)
        : node_path_1.default.resolve(process.cwd(), 'pdfParser', 'pricechange.pdf');
    const output = outputArg
        ? node_path_1.default.resolve(process.cwd(), outputArg)
        : node_path_1.default.resolve(process.cwd(), 'pdfParser', 'output.json');
    return { input, output };
}
async function main() {
    const { input, output } = resolveCliOptions();
    if (!node_fs_1.default.existsSync(input)) {
        console.error(`Input PDF not found: ${input}`);
        process.exitCode = 1;
        return;
    }
    const labels = await (0, parsePdf_1.parsePdf)(input);
    const payload = {
        source: node_path_1.default.basename(input),
        count: labels.length,
        labels,
    };
    node_fs_1.default.mkdirSync(node_path_1.default.dirname(output), { recursive: true });
    node_fs_1.default.writeFileSync(output, JSON.stringify(payload, null, 2), 'utf8');
    console.log(`Parsed ${labels.length} labels -> ${output}`);
}
main().catch((error) => {
    console.error('Parsing failed:', error);
    process.exitCode = 1;
});
