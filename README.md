# Visualizing the Design Space of a Circadian Climate-Adaptation Study

INFO 526 - Project 2 - M.A. Sans-Fuentes

## Goal

POLYCLOCK is a population-genomics project asking whether the human
circadian clock has adapted to regional light and temperature regimes. This
project builds an interactive Shiny application that visualizes the
geographic and climatic structure of 54 human populations, to assess whether
the data and study design can answer that question before any genetic
analysis.

The figures check three conditions:

1. whether climate can be distinguished from ancestry;
2. whether temperature can be separated from day length;
3. whether the population coordinates are precise enough for the resolution
   of the climate data.

Only population metadata and climate are used here; no genetic data.

## Repository structure


```         
Project2_POLYCLOCK_VIZ/
|--- README.md                      # project overview and how to reproduce
|--- abstract.qmd                   # abstract (written at the end)
|--- about.Rmd                      # about page 
|--- data/
|   |--- README.md                  # codebook for every file
|   |--- raw/                       # downloads, not in the repository
|   │   |--- README.md
|   |--- derived/                   # tables built by the scripts
|       |--- populations_54.csv
|       |--- climate_54.csv
|       |--- climate_buffers.csv
|       |--- climate_sensitivity.csv
|       |--- README.md
|--- scripts/
|   |--- 00_download_metadata.R     # gnomAD metadata
|   |--- 01_populations.R           # population table
|   |--- 02_climate_data.R          # climate tables and photoperiod
|   |--- README.md
|--- proposal/                      # Proposal documents
|   |--- proposal.qmd
|--- proposal.html
|   |--- README.md    
|--- app/                           # (planned) Shiny app and its README
|--- presentation/                  # (planned) Quarto slides and README
|--- writeup/                       # (planned) final write-up and README
|--- images/                        # (planned) figures
```


## How to reproduce
To be added later


# References

- Bergström, A., McCarthy, S.A., Hui, R. et al. (2020). Insights into human
  genetic variation and population history from 929 diverse genomes.
  *Science* 367(6484), eayy512. <https://doi.org/10.1126/science.aay5012>
- Fick, S.E. and Hijmans, R.J. (2017). WorldClim 2: new 1-km spatial
  resolution climate surfaces for global land areas. *International Journal
  of Climatology* 37(12), 4302–4315. <https://doi.org/10.1002/joc.5086>
- Koenig, Z., Yohannes, M.T., Nkambule, L.L. et al. (2024). A harmonized
  public resource of deeply sequenced diverse human genomes. *Genome
  Research* 34(5), 796–809. <https://doi.org/10.1101/gr.278378.123>

## Data sources

- gnomAD v3.1.2 HGDP + 1KG sample metadata (`gnomad_meta_updated.tsv`).
  Genome Aggregation Database.
  <https://gnomad-public-us-east-1.s3.amazonaws.com/release/3.1/secondary_analyses/hgdp_1kg_v2/metadata_and_qc/gnomad_meta_updated.tsv>
  (accessed October 2026).
- WorldClim 2.1 bioclimatic variables, 30 arc-seconds.
  <https://www.worldclim.org/data/worldclim21.html> (accessed October 2026).
