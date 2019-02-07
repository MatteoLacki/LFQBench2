# Welcome to LFQBench2: an R package that can be used to compare the outcomes of protein/peptide searches

## Installation
```{r}
install.packages("LFQBench2")
```

## Usage:
The package can be used in R scripts:

```{r}
library(LFQBench2)

# Read in isoquant report in the long-format
DL = read_isoquant_report(
	path = "/Users/great_user/his_wonderful_data/super_ISOQuant_protein_report.xlsx",
        col_pattern = "some_text_that_only_appears_in_columns_with_intensities")
```

Check out `?read_isoquant_report` for more help while in R console.


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
