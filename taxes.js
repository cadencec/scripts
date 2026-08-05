// Usage:
// 1. Fill out taxes.conf
// 2. Check brackets below
// 3. Run: node taxes.js ./taxes.conf
const fs = require("node:fs");

const confPath = process.argv[2];
if (!confPath) {
  console.error("Usage: node taxes.js <path-to-conf>");
  process.exit(1);
}

let conf;
try {
  conf = JSON.parse(fs.readFileSync(confPath, "utf8"));
} catch (error) {
  console.error(`Unable to read configuration from ${confPath}: ${error.message}`);
  process.exit(1);
}

const {
  income,
  weeks,
  standardDeduction,
  iraDeduction,
  paidFederal,
  paidOregon,
  paidMissouri,
  paidArkansas,
  quarter,
} = conf;

const requiredNumbers = {
  income,
  weeks,
  standardDeduction,
  iraDeduction,
  paidFederal,
  paidOregon,
  paidMissouri,
  paidArkansas,
  quarter,
};
const invalidKey = Object.entries(requiredNumbers).find(
  ([, value]) => typeof value !== "number" || !Number.isFinite(value),
);
if (invalidKey) {
  console.error(`Configuration value "${invalidKey[0]}" must be a number.`);
  process.exit(1);
}

const perWeek = income / weeks;
const extrapolated = perWeek * 52;
const subjectToSelfEmployment = 0.9235 * extrapolated;
const selfEmploymentTax = 0.153 * subjectToSelfEmployment;
const selfEmploymentDeduction = 0.5 * selfEmploymentTax;
console.log("Projected income:", {extrapolated, perWeek});
console.log("Self employment tax:", {subjectToSelfEmployment, selfEmploymentTax, selfEmploymentDeduction})

// Federal
const taxableIncome =
  extrapolated - standardDeduction - iraDeduction - selfEmploymentDeduction;
const ti = Math.max(taxableIncome, 0);

const threshold1 = 12400;
const threshold2 = 50400;
const threshold3 = 105700;
const threshold4 = 201775;

const bracket1 = 0.1 * Math.min(ti, threshold1);
const bracket2 = 0.12 * Math.max(Math.min(ti, threshold2) - threshold1, 0);
const bracket3 = 0.22 * Math.max(Math.min(ti, threshold3) - threshold2, 0);
const bracket4 = 0.24 * Math.max(Math.min(ti, threshold4) - threshold3, 0);
const bracketTotal = bracket1 + bracket2 + bracket3 + bracket4;
console.log("Federal Tax Brackets:", { bracket1, bracket2, bracket3, bracket4, bracketTotal });

const federalTax = bracketTotal + selfEmploymentTax;

const quarterRatio = quarter / 4;
const federalOwed = quarterRatio * federalTax;
const federalPayment = Math.trunc(federalOwed - paidFederal);
console.log(`IRS Direct Pay: ${federalPayment}`);

// Oregon
const oThreshold1 = 4300;
const oThreshold2 = 10750;
const oThreshold3 = 125000;
const oStandardDeduction = 2800

const oregonTaxable = extrapolated - oStandardDeduction;

const oBracket1 = 0.0475 * Math.min(oregonTaxable, oThreshold1);
const oBracket2 =
  0.0675 * Math.max(Math.min(oregonTaxable, oThreshold2) - oThreshold1, 0);
const oBracket3 =
  0.0875 * Math.max(Math.min(oregonTaxable, oThreshold3) - oThreshold2, 0);
const oBracketTotal = oBracket1 + oBracket2 + oBracket3;
const oregonOwed = quarterRatio * oBracketTotal;
const oregonPayment = Math.trunc(oregonOwed - paidOregon);
console.log(`Oregon: ${oregonPayment}`)

// Missouri (nonresident: tax on full income, then apportion by weeks)
const moThreshold1 = 1313
const moThreshold2 = 2626
const moThreshold3 = 3939
const moThreshold4 = 5252
const moThreshold5 = 6565
const moThreshold6 = 7878
const moThreshold7 = 9191
const moStandardDeduction = 15750
const moWeeks = 5
const moFullTaxable = Math.max(extrapolated - moStandardDeduction, 0);
const moRatio = moWeeks / 52;
const moBracket1 = 0 * Math.min(moFullTaxable, moThreshold1);
const moBracket2 = 0.02 * Math.max(Math.min(moFullTaxable, moThreshold2) - moThreshold1, 0);
const moBracket3 = 0.025 * Math.max(Math.min(moFullTaxable, moThreshold3) - moThreshold2, 0);
const moBracket4 = 0.03 * Math.max(Math.min(moFullTaxable, moThreshold4) - moThreshold3, 0);
const moBracket5 = 0.035 * Math.max(Math.min(moFullTaxable, moThreshold5) - moThreshold4, 0);
const moBracket6 = 0.04 * Math.max(Math.min(moFullTaxable, moThreshold6) - moThreshold5, 0);
const moBracket7 = 0.045 * Math.max(Math.min(moFullTaxable, moThreshold7) - moThreshold6, 0);
const moBracket8 = 0.047 * Math.max(moFullTaxable - moThreshold7, 0);
const moBracketTotal = moBracket1 + moBracket2 + moBracket3 + moBracket4 + moBracket5 + moBracket6 + moBracket7 + moBracket8;
const missouriOwed = moBracketTotal * moRatio;
const missouriPayment = Math.trunc(missouriOwed - paidMissouri);
console.log(`Missouri: ${missouriPayment}`);

// Arkansas (nonresident: tax on full income, then apportion by weeks)
const arThreshold1 = 5499
const arThreshold2 = 10899
const arThreshold3 = 15599
const arThreshold4 = 25699

const arStandardDeduction = 2470
const arWeeks = 4
const arFullTaxable = Math.max(extrapolated - arStandardDeduction, 0);
const arRatio = arWeeks / 52;
const arBracket1 = 0 * Math.min(arFullTaxable, arThreshold1);
const arBracket2 = 0.02 * Math.max(Math.min(arFullTaxable, arThreshold2) - arThreshold1, 0);
const arBracket3 = 0.03 * Math.max(Math.min(arFullTaxable, arThreshold3) - arThreshold2, 0);
const arBracket4 = 0.034 * Math.max(Math.min(arFullTaxable, arThreshold4) - arThreshold3, 0);
const arBracket5 = 0.039 * Math.max(arFullTaxable - arThreshold4, 0);
const arBracketTotal = arBracket1 + arBracket2 + arBracket3 + arBracket4 + arBracket5;
const arkansasOwed = arBracketTotal * arRatio;
const arkansasPayment = Math.trunc(arkansasOwed - paidArkansas);
console.log(`Arkansas: ${arkansasPayment}`);

// North Carolina (two weeks, under $1000 requirement for estimated payments, pay at end of year)
