# proposal

The project proposal, as a Quarto document (`proposal.qmd`) that reads the derived data and reports dataset dimensions with inline code.

## Files

- `proposal.qmd`: the source
- `proposal.html`: the rendered proposal (generated from the `.qmd`; open it in a browser).

## Contents

- **High-level goal:** what the project builds and why
- **Goals and motivation:** the three conditions the figures test
  - *Data:* the datasets, why they were chosen, and their dimensions
  - *Research questions:* the three pre-analysis checks
  - *Approach:* the planned figures and the skills learned for the project
- **Work Plan:** weekly tasks with status, due date and priority; updated at least once a week
- **Repository organization:** the folder structure of this repository
- **References**

## Render

From the repository root:

``` bash
quarto render proposal/proposal.qmd
```

or open `proposal.qmd` in RStudio and click **Render**. It needs the R packages `readr` and `dplyr`.

Re-render and commit `proposal.html` whenever `proposal.qmd` or the data in `data/derived/` changes.
