# scripts

R scripts that download the raw data and create the files in `data/derived/`.
Run them in order from the repository root. If an important check fails, the
script stops with an error message.

| Script | Reads | Writes | What it does |
    |---|---|---|---|
    | `00_download_metadata.R` | gnomAD public AWS mirror | `data/raw/gnomad_meta_updated.tsv` | Downloads the gnomAD v3.1.2 HGDP+1KG sample metadata (skipped if the file is already there) |
    | `01_populations.R` | `data/raw/gnomad_meta_updated.tsv` | `data/derived/populations_54.csv` | One row per HGDP population, with Bergström et al. (2020) coordinates and regions; checks for 54 populations at 52 sites |
    
```r
source("scripts/00_download_metadata.R")
source("scripts/01_populations.R")
```
