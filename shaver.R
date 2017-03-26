# Functions to shave messy CSVs

# CONDITIONS:
# - The number of data rows must be greater than the number of header rows because column assessment is based on a vote
# - Requires tibble and readr

get_cols = function(x, delim=",") tryCatch(read.table(textConnection(x), sep=delim), error=function(e) NULL)
find_data_rows = function(f, delim=",", min_rows=10, col_spec=0.9, row_sens=0.5){
  cc = numeric() # the number of columns in each row
  rr = 1 # initial row
  # rc is the row count, cc is the column count, first is the first row with that class, ctyp is a list of column types
  classes = tibble::tibble(rc=numeric(), cc=numeric(), first=numeric(), ctyp=list())
  # Finding consensus on 'data row'
  # Keep adding while the number of data rows is less than the sensitivity (or less than minimum rows) and the file is not done
  while(all(classes$rc/sum(classes$rc)<row_sens) || sum(classes$rc)<min_rows){
    ll = readr::read_lines(f, skip=rr-1, n_max=1) # the given line
    if(length(ll)==0) break # if end of file
    gcc = get_cols(ll, delim)[1,]
    cc = append(cc, length(gcc)) # add to number of cols per row
    # the classes in the new row
    newclass = as.character(unlist(lapply(gcc, class)))
    # check for agreement with other row types
    agreement = function(x) length(which(x==newclass))/max(length(x),length(newclass))>col_spec
    # alternative 100% agreement = function(x) all(x==newclass)
    matchclass = sapply(classes$ctyp, agreement) # match row class
    if(any(matchclass)){ # increment that row type
      classes$rc[which(matchclass)] = classes$rc[which(matchclass)]+1
    }else{ # add a new row type
      # (as long as it is not a row with a single text column and blank commas to fill column space)
      if(length(newclass)>1 && !(newclass[1]=="factor" && all(newclass[-1]=="logical"))){
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
  # Find the data rows
  dr = find_data_rows(f, delim, min_rows, col_spec, row_sens)
  srow = dr$dd$first-1 # number of rows to skip
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
  # column names from the header row
  cnames = as.character(unlist(get_cols(readr::read_lines(f, n_max=1, skip=hrow-1))))
  # read in the data file
  x = readr::read_csv(f, skip=srow, col_names=cnames, col_types=readr::cols())
  return(x)
}
