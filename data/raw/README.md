# data/raw

Files downloaded from other sources, exactly as they were published. This
folder is empty in the repository (only this README is kept) because the files
can be downloaded again: run the scripts as described below.

| File or folder | Source | How to get it |
|---|---|---|
| `gnomad_meta_updated.tsv` | gnomAD v3.1.2 HGDP + 1KG sample metadata | Run `scripts/00_download_metadata.R`, which downloads it from the gnomAD public release (`release/3.1/secondary_analyses/hgdp_1kg_v2/metadata_and_qc/gnomad_meta_updated.tsv`). Direct link: https://gnomad-public-us-east-1.s3.amazonaws.com/release/3.1/secondary_analyses/hgdp_1kg_v2/metadata_and_qc/gnomad_meta_updated.tsv |
| `worldclim/` | WorldClim 2.1 bioclimatic variables at 30 arc-seconds (Fick and Hijmans 2017) | Run `scripts/02_climate_data.R`, which downloads them on the first run (about 10 GB). Information on the variables: https://www.worldclim.org/data/bioclim.html |

`scripts/01_populations.R` reads `gnomad_meta_updated.tsv`, and
`scripts/02_climate_data.R` reads the maps in `worldclim/`.

The tables built from these files are committed in `data/derived/`, so the
rest of the project runs without anything in this folder.