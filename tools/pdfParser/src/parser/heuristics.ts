// A standalone price token, optionally wrapped in currency / punctuation (€, parentheses…),
// but never containing letters — so a glued volume like "1.75LTR" is rejected while
// "€4.25", "€ 4.25", "4.25" and "4,25" are accepted. NOTE: trailing letters are intentionally
// NOT stripped; stripping them would turn "1.75LTR" back into "1.75".
const PRICE_TOKEN_REGEX = /^[^\dA-Za-z]*(\d{1,4})[.,](\d{2})[^\dA-Za-z]*$/;
// A line carrying a (spaced) unit or per-unit word is a description / sub-price line,
// not the product price line — catches "BOTTLE 1.75 LTR", "€ 2.43 per LTR", "67.20 GRM".
// (The real price line is always a bare "€ X.XX" with no unit word in this data.)
const UNIT_WORD_REGEX = /\b(?:LTR|LTRS|LITRE|LITRES|ML|MLS|CL|GRM|GRMS|KG|KGM|KGS|PER|EACH|PCE|PCS|PK)\b/i;
const DATE_TOKEN_REGEX = /\b\d{1,2}\.\d{2}\b/;
const DIGITS_ONLY_REGEX = /^\d+$/;

function isValidEan13(code: string): boolean {
  if (!(code.length === 13 && DIGITS_ONLY_REGEX.test(code))) return false;
  const digits = code.split("").map((c) => Number.parseInt(c, 10));
  const checkDigit = digits[12] ?? 0;
  let sum = 0;
  // Weighting from the right (excluding check digit): 1,3,1,3,...
  for (let i = 11, weight = 3; i >= 0; i -= 1, weight = weight === 3 ? 1 : 3) {
    sum += (digits[i] ?? 0) * weight;
  }
  const calc = (10 - (sum % 10)) % 10;
  return calc === checkDigit;
}

function isValidUpcA(code: string): boolean {
  if (!(code.length === 12 && DIGITS_ONLY_REGEX.test(code))) return false;
  const digits = code.split("").map((c) => Number.parseInt(c, 10));
  const checkDigit = digits[11] ?? 0;
  let sum = 0;
  // Positions are 1-based from the left (excluding check digit).
  for (let i = 0; i < 11; i += 1) {
    const d = digits[i] ?? 0;
    sum += (i % 2 === 0 ? 3 : 1) * d;
  }
  const calc = (10 - (sum % 10)) % 10;
  return calc === checkDigit;
}

export function extractPrice(text: string): number | null {
  if (UNIT_WORD_REGEX.test(text)) return null;
  for (const token of text.trim().split(/\s+/)) {
    const match = token.match(PRICE_TOKEN_REGEX);
    if (!match) continue;
    const value = Number.parseFloat(`${match[1]}.${match[2]}`);
    if (Number.isFinite(value)) return value;
  }
  return null;
}

export function extractEan(text: string): string | null {
  // Important: some pages show spaced digit groups on the same line as dates (e.g. "454 799 864 473 30.01 ...").
  // If we try to "normalize digits" with a loose regex, we can accidentally absorb the first digit of the date,
  // producing wrong codes like "4547998644733". So we ignore lines containing date tokens altogether.
  if (DATE_TOKEN_REGEX.test(text)) return null;

  const tokens = text.trim().split(/\s+/).filter(Boolean);
  const digitTokens = tokens.filter((t) => DIGITS_ONLY_REGEX.test(t));
  if (digitTokens.length === 0) return null;

  // In well-formed labels, the left-most numeric token is the product code/barcode.
  // Sometimes it is short (e.g. plants: "997885"), sometimes it's a barcode (12/13 digits),
  // and the 10-digit token is usually an internal code.
  const first = digitTokens[0] ?? null;
  if (first) {
    if (first.length === 13 && isValidEan13(first)) return first;
    if (first.length === 12 && isValidUpcA(first)) return first;
    if (first.length >= 5 && first.length <= 11 && first.length !== 10) return first;
  }

  // Prefer explicit valid EAN-13 / UPC-A tokens (barcode/UPC printed as a single token), left-to-right.
  const token13 = digitTokens.find((t) => t.length === 13 && isValidEan13(t));
  if (token13) return token13;
  const token12 = digitTokens.find((t) => t.length === 12 && isValidUpcA(t));
  if (token12) return token12;

  // Some codes are printed as small digit groups (e.g. "454 799 864 473"). Reconstruct only from small groups.
  for (let start = 0; start < digitTokens.length; start += 1) {
    let acc = "";
    for (let i = start; i < digitTokens.length; i += 1) {
      const tok = digitTokens[i];
      if (tok.length > 4) break;
      acc += tok;
      if (acc.length === 13 && isValidEan13(acc)) return acc;
      if (acc.length === 12 && isValidUpcA(acc)) return acc;
      if (acc.length > 13) break;
    }
  }

  // Fallback: return the left-most numeric token if it's at least 5 digits.
  if (first && first.length >= 5) return first;
  return null;
}

export function normalizeDescription(lines: string[]): string {
  return lines
    .map((line) => line.replace(/\s+/g, " ").trim())
    .filter(Boolean)
    .join(" ")
    .replace(/\s+/g, " ")
    .trim();
}
