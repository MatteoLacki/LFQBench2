# Welcome to LFQBench2: an R package that can be used to compare protein/peptide quantification results

### Installation
Install `devtools` with
```{r}
install.packages("devtools")
```
and then, install our software directly from github:
```{r}
devtools::install_github("MatteoLacki/LFQBench2")
```

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

With our package, you can produce plots like this ![](https://github.com/MatteoLacki/LFQBench2/blob/master/picts/hye_2.jpg "Comparing Human-Yeast-Ecoli Proteomes")
with as little as this code:
```{R}
library(LFQBench2)
D = read_isoquant(report='protein', path='path_to_your_ISOQuant_protein_report', long_df=TRUE)
D_meds = preprocess_proteins_4_intensity_plots(D)
o = plot_proteome_mix(E_meds_good, organisms, bins=100)
W = plot_grid(plotlist=o, nrow=1, align='h', axis='l')
```
(install cowplot for the extra `plot_grid` function, though).
To get the first plot only, interpret additionally
```{R}
o$scatterplot
```

### Plotting distances to median retention time

With our package, you can also check the quality of your chromatography system by comparing multiple technical repetitions of the experiment over time (i.e. different *runs*).

In order to do this, prepare your peptide report and run:
```{R}
library(LFQBench2)
library(data.table)

# Path to a file with data: to get the raw data from ISOQuant you have to download it directly from XAMP
path = path.expand('~/Projects/retentiontimealignment/Data/annotated_data.csv')
D = fread(path)

# We need to have following columns:
rt = D$rt # recorded retention times (but any other value will do, like drift times from IMS)
runs = D$run # which run was the retention time recorded at?
ids = D$id # which peptide was measured

S = get_smoothed_data(rt, runs, ids) # get the data for plotting
S[,run:=ordered(run)] # change run to ordered factor, for ggplot to be happy
plot_dist_to_reference(S)
```

which will result in
![](https://github.com/MatteoLacki/LFQBench2/blob/master/picts/dist2meds_2.jpg "Distances to Median Retention Times")

Admittedly, with 10 runs together we experience some overplotting.
This is easy to cope with, since the output of the `plot_dist_to_reference` function
returns a `ggplot` object,
```{R}
o + facet_wrap(~run) + geom_hline(yintercept=0, linetype='dotted')
```
![](https://github.com/MatteoLacki/LFQBench2/blob/master/picts/dist2meds3_2.jpg "Distances to Median Retention Times")

Note, that if you eliminate columns `bot` or `top` from `S`, the ribbons will not be plotted,
```{R}
S[, `:=`(top=NULL, bot=NULL)]
plot_dist_to_reference(Z)
```
resulting in
![](https://github.com/MatteoLacki/LFQBench2/blob/master/picts/dist2meds2_2.jpg "Distances to Median Retention Times")


### Command line usage:
* Find out where your package was installed with `find.package('LFQBench2')` in your R console
* add it to your PATH variable (this might work on Windows too, but it will be much more complicated).

Now you can simply use:
```{bash}
read_isospec_report -p <Pattern> <Path>
```

Run `read_isospec_report -h` for further help.

## Currently we support a rather restrictive list of software programmes:
* ISOQuant protein reports.
