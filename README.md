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

The outcome of `get_intensities` will might like that then:
```{R}
$I
     2019-068-03 SYE A 1:3 1 2019-068-03 SYE A 1:3 2 2019-068-03 SYE A 1:3 3 2019-068-06 SYE B 1:3 1 2019-068-06 SYE B 1:3 2 2019-068-06 SYE B 1:3 3
  1:             1047382.333             1064490.000             1128334.000             1105886.667             1093933.333             1084953.333
  2:              639159.667              671481.000              678078.667              668860.667              690640.667              671030.333
  3:             1679442.333             1762389.333             1737078.333             1881198.000             1851061.667             1898205.667
  4:              681142.333              679438.000              679724.000              677334.333              693968.333              666099.667
  5:               56764.333               52828.000               65068.333              126121.667              127239.000              136701.667
 ---                                                                                                                                                
278:                4702.500                5311.000                4066.500               13863.000               13288.000               13402.500
279:                4690.000                4768.000                4229.000                5138.000                5296.000                4388.000
280:                3960.000                4219.667                4002.333                2111.500                2258.500                1892.333
281:                4740.333                4664.667                5411.333                2692.667                2631.667                2757.500
282:               60659.500               61878.500               63753.000               67623.500               68640.500               56331.500

$design
                I_col_name condition tech_repl
1: 2019-068-03 SYE A 1:3 1         A         1
2: 2019-068-03 SYE A 1:3 2         A         2
3: 2019-068-03 SYE A 1:3 3         A         3
4: 2019-068-06 SYE B 1:3 1         B         1
5: 2019-068-06 SYE B 1:3 2         B         2
6: 2019-068-06 SYE B 1:3 3         B         3
```
It is easy to add the design information to the intensities (if you want that):
```{R}
library(data.table)
LI = melt(I$I, variable.name='I_col_name')
merge(LI, I$design, by='I_col_name')

> merge(LI, I$design, by='I_col_name')
                   I_col_name       value condition tech_repl
   1: 2019-068-03 SYE A 1:3 1 1047382.333         A         1
   2: 2019-068-03 SYE A 1:3 1  639159.667         A         1
   3: 2019-068-03 SYE A 1:3 1 1679442.333         A         1
   4: 2019-068-03 SYE A 1:3 1  681142.333         A         1
   5: 2019-068-03 SYE A 1:3 1   56764.333         A         1
  ---                                                        
1688: 2019-068-06 SYE B 1:3 3   13402.500         B         3
1689: 2019-068-06 SYE B 1:3 3    4388.000         B         3
1690: 2019-068-06 SYE B 1:3 3    1892.333         B         3
1691: 2019-068-06 SYE B 1:3 3    2757.500         B         3
1692: 2019-068-06 SYE B 1:3 3   56331.500         B         3
```
This can be used in other projects, where you might want to study intensities as depending upon the groups defined by the design of your experiment.

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

### Reading config files
It is now possible to read in configuration sets from the ISOQuant output.
This should be done to assure that you have been using the same parameters across different projects.
More generally, this allows for the monitoring of changes between the different files.
Here be examples:

```{R}
library(stringr)
library(LFQBench2)

# This script illustrates how to assure oneself that the same configuration
# files were used across your ISOQuant analysis, or to pinpoint the differences.

reports_paths = Sys.glob("data/kuner_2018_072/data/obelix/output/*.xlsx") # here any character vector will do
names(reports_paths) = str_match(reports_paths, ".* Kuner (.*) Obelix_user")[,2]
configs = lread(reports_paths, read_isoquant_config_from_report)
config_diff = diff_isoquant_configs(configs)
# if configs are the same, an empty data.table (data.frame) is returned.
# if there are differences, best to view them with the appropriated viewer:
View(config_diff)
```

Note that the comparison of configurations is done pairwise, for each pair of configurations.
Also, note that the opening and comparison of configuration files is separated, so that you
can always peep into the configs quickly.

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
