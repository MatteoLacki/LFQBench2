#' Prepare project csv with data for ISOQuant.
#'
#' @param acquired_name Sample Sheet 'File name'.
#' @param sample_description Sample Sheet 'File Text'
#' @param folderNo E.g. "c('2019-050', '2019-050', '2019-050', ...)"
#' @return data.table needed for IsoQuant projects.
#' @importFrom data.table data.table
#' @export
isoquant_project_csv = function(acquired_name,
                                sample_description,
                                folderNo,
                                path_prefix='Y:\\RES',
                                windows_sep=T){
  if(windows_sep){
    sep = '\\'
  } else {
    sep = .Platform$file.sep
  }
  peptide3d_xml = paste0(path_prefix, sep, folderNo, sep, acquired_name, sep, acquired_name, '_Pep3D_Spectrum.xml', sep='')
  iaDBs_xml = paste0(path_prefix, sep, folderNo, sep, acquired_name, sep, acquired_name, '_IA_workflow.xml', sep='')
  data.table(acquired_name=acquired_name,
             peptide3d_xml=peptide3d_xml,
             iaDBs_xml=iaDBs_xml,
             sample_description=sample_description)
}
