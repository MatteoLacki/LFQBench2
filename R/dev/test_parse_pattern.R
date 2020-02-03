library(stringr)
library(data.table)

parse_pattern = function(s){
  names = str_extract_all(s, "\\([^\\)]*\\)")[[1]]
  if(length(names) == 0) stop(paste0("Your 'PPPATTERN' has no groups [i.e. (.), or (name)]: '", s,"'"))
  names = str_sub(names, 2L, -2L)# no brackets
  names[names == "."] = paste("group", 1:sum(names=="."), sep='_')
  s_out = str_replace_all(s, "\\([^\\)]*\\)", "\\([^\\)]*\\)")
  return(list(pattern=s_out, names=names))
}


s = "(:year:.*)-(.*).* SYE (:condition:.) 1:3 (:replicates:.)"
parse_pattern2 = function(s){
  names = str_extract_all(s, "\\([^\\)]*\\)")[[1]]
  if(length(names) == 0) stop(paste0("Your 'PPPATTERN' has no groups [i.e. (.), or (name)]: '", s,"'"))
  names = str_extract(names, "\\(\\:[^:]+:")
  names = str_sub(names, 3L, -2L)# no brackets
  names[is.na(names)] = paste("group", 1:sum(is.na(names)), sep='_')
  s_out = str_replace_all(s, "\\(\\:[^:]+:", "(")
  return(list(pattern=s_out, names=names))
}

str_replace_all(s, "\\([^:]*:", "(")
parse_pattern2(s)


parse_pattern("(.*)-(.*).* SYE (.*) 1:3 (.*)")
parse_pattern(".* SYE (asdvasd) 1:3 (baasdasd)")
parse_pattern(".* SYE (.) 1:3 (.)")
parse_pattern(".* SYE (.) 1:3 (.) (asdab) (.)")
parse_pattern(".* SYE ")
I_col_pattern = "intensity in 2019-068-03 SYE (group) 1:3 (tech_repl)"



