library(readxl)
library(data.table)
library(matrixStats)
library(stringr)

path = '~/Projects/lab_analysis/data/obelix/output/2018-072 Kuner Cerebbellum Obelix_user designed 20190206-142325_quantification_report.xlsx'
# path = '~/Projects/lab_analysis/data/2018-072 Kuner_user designed 20190131-154908_quantification_report_eval_ML.xlsx'
long_df=T
I_col_pattern = 'Kuner '
sheet="TOP3 quantification"
I_col_pattern = "2018-072-0(.) Kuner (.)"
I_col_pattern_group_names = c('tech_rep', 'biol_rep')
I_col_pattern_group_names = NA

o = as.data.table(read_excel(path, sheet=sheet, skip=1))
o[o == ""] = NA
o[, path:=path][, grep("AVERAGE",colnames(o)):=NULL] # add path, remove AVEAGEs
if(long_df){
  I_cols = as.data.table(str_match(colnames(o), I_col_pattern))
  if(any(is.na(I_col_pattern_group_names))){
    # there were no group names, os some where NA
    I_col_pattern_group_names = paste("group", 1:(ncol(I_cols)-1), sep='_')
  }
  colnames(I_cols) = c('I_col_name', I_col_pattern_group_names)
  idx_intensity = str_which(colnames(o), I_col_pattern)
  I_cols = I_cols[idx_intensity,]
  o = melt(o,
           measure.vars=idx_intensity,
           na.rm=T,
           variable.factor=F,
           variable.name='I_col_name',
           value.name="intensity")[I_cols,
                                   on='I_col_name']
}#
# ## Peptides
# # path = '~/Projects/LFQBench2/data/peptides.csv'
# path = '~/Projects/LFQBench2/data/simple_proteins.csv'
# # path = '/home/matteo/Projects/LFQBench2/HYE/proteins.xlsx'
# # path = '~/Projects/LFQBench2/data/peptides.csv'
#
#
# # path = '~/Projects/LFQBench2/data/proteins.xlsx'
# path = path.expand(path)
# sheet="TOP3 quantification"
# intensity_pattern="[A|B][:space:][:digit:]"
# long_df=FALSE
#
# read_isoquant_simple_protein_report(path, T)
# fread(path)
#
#
#
#
# x = read_isoquant_protein_report(path, T)
# head(x)
#
#
# intensity_pattern = "intensity in"
# cond_rep_sep = " "
# prot_spec_sep = "_"
#
# DW[, id:=ifelse(is.na(modifier), sequence, paste(sequence, modifier, sep='_'))]
# cn = colnames(DW)
# cs = grepl(intensity_pattern, cn)
# DL = DW[,..cs]
# DL$id = DW$id
#
#
# prot_spec = str_split(DW[,entry], prot_spec_sep, simplify = T)[,1:2]
# DL$prot = prot_spec[,1]
#
# DL$specie = prot_spec[,2]
#
# DLL = melt(DL,
#            id.vars=c('id', 'prot', 'specie'),
#            variable.name='cond',
#            value.name='intensity',
#            na.rm=T)
#
# DLL[, cond := str_replace(cond, intensity_pattern,"")]
# conds = str_split(DLL$cond, cond_rep_sep, simplify=T)[,2:3]
# DLL$cond = conds[,1]
# DLL$run = as.integer(conds[,2])
#
#
#
# medians = DLL[, .(int_med=median(intensity), run_cnt=.N), .(cond, id, prot, specie)]
# medians = dcast(medians, id+prot+specie~cond,value.var = 'int_med')
# medians_good = medians[complete.cases(medians)][specie %in% c("HUMAN", "YEAS8", "ECOLI")]
#
# ggplot(medians_good, aes(x=HYE110_A, y=HYE110_B/HYE110_A))+
#   geom_hline(yintercept = 1, color='orange')+
#   geom_point(size=.1)+
#   scale_x_log10()+
#   scale_y_log10()+
#   cowplot::theme_cowplot()
#
# ggplot(medians_good, aes(x=HYE110_A, y=HYE110_B/HYE110_A)) +
#   geom_hline(yintercept = 1, color='orange')+
#   geom_density_2d(aes(color=specie))+
#   scale_x_log10()+
#   scale_y_log10()+
#   cowplot::theme_cowplot()
