# scripts

R scripts that download the raw data and create the files in `data/derived/`.
Run them in order from the repository root. If an important check fails, the
script stops with an error message.

| Script | Reads | Writes | What it does |
|---|---|---|---|
| `00_download_metadata.R` | gnomAD public AWS mirror | `data/raw/gnomad_meta_updated.tsv` | Downloads the gnomAD v3.1.2 HGDP+1KG sample metadata (skipped if the file is already there) |
| `01_populations.R` | `data/raw/gnomad_meta_updated.tsv` | `data/derived/populations_54.csv` | One row per HGDP population, with Bergström et al. (2020) coordinates and regions; checks for 54 populations at 52 sites |
| `02_climate_data.R` | `data/derived/populations_54.csv`; downloads WorldClim 2.1 to `data/raw/worldclim/` | `data/derived/climate_54.csv`, `climate_buffers.csv`, `climate_sensitivity.csv` | Climate at the point and as area-weighted means over 10–100 km buffers, annual photoperiod range, and how much each value changes with the radius |

```r
source("scripts/00_download_metadata.R")
source("scripts/01_populations.R")
source("scripts/02_climate_data.R")
```
**Download size.** The first time you run `02_climate_data.R`, it downloads the
WorldClim climate maps (about 10 GB). Later runs reuse the saved maps.

**Quick test.** To check that the script works without the big download, change
this line in its Settings section:

    RESOLUTION <- 10     # test only: coarser maps, much smaller download

The final files must be made with `RESOLUTION <- 0.5` (maps at ~1 km). The
coarser test maps give different climate values, so don't keep the test results.