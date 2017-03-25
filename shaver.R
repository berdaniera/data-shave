# Functions to shave messy CSVs

# CONDITIONS:
# - The number of data rows must be greater than the number of header rows because column assessment is based on a vote
# - Requires tibble and readr

get_cols = function(x, delim=",") tryCatch(read.table(textConnection(x), sep=delim), error=function(e) NULL)
find_data_rows = function(f, delim=",", min_rows=10, col_spec=0.9, row_sens=0.5){
  cc = numeric() # the number of columns in each row
  rr = 1 # initial row
  classes = tibble::tibble(rc=numeric(), cc=numeric(), first=numeric(), ctyp=list())
  # 50% threshold for consensus on 'data row'
  # Keep adding while the number of rows is less than tolerance and the file is not done
  while(all(classes$rc/sum(classes$rc)<row_sens) || sum(classes$rc)<min_rows){
    ll = readr::read_lines(f, skip=rr-1, n_max=1) # the given line
    if(length(ll)==0) break # if end of file
    gcc = get_cols(ll, delim)[1,]
    cc = append(cc, length(gcc)) # add to number of cols per row
    newclass = as.character(unlist(lapply(gcc, class)))
    agreement = function(x) length(which(x==newclass))/max(length(x),length(newclass))>col_spec
    # alternative 100% agreement = function(x) all(x==newclass)
    matchclass = sapply(classes$ctyp, agreement) # match row class
    if(any(matchclass)){
      classes$rc[which(matchclass)] = classes$rc[which(matchclass)]+1
    }else{
      if(length(newclass)>1 && !(newclass[1]=="factor" && all(newclass[-1]=="logical"))){
        # catch edge case where first column is text and commas are automatically added to fill space
        classes = tibble::add_row(classes, rc=1, cc=length(newclass), first=rr, ctyp=list(newclass))
      }
    }
    rr = rr+1 # iterate row
  }
  return(list(cc=cc, dd=classes[which.max(classes$rc/sum(classes$rc)),])) # most common row type
}
shave_csv = function(f, delim=",", min_rows=10, col_spec=0.9, row_sens=0.5, method="first"){
  # min_rows = (0-n) the minimum number of rows to consider, should be related to the estimated number of header rows
  # col_spec = (0-1) specificity for classifying data rows based on column types, higher values will exclude false positives
  # row_sens = (0-1) sensitivity for identifying data rows, what fraction of rows must be in the data type to finish
  # method = approach for grabbing the head row,
  # "first": Assume first row with correct dimensions is header row
  # "continuous": Assume row before first data row is header row
  dr = find_data_rows(f, delim, min_rows, col_spec, row_sens)
  srow = dr$dd$first-1 # number of row to skip
  ww = which(dr$cc==dr$dd$cc) # which rows in sample match length of data row
  if(method=="first"){
    # also, check if header row classes match data row classes
    if(dr$dd$first == ww[1]){ hrow = ww[2] }else{ hrow = ww[1] }
  }else if(method=="continuous"){
    if(dr$dd$first == ww[1]) srow = srow + 1
    hrow = srow
  }else{
    stop('Please specify a method in c("first","continuous")')
  }
  cnames = as.character(unlist(get_cols(readr::read_lines(f, n_max=1, skip=hrow-1))))
  x = readr::read_csv(f, skip=srow, col_names=cnames, col_types=readr::cols())
  return(x)
}
