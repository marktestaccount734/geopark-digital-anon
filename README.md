# Digital Transformation in UNESCO Global Geoparks

## Introduction

This repository contains the data and reproducible analytical workflows supporting the study:

**Does Digital Transformation Drive Innovation in UNESCO Global Geoparks? Evidence from a Global Survey on the Role of Digital Tools**

The project investigates how digital tools are used across UNESCO Global Geoparks (UGGps) and evaluates their role in supporting geopark operations, including geoconservation, management, geotourism, education, and regional development.

The repository provides an anonymised dataset and a suite of R scripts used to conduct descriptive, bivariate, and multivariable statistical analyses.

---

## Analytical Framework

The analysis is structured to address five research questions examining:

- The distribution and types of digital tools used in geoparks  
- Differences in usage across networks and demographics  
- Relationships between digital tools and operational areas  
- Patterns of digital tool use across operational functions  
- Predictors of digital tool adoption  

---

## Methods Overview

### Descriptive Analysis
Frequencies and proportions were calculated to characterise:
- Digital tool types  
- Respondent demographics  
- Geographic and operational characteristics  
- Usage patterns across operational areas  

---

### Chi-Square Analysis

Chi-square tests of independence were used to examine associations between categorical variables, including:

- Demographics and frequency of digital tool use  
- Digital tool types and operational areas  
- Usage frequency and operational areas  

Outputs include:
- Observed and expected contingency tables  
- Row and column proportions  
- Chi-square statistics (χ², df, p-values)  
- Heatmap visualisations for interpretation  

---

### Regression Modelling

#### Negative Binomial Regression
A negative binomial regression model was used to examine predictors of digital tool adoption (count data).

- A full model including all predictors was specified  
- Backward selection based on AIC was applied  
- A reduced model retained only statistically significant predictors  

Outputs include:
- Coefficients  
- Incidence Rate Ratios (IRR)  
- Confidence intervals  
- p-values  

---

#### Binary Logistic Regression
Binary logistic regression models were used to assess predictors of uptake for specific digital tools (e.g., VR, AR, mobile applications).

- The full set of predictors was retained  
- Models estimate the likelihood of tool adoption  

Outputs include:
- Coefficients  
- Odds ratios  
- Confidence intervals  
- p-values  

---

## Data Processing and Cleaning Workflow

Due to ethical constraints, raw survey responses cannot be shared. However, the full data processing workflow used to derive the cleaned dataset is documented below.

### Data Preparation

- Survey responses were translated into English where required (Spanish and Chinese responses)
- Additional contextual variables were added from external sources:
  - Country  
  - Regional network  
  - Geopark size  
  - Year of designation  
  - Year of last revalidation  

Sources:
- Global Geoparks Network (GGN) database  
- UNESCO Global Geoparks map and annual reports  

---

### Dataset Structuring

- UNESCO Global Geoparks (UGGps) and aspiring geoparks were separated due to differences in population definition and completeness
- Analysis focuses on UGGps that were designated in 2022 and aspiring geoparks that were designated in 2023.

---

### Handling Duplicate Responses

- Duplicate geopark responses were consolidated  
- Geopark manager responses were prioritised  
- Binary discrepancies (Yes/No) were resolved by recording **"Yes"**  

---

### Missing and Unknown Values

- NA and blank values were recoded as **"Unknown"** and not used in the analysis
- Handling of specific categorical variables:
  - Gender → "Unspecified"  
  - Years of employment → "Unspecified"  

---

### Derived Variables

#### Digital Tool Adoption

- Binary responses ("Yes") were summed to create:
  - **Adoption_Count**

- Adoption levels were categorised as:
  - Low (≤ 33%)  
  - Moderate (> 33% and ≤ 66%)  
  - High (> 66%)  

---

#### Geopark Classification Variables

- **Era of designation** (Du & Girault, 2018)
- **Lifecycle stage** (adapted from UNESCO and Pásková, 2022)
- **Size categories** based on dataset distribution  

---

### Qualitative Data

- Short-text responses were grouped into thematic categories  
- Categories were quantified and integrated with quantitative analysis  

---

## Usage

The repository is designed to reproduce the statistical analyses presented in the study.

### Running the Analysis

1. Clone or download this repository  
2. The cleaned dataset is located in the `/data` folder but you will need to alter pathnames in the scripts  
3. Open the R scripts in the `/scripts` folder  

1. **Chi-square analysis**  
   - Examines associations between categorical variables  
   - Outputs contingency tables and Excel summaries  

2. **Binary logistic regression**  
   - Assesses predictors of uptake for specific digital tools  
   - Outputs coefficients, odds ratios, and confidence intervals  

3. **Negative binomial regression**  
   - Examines predictors of overall digital tool adoption (count data)  
   - Outputs coefficients, incidence rate ratios (IRR), and confidence intervals  

---

### Custom Analysis

Many scripts are parameterised using input variables (e.g., `var1`, `var2`), allowing users to:

- Run different variable combinations  
- Generate multiple contingency tables and visualisations  
- Reproduce or extend the analyses  

Example:

```r
runChiSquareTest("AR", "Management_Structure")
```

### Additional Information

Created: 29 March 2026  

This repository contains supplementary data and code associated with the study:  
*Does Digital Transformation Drive Innovation in UNESCO Global Geoparks? Evidence from a Global Survey on the Role of Digital Tools.*  

A DOI will be added once the article is published.

### References

- Du, Y., & Girault, Y. (2018). A Genealogy of UNESCO Global Geopark: Emergence and Evolution. International Journal of Geoheritage and Parks, 6(2), 1–17. https://doi.org/10.17149/ijgp.j.issn.2577.4441.2018.02.001
- Pásková, M. (2022). Geopark Certification as an Efficient Form of Sustainable Management of a Geotourism Destination. In V. Braga, A. Duarte, & C. S. Marques (Eds.), Economics and Management of Geotourism (pp. 65–85). Springer International Publishing. https://doi.org/10.1007/978-3-030-89839-7_4
- UNESCO. (2022). Checklist to define an aspiring UNESCO Global Geopark (aUGGp). https://unesdoc.unesco.org/ark:/48223/pf0000383838

