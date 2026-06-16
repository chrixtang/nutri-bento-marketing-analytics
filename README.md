# Nutri-bento — A Data-Driven Approach to Launching a Healthy Meal Service in Hong Kong

Marketing-analytics feasibility study for a hypothetical healthy *bento* (lunchbox)
takeaway brand in Hong Kong. Built for **STAT3613 Marketing Analytics** at the
University of Hong Kong. The project takes a single consumer survey and runs a full
analytics pipeline — **dimensionality reduction → customer segmentation → predictive
regression → conjoint product design** — and turns the output into concrete pricing,
targeting, and menu decisions.

**Team:** Lee Man Nok · Wong King Wang · Tang Wai Shing (equal contribution)
**Tools:** R (`tidyverse`, `cluster`, `factoextra`, `corrplot`, `mlogit`, `conjanal`, `car`)

---

## What the project answers

| Business question | Method | Headline result |
|---|---|---|
| What underlying attitudes drive healthy eating? | **Factor Analysis (PCA + varimax)** on 7 Likert items | 3 factors explain **79.7%** of variance: General Health Consciousness (60.8%), Nutritional Quality Focus (10.4%), Health Investment & Monitoring (8.6%). KMO = 0.78 |
| Who are our customers? | **K-means clustering** on PC scores (k chosen by elbow) | 4 actionable segments, profiled by health attitude, age, income, willingness-to-pay and purchase frequency |
| What predicts spend & loyalty? | **OLS regression** with VIF / residual diagnostics | Income (p = 0.016) and segment membership are the significant drivers of willingness-to-pay; WTP model R² = 0.31 |
| What should the menu be? | **Conjoint analysis (multinomial logit)** on protein / grain / vegetable | Optimal core bento = **Beef (35% share) + White Rice (41%) + Leafy Greens / Root Veg** |

The integrated recommendation: launch a tiered menu, price the premium line at
HKD 65–80 for the "Highly Health Conscious" segment (≈38% of sample), and build the
default bento around the most-preferred ingredient combination.

---

## Repository layout

```
nutri-bento-marketing-analytics/
├── README.md
├── code/
│   ├── 01_pca_clustering.R       # Factor analysis (PCA), K-means segmentation, regression
│   └── 02_conjoint_analysis.R    # Multinomial-logit conjoint for protein/grain/vegetable
├── data/
│   ├── Proj3613.csv              # Conjoint responses: protein + grain choices
│   ├── vegetable.csv             # Conjoint responses: vegetable choices
│   └── (Eating habits 2.csv)     # Raw survey — NOT included, see note below
└── report/
    └── Nutri-bento_Report.pdf    # Full written report with figures & tables
```

### A note on the data
The conjoint inputs (`Proj3613.csv`, `vegetable.csv`) are included. The **raw survey
file is intentionally not committed** because it holds personal respondent information
(income, occupation, demographics). `code/01_pca_clustering.R` points at a
`SURVEY_PATH` placeholder so you can drop in your own copy to reproduce the PCA,
clustering and regression steps. The conjoint script in `code/02` runs as-is against
the committed CSVs.

---

## How to run

```r
# from the repository root, in R / RStudio
install.packages(c("tidyverse", "cluster", "factoextra", "corrplot", "car", "mlogit"))
# conjanal is from GitHub:
# devtools::install_github("cwkwanstat/conjanal")

source("code/02_conjoint_analysis.R")   # reproduces the menu-preference results
source("code/01_pca_clustering.R")       # requires the raw survey CSV (see note)
```

---

## Methods, in brief

- **Factor Analysis / PCA** — seven 1–5 health-attitude items standardized, then reduced
  with `prcomp`. Adequacy checked with KMO and Bartlett's test of sphericity; factors
  retained on the scree/70%-variance rule and interpreted from loadings.
- **K-means segmentation** — clustering on the first three PC scores, *k* selected via the
  elbow method (within-cluster sum of squares). Segments validated by between- vs.
  within-cluster variance and profiled on demographics and behaviour.
- **Regression** — two OLS models (willingness-to-pay; monthly purchase frequency) with
  health-factor scores, age, income and cluster dummies. Multicollinearity screened with
  VIF (all < 3) and residuals inspected for normality.
- **Conjoint analysis** — choice data reshaped to long form and fit with `mlogit`;
  part-worth utilities and softmax preference shares computed per attribute level to rank
  ingredient options.

## Known limitations (documented in the report)
Convenience sample (n ≈ 69–75, 64% male) → limited generalizability; survey measures
*intent* not *behaviour* (intention–action gap); conjoint omitted price and sauce as
attributes. Future work: stratified random sample and a choice-based conjoint that
includes price.
