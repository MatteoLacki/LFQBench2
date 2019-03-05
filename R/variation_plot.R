# D = fread("~/Projects/retentiontimealignment/Data/annotated_data.csv")
# ids = D$id
# runs = D$run
# x = D$rt

#' Get smoothed distances to reference and estimates of standard deviation.
#'
#' @param x Array of values to smooth.
#' @param runs Each entries indicate the run at which the corresponding entry of x was measured.
#' @param ids Classifies entries of x as being the measurement of the same entity, e.g. a peptide.
#' @param min_observed_cnt The minimal number of runs the measurements were recorded.
#' @param window_size An integer describing how many points are considered in the calculation of rolling medians and MADs.
#' @param mad_cnt Numeric value: how many MAD from the median should be calculated for the ribbons. Non positive values result in the absence of a ribbon.
#' @param spline.df Degrees of freedom for the spline extrapolating the rolling medians and rolling MADs.
#' @param grid.points.cnt Number of points in the grid extrapolating the rolling medians and rolling MADS.
#' @return A data.table with denoised and smoothed estimates of distances to the median reference run.
#' @export
get_smoothed_data = function(x, runs, ids,
                             min_observed_cnt = 2,
                             window_size = 11,
                             mad_cnt = 2,
                             spline.df = 30,
                             grid.points.cnt = 100){
  D = data.table(rt=x, run=runs, id=ids)
  D = D[, run_cnt:=length(rt), by=id][run_cnt>=min_observed_cnt]
  D = unique( D, by=c('id','run') )
  D[, run := paste0("run_", run) ]
  DW = dcast(D, id + run_cnt ~run, value.var = 'rt')
  DW_m = as.matrix(DW[,!1:2])
  # the reference run (to be plotted on the x axis)
  pep_medians = rowMedians(DW_m, na.rm=T)
  # distances to the reference run
  Ref_d = -sweep(DW_m, 1, pep_medians)
  Ref_d = as.data.table(Ref_d)
  Ref_d$med = pep_medians
  Ref_d$peptide = DW$id
  Ref_d = Ref_d[order(med)]
  Ref_d = melt(Ref_d, id.vars = c('peptide', 'med'),
                   variable.name = "run",
                   value.name = "rt_ref_d",
                   na.rm=T)
  Ref_d[, roll_med_rt := runmed(rt_ref_d, k=window_size, endrule='constant'), by=run]
  if(mad_cnt > 0) Ref_d[, roll_mad_rt := runmed(abs(rt_ref_d - roll_med_rt),
                                                k=window_size,
                                                endrule='constant'), by=run]
  ref.min = min(Ref_d$med)
  ref.max = max(Ref_d$med)
  ref.grid = seq(ref.min, ref.max, length.out=grid.points.cnt)
  S = function(x, y, df, grid) predict(smooth.spline(x, y, df=df), grid)
  SD = Ref_d[, S(med, roll_med_rt, spline.df, ref.grid), by=run]
  colnames(SD)[3] = 'mid'
  if(mad_cnt > 0){
    top = Ref_d[, S(med, roll_med_rt + mad_cnt * roll_mad_rt, spline.df, ref.grid), by=run]
    colnames(top)[3] = 'top'
    bot = Ref_d[, S(med, roll_med_rt - mad_cnt * roll_mad_rt, spline.df, ref.grid), by=run]
    colnames(bot)[3] = 'bot'
    SD = SD[top, on=c('run', 'x')
            ][bot, on=c('run', 'x')
              ][top<=mid, top:=mid
                ][bot>=mid, bot:=mid]
  }
  SD[,run:=as.integer(gsub("run_", "", SD$run))]
  return(SD)
}
