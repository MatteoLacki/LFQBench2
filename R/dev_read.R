library(data.table)
library(matrixStats)
library(stringr)

## Peptides

path = '/home/matteo/Projects/LFQBench2/HYE/peptides.csv'
# path = '/home/matteo/Projects/LFQBench2/HYE/proteins.xlsx'
DW = fread(path)
DW[DW == ""] = NA

intensity_pattern = "intensity in"
cond_rep_sep = " "
prot_spec_sep = "_"
DW[, id:=ifelse(is.na(modifier), sequence, paste(sequence, modifier, sep='_'))]

cn = colnames(DW)
cs = grepl(intensity_pattern, cn)
DL = DW[,..cs]
DL$id = DW$id

prot_spec = str_split(DW[,entry], prot_spec_sep, simplify = T)[,1:2]
DL$prot = prot_spec[,1]
DL$specie = prot_spec[,2]

DLL = melt(DL,
           id.vars = c('id', 'prot', 'specie'),
           variable.name = 'cond',
           value.name='intensity',
           na.rm=T)

DLL[, cond := str_replace(cond, intensity_pattern,"")]
conds = str_split(DLL$cond, cond_rep_separator, simplify=T)[,2:3]
DLL$cond = conds[,1]
DLL$run = as.integer(conds[,2])
medians = DLL[, .(int_med=median(intensity), run_cnt=.N), .(cond, id, prot, specie)]
medians = dcast(medians, id+prot+specie~cond,value.var = 'int_med')
medians_good = medians[complete.cases(medians)]

ggplot(medians_good, aes(x=A, y=B/A))+
  geom_hline(yintercept = 1, color='orange')+
  geom_point(size=.1)+
  scale_x_log10()+
  scale_y_log10()+
  cowplot::theme_cowplot()


ggplot(medians_good, aes(x=A, y=B/A))+
  geom_hline(yintercept = 1, color='orange')+
  geom_density_2d(aes(color=specie))+
  scale_x_log10()+
  scale_y_log10()+
  cowplot::theme_cowplot()
