# Data

- **gnomAD v3.1.2 HGDP+1KG sample metadata** (`raw/gnomad_meta_updated.tsv`): One row per sequenced individual (4,150 in total, 948 from the Human Genome Diversity Project), with population, region and coordinates (Bergström et al. 2020; Koenig et al. 2024). Downloaded by `scripts/00_download_metadata.R`.

- **Population table** (`derived/populations_54.csv`): One row per population, built from the HGDP individuals by `scripts/01_populations.R`: 54 populations at 52 distinct sampling sites. Balochi and Brahui share a sampling site, as do Druze and Palestinian; they are distinct groups with identical coordinates.

- **WorldClim 2.1 climate maps** (Fick & Hijmans 2017): Global gridded climate maps at 30 arc-seconds (about 1 km). We use five bioclimatic variables (https://www.worldclim.org/data/bioclim.html): annual mean temperature (BIO1), temperature seasonality (BIO4), mean temperature of the warmest and coldest quarters (BIO10, BIO11) and annual precipitation (BIO12). Downloaded by `scripts/02_climate_data.R` (about 10 GB).

- **Climate tables** (`derived/climate_54.csv`, `climate_buffers.csv`, `climate_sensitivity.csv`): Built by `scripts/02_climate_data.R`. They give the climate at each population's coordinate and averaged over circles of 10–100 km around it, the annual photoperiod range at its latitude, and how much the values change with the radius.


| Folder | Contents |
|------------------------------------|------------------------------------|
| `raw/` | Original downloads: the gnomAD metadata file and the WorldClim maps (not in the repository; run `scripts/00_download_metadata.R` and `scripts/02_climate_data.R`) |
| `derived/` | Tables built from `raw/` by the scripts in `scripts/` |  


## Codebook

### `raw/gnomad_meta_updated.tsv`

`scripts/01_populations.R` reads only these columns:

| Column | Type | Description |
|------------------------|------------------------|------------------------|
| `s`    | text | Sample identifier |
| `subsets.hgdp` | TRUE/FALSE | TRUE for the 948 HGDP individuals (the rest are 1000 Genomes) |
| `high_quality` | TRUE/FALSE | gnomAD's sample QC flag |
| `population`   | text | Population name (Bergström et al. 2020 labels) |
| `latitude`, `longitude` | number | Coordinates of the population, decimal degrees |
| `region` | text | Geographic region (blank for 27 HGDP individuals) |

The file also has an older set of population columns (names starting with `hgdp_tgp_meta.`). They are not read: in our check they have 52 populations and different coordinates for PapuanHighlands, NorthernHan and Mongolian.

### `derived/populations_54.csv`

Built by `scripts/01_populations.R`. One row per population.

| Column           | Type       | Description                                                                                                       |
|------------------|------------|-------------------------------------------------------------------------------------------------------------------|
| `population`     | text       | HGDP population name (Bergström et al. 2020 labels)                                                               |
| `region`         | text       | Geographic region: AFRICA, AMERICA, CENTRAL_SOUTH_ASIA, EAST_ASIA, EUROPE, MIDDLE_EAST, OCEANIA                   |
| `lat`            | number     | Latitude of the sampling site, decimal degrees (negative = south)                                                 |
| `lon`            | number     | Longitude of the sampling site, decimal degrees (negative = west)                                                 |
| `n`              | integer    | Number of sequenced individuals                                                                                   |
| `n_high_quality` | integer    | Individuals passing gnomAD's sample QC flag (`high_quality`)                                                      |
| `all_qc_flagged` | TRUE/FALSE | TRUE if no individual passes the QC flag (a gnomAD sample-QC artefact for six isolated populations; all are kept) |
| `site_id`        | integer    | Sampling-site identifier; populations sharing coordinates share a `site_id`                                       |
| `n_pops_at_site` | integer    | Number of populations at that site (1 or 2)                                                                       |


### `derived/climate_54.csv`

Built by `scripts/02_climate_data.R`. One row per population: climate at the sampling point and photoperiod. 

| Column                                               | Type                      | Description                                                                                                                             |
|------------------------------------------------------|---------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| `population`, `region`, `lat`, `lon`, `n`, `site_id` |                           | As in `populations_54.csv`                                                                                                              |
| `BIO1`                                               | °C                        | Annual mean temperature at the point                                                                                                    |
| `BIO4`                                               | SD × 100                  | Temperature seasonality: standard deviation of the 12 monthly means, × 100 (859 = 8.59 °C)                                              |                                            
| `BIO10`                                              | °C                        | Mean temperature of the warmest quarter                                                                                                 |
| `BIO11`                                              | °C                        | Mean temperature of the coldest quarter                                                                                                 |
| `BIO12`                                              | mm                        | Annual precipitation                                                                                                                    |
| `photoperiod_range_h`                                | hours                     | Longest minus shortest day length over the 365 days of the year, at the site's latitude (Forsythe et al. 1995 model, sunrise to sunset) |
| `land_fraction`                                      | 0 or 1                    | 1 if the point falls on land; 0 if it falls on water (climate values are then NA)                                                       |
| `res_arcmin`                                         | arc-minutes               | WorldClim resolution used (0.5 = 30 arc-seconds, ~1 km)                                                                                 |
 

### `derived/climate_buffers.csv`
    
Built by `scripts/02_climate_data.R`. One row per population per radius (54 × 6 = 324 rows).

| Column                                               | Type                       | Description |
|------------------------------------------------------|----------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `population`, `region`, `lat`, `lon`, `n`, `site_id` |                            | As in `populations_54.csv`                                                                                                                |
| `radius_km`                                          | km                         | 0 (the point itself), 10, 25, 50, 75 or 100                                                                                               |
| `BIO1`, `BIO4`, `BIO10`, `BIO11`, `BIO12`            | As in climate_54.csv       | Area mean within the radius, weighted by the fraction of each grid cell inside it; sea cells skipped. At radius 0, the value at the point |
| `land_fraction`                                      | 0–1                        | Share of the circle that is land (1 = all land, 0.5 = half sea, 0 = all sea); 0 or 1 at radius 0                                          |                                                                   
| `photoperiod_range_h`                                | hours                      | As in `climate_54.csv` (does not vary with radius)                                                                                        |
| `res_arcmin`                                         | arc-minutes                | WorldClim resolution used                                                                                                                 |
    
### `derived/climate_sensitivity.csv`
    
Built by `scripts/02_climate_data.R`. One row per population: how far its climate values move across radii.

| Column                                          | Type                      | Description                                      |
|-------------------------------------------------|---------------------------|--------------------------------------------------|
| `population`, `region`, `lat`, `lon`, `site_id` |                           | As in `populations_54.csv`                       |
| `bio1_point`                                    | °C                        | BIO1 at the point                                |
| `bio1_shift`                                    | °C                        | Largest minus smallest BIO1 across all radii     |
| `bio4_point`                                    | SD × 100                  | BIO4 at the point                                |
| `bio4_shift`                                    | SD × 100                  | Largest minus smallest BIO4 across all radii     |
| `min_land_fraction`                             | 0–1                       | Smallest land share across radii (low = coastal) |
| `res_arcmin`                                    | arc-minutes               | WorldClim resolution used                        |
    
## Methods notes
    
**Area means.** ... `land_fraction` records how much land that was.

`land_fraction` is 0 or 1 at the point. In `climate_buffers.csv` the same column is the share of the circle that is land (0 to 1).  

