# Welcome to LFQBench2: an R package that can be used to compare the outcomes of protein/peptide searches

## Installation
Install `devtools` with
```{r}
install.packages("devtools")
```
and then, install our software directly from github:
```{r}
devtools::install_github("MatteoLacki/LFQBench2")
```


## Usage:

### Reading the reports
The package can be used in R scripts to open reports of the ISOquant package (all three types: protein, peptides, and simple_proteins):

```{r}
library(LFQBench2)

# Read in isoquant report in the long-format
DL = read_isoquant(
	report = 'protein',
	path = "/Users/great_user/his_wonderful_data/super_ISOQuant_protein_report.xlsx",
    col_pattern = "some_text_that_only_appears_in_columns_with_intensities")
```

Check out `?read_isoquant`, `?read_isoquant_protein_report`, `?read_isoquant_peptide_report`, `?read_isoquant_simple_protein_report` for more help in R console.


### Comparing intensities of protein mixtures

With this package, you can produce plots like this
![alt text](https://github.com/MatteoLacki/LFQBench2/tree/master/picts/hye.jpg)
with as little as this code:
```{R}
# I assume you opened the protein data and stored it under D
D_meds = preprocess_proteins_4_intensity_plots(D)
o = plot_proteome_mix(E_meds_good, organisms, bins=100)
o$scatterplot
o$hex_dens2d
o$dens2d
W = plot_grid(plotlist=o, nrow=1, align='h', axis='l')
```
(install cowplot for the extra `plot_grid` function).

## Command line usage:
* Find out where your package was installed with `find.package('LFQBench2')` in your R console
* add it to your PATH variable (this might work on Windows too, but it will be much more complicated).

Now you can simply use:
```{bash}
read_isospec_report -p <Pattern> <Path>
```

Run `read_isospec_report -h` for further help.

## Currently we support a rather restrictive list of software programmes:
* ISOQuant protein reports.
