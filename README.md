# data-shave
Shave the top off of weird data files.

# This is a draft!
Developing some data shaving applications.

## Why did I make this
Weird data files with metadata or multi-header rows at the top. I run into this all the time.

# Usage
## Function
The function is `shave_csv(f, delim, min_rows, col_spec, row_sens, method)`.

All parameters except `f` have default values that I think are pretty good in most cases. That means you can just run `shave_csv(file_path)` and it will spit something (hopefully good) out.

## Parameters
`f` = The file path to your csv file

`delim` = *(character)* The file delimiter. Default: `","`

`min_rows` = *(numeric, 0-n)* The minimum number of rows to consider. This should be related to the estimated number of header rows (want to make sure you get past them). Default: `10`

`col_spec` = *(numeric, 0-1)* The specificity for classifying data rows based on the column types and number. Higher values will exclude false positives. Default: `0.9`

`row_sens` = *(numeric, 0-1)* The sensitivity for identifying data rows. It is the fraction of rows that must match the majority type to finish classification. Default: `0.5`

`method` = *(character, c("first","continuous"))* The approach for grabbing the head row. "first" assumes that the first row with correct dimensions is the header row. "continuous" assumes that the row just before the data row is the header row. Default: `"first"`

## Examples
Explain `example.R`, which runs through the example data files. Explain the weirdness of each example data file.

## Exceptions
Add stuff about exceptions to the defaults. E.g., one of the example files does better with col_spec=0.8 to allow for more flexibility in the column types.
