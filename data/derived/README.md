# data/derived

Tables built by the scripts in `scripts/` from the files in `data/raw/`.
These tables are stored in the repository, so the app and the write-up work as soon as someone clones it, without downloading the raw data.

| File | Rows | Built by |
|---|---|---|
| `populations_54.csv` | 54 (one per population) | `scripts/01_populations.R` |
| `climate_54.csv` | 54 (one per population) | `scripts/02_climate_data.R` |
| `climate_buffers.csv` | 324 (54 populations × 6 radii) | `scripts/02_climate_data.R` |
| `climate_sensitivity.csv` | 54 (one per population) | `scripts/02_climate_data.R` |

Column definitions are in the codebook in `data/README.md`.