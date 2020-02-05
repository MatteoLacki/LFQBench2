#' Get intensiities from data that has them in columns (wide format).
#'
#' @param D data.table with intensities and species to extract
#' @param I_col_pattern Pattern to match intensity columns.
#' @return list with intensities and description of the experimental design
#' @importFrom data.table as.data.table rbindlist
#' @importFrom stringr str_match str_match_all
#' @export
get_intensities = function(D, I_col_pattern){
  D = as.data.table(D)
  p_pat = parse_pattern(I_col_pattern)
  I_cols = str_match_all(colnames(D), p_pat$pattern)
  where_pattern = sapply(I_cols, length) > 0
  idx_intensity = colnames(D)[where_pattern]
  if(!any(where_pattern)) stop("Pattern not found among column names.")
  I_cols = rbindlist(lapply(I_cols[where_pattern], as.data.frame))
  colnames(I_cols) = c("I_col_name", p_pat$names)
  I = D[,idx_intensity,with=F]
  return(list(I=I, design=I_cols))
}


#' Get species tags from a species column.
#'
#' @param species_col Vector with species to extract.
#' @param species_pattern Pattern to distinguish species in species column.
#' @return character vector with species
#' @importFrom stringr str_match
#' @export
get_species = function(species_col, species_pattern=".*_(.*)"){
  return(str_match(species_col, species_pattern)[,2])
}


#' Get species tags from a species column.
#'
#' @param I data.table with intensities in wide format.
#' @param design experimental design for columns in I.
#' @param sampleComposition composition of spiked in samples
#' @return list with median intensities, the same filter for species in sampleComposition, and sampleCopmposition with ratios.
#' @importFrom data.table as.data.table
#' @importFrom matrixStats rowMedians
#' @export
get_ratios_of_medians = function(I, design, species, sampleComposition){
  sampleComposition$ratios = sampleComposition[[2]]/sampleComposition[[3]]
  I = as.matrix(I)
  condition_cols = lapply(split(design, design$condition), '[[', 'I_col_name')
  condition_no = length(condition_cols)
  if(condition_no!=2) stop("Number of conditions ain't two: code this case yourself please :)")
  meds = as.data.table(sapply(condition_cols, function(cond) rowMedians(I[,cond], na.rm=T)))
  meds$species = species
  sampleCompositionConditionNames = sort(names(condition_cols))
  dataConditionNames = sort(colnames(sampleComposition)[2:3])
  condition_names_match = all(sampleCompositionConditionNames==dataConditionNames)
  if(!condition_names_match) stop(paste0("Condition columns in 'sampleComposition' (",
                                         paste(sampleCompositionConditionNames, collapse=', '),
                                         ") do not match those in the data (",
                                         paste(dataConditionNames, collapse=', '),")."))

  meds$I_ratio = meds[[dataConditionNames[1]]] / meds[[dataConditionNames[2]]]
  if(!all(sampleComposition$species %in% unique(meds$species))) stop('Species not found among the peptides: ')
  clean_meds = meds[species %in% sampleComposition$species]
  return(list(I_meds=meds,
              I_cleanMeds=clean_meds,
              sampleComposition=sampleComposition))
}
