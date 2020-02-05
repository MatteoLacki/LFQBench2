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
The package can be used to open excel and csv reports with quantification results.
To open a data in wide format, where intensities are reported in columns, use `read_wide_report`.
For example, in case of IsoQuant reports, simply write:
```{R}
library(LFQBench2)

R = read_wide_report(path_to_report, skip=1, sheet="TOP3 quantification")
```
Function 'read_wide_report' uses readxl::read_excel or data.table::fread underneath, and additional arguments to these function can be added directly to function call.

To extract intensity and design from the resulting `data.table` use `get_intensities`.
```{R}
library(LFQBench2)

I = get_intensities(R, I_col_pattern=".* SYE (:condition:.) 1:3 (:tech_repl:.)")
```
Underneath, we use `stringr` regular expressions, so the pattern can be pretty general and should differentiate the intensity columns from other columns.
Note, that we have modified these expressions to include group names.
Thus, `:condition:` in `(:condition:.)` will result in an additional column with the name `condition` in the output of `get_intensities` function.
You can give arbitrary names to groups and have as many groups you like.
However, naming one group as `condition` is necessary for the calculations of intensity ratios.

Now, we will need to know, which proteomes/peptidomes are there at which spiked in ratios:
```{R}
sampleComposition = data.frame(
  species = c("HUMAN","YEAS8", "ECOLI"),
  A       = c(  135,     03,      12  ),
  B       = c(  135,     09,      06  )
)
```

Then, it's all quite easy: we can then calculate median levels of intensities per protein/peptide with:
```{R}
MI = get_ratios_of_medians(I$I, I$design, species, sampleComposition)
```
and plot the outcomes with
```{R}
plots = plot_ratios(MI$I_cleanMeds, MI$sampleComposition)
plots$main
```

![](https://github.com/MatteoLacki/LFQBench2/blob/master/picts/hye.png "Comparing Human-Yeast-Ecoli Proteomes")
Alltogether, the code was as short as
```{R}
sampleComposition = data.frame(
  species = c("HUMAN","YEAS8", "ECOLI"),
  A       = c(  135,     03,      12  ),
  B       = c(  135,     09,      06  )
)
R = read_wide_report(path_to_report, skip=1, sheet="TOP3 quantification")
I = get_intensities(R, I_col_pattern=".* SYE (:condition:.) 1:3 (:tech_repl:.)")
species = get_species(species_col=R[['accession']],
                      species_pattern=".*_(.*)")
MI = get_ratios_of_medians(I$I, I$design, species, sampleComposition)
plots = plot_ratios(MI$I_cleanMeds, MI$sampleComposition)
plots$main
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
