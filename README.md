# Welcome to LFQBench2
## an R package used to compare protein/peptide quantification results

### Installation
Install `devtools` with
```{r}
install.packages("devtools")
```
and then, install our software directly from github:
```{r}
devtools::install_github("MatteoLacki/LFQBench2")
```

### Reading reports
#### IsoQuant 
The package can be used in R scripts to open reports of the ISOquant package.
The user can choose among functions such as 
* `read_isoquant_protein_report`,
* `read_isoquant_peptide_report`, 
* and `read_isoquant_simple_protein_report`.

To read in a full protein report, use
```{r}
library(LFQBench2)

# Read in isoquant report in the long-format
DL = read_isoquant_protein_report(path = "path/to/report.xlsx"),
```
As outcome, you get a `data.table` in the wide format, which roughly corresponds 
to the original format of the report.

In the wide format, every row corresponds to exactly one protein and several columns contains informations on the measured intensities found in different runs submitted to IsoQuant (for it is a match-between-runs algorithm after all).
This is easy to visualize in Excel, but not so comfy, if you want to combine several projects or plot the outcomes with  `ggplot2`.

To cast the function between wide and long formats, use `wide2long` function.
To check, how it works, consider
```{R}
data(simple_protein_report)
colnames(simple_protein_report)
# c('A 1', 'A 2', 'A 3'. 'A 4', 'B 1', 'B 2', 'B 3', 'B 4')
W = wide2long(simple_protein_report,
  I_col_pattern = '(.) (.)',
  I_col_pattern_group_names = c('condition', 'technical_replicate'))
head(W)
#          entry I_col_name intensity condion technical_replicate
# 1: 1433B_HUMAN        A 1     54698       A                   1
# 2: 1433E_HUMAN        A 1    111761       A                   1
# 3: 1433F_HUMAN        A 1      6721       A                   1
# 4: 1433G_HUMAN        A 1     38671       A                   1
# 5: 1433S_HUMAN        A 1     10788       A                   1
# 6: 1433T_HUMAN        A 1     34178       A                   1
```
Therefore, by setting `I_col_pattern` you can easily detect columns reporting intensities and organize them into groups based on the column string using groups (to understand this concept, check out the cheetsheet for the `stringr` package).


### Comparing intensities of protein mixtures

With our package you can generate plots that show departures of the observed 
ratios of proteins/peptide intensities from the injected amounts.
![](https://github.com/MatteoLacki/LFQBench2/blob/master/picts/hye_2.jpg "Comparing Human-Yeast-Ecoli Proteomes")
This can be achieved with:
```{R}
library(LFQBench2)
path = 'path_to_your_ISOQuant_protein_report'
D = read_isoquant_protein_report(path,
  I_col_pattern="the pattern",
  I_col_pattern_group_names=c('the','names','of','the','groups'))
D_meds = preprocess_proteins_4_intensity_plots(D)
o = plot_proteome_mix(D_meds, organisms, bins=100)
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
