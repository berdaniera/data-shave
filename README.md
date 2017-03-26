# Data shave
A safety razor for your csv files.

> A: This thing came out the same time I was printing leaflets for the Shave the Data Foundation.

> B: You mean Save the Data.

> A: Oh is that what you did with them...

(modified from Beverly Hills Ninja)

### This is a draft!
The plan is to make some functions that make a good guess at which row is the header and which rows are the data (and shave the rest).

### Why did I make this?
Weird data files with metadata or multi-header rows at the top. I run into this pretty frequently and sometimes I can't (or don't want to) figure out which rows I should keep and which rows I should drop.

# Usage
### Function
The function is `shave_csv(f, delim, min_rows, col_spec, row_sens, method)`.

All parameters except `f` have default values that I think are pretty good in most cases. That means you can just run `shave_csv(file_path)` and it will spit something (hopefully good) out.

### Parameters
`f` = The file path to your csv file

`delim` = *(character)* The file delimiter. Default: `","`

`min_rows` = *(numeric, 0-n)* The minimum number of rows to consider. This should be related to the estimated number of header rows (want to make sure you get past them). Default: `10`

`col_spec` = *(numeric, 0-1)* The specificity for classifying data rows based on the column types and number. Higher values will exclude false positives. Default: `0.9`

`row_sens` = *(numeric, 0-1)* The sensitivity for identifying data rows. It is the fraction of rows that must match the majority type to finish classification. Default: `0.5`

`method` = *(character, c("first","continuous"))* The approach for grabbing the head row. "first" assumes that the first row with correct dimensions is the header row. "continuous" assumes that the row just before the data row is the header row. Default: `"first"`

### What does it do?
1. You put in a data file path.
2. The function starts scanning the file line by line and clustering rows.
3. Rows get added to a "type" bin based on similarity (set with `col_spec`).
4. After `min_rows`, the function looks for a majority row class (from `row_sens`) and calls that the "data" row format. If no threshold is met, keep reading lines.
5. Once the data row is identified, the first row with that type is called the first data row.
6. The header row is selected depending on the `method` parameter. By default, the function grabs the first row where `n_columns==n_columns_in_data_row`.

### Requirements
These functions require the `readr` and `tibbble` packages (or just `tidyverse`).

# Examples
### A bestiary of data files
The code in `example.R` runs through a handful of example data files that I've pulled together. Each one has some peculiarities:
- [`AHS_2013_C01AHM_with_ann.csv`](https://github.com/berdaniera/data-shave/blob/master/example-files/AHS_2013_C01AHM_with_ann.csv) - from the [US Census](https://www.census.gov/). Has two header rows (and lots of columns!)
- [`AMF_USWCr_2005_L2_WG_V0004.csv`](https://github.com/berdaniera/data-shave/blob/master/example-files/AMF_USWCr_2005_L2_WG_V004.csv) - from the [Ameriflux network](https://ameriflux.lbl.gov/). Has multiple metadata rows at the top and two header rows. Also, has rows with many different "formats" (i.e., lots of missing data which makes it hard to identify the first data row)
- [`NC_Eno_2016-08-25_HW.csv`](https://github.com/berdaniera/data-shave/blob/master/example-files/NC_Eno_2016-08-25_HW.csv) - from a [Hobo data logger](http://www.onsetcomp.com/) in a river in North Carolina. Has one metadata row, very few rows (to test the problem of `n_rows < min_rows`), and a first data row with a different format than the rest.
- [`NC_Eno_2016-11-22_HA.csv`](https://github.com/berdaniera/data-shave/blob/master/example-files/NC_Eno_2016-11-22_HA.csv) - from another Hobo data logger. Same as the previous one, but with more rows.
- [`NC_Eno_2016-11-28_CS.dat`](https://github.com/berdaniera/data-shave/blob/master/example-files/NC_Eno_2016-11-28_CS.dat) - from a [Campbell Scientific data logger](https://www.campbellsci.com/) in a river in North Carolina. Has a metadata row and multiple header rows.
- [`Sallyfork2-8.18.2016.csv`](https://github.com/berdaniera/data-shave/blob/master/example-files/Sallyfork2-8.18.2016.csv) - from a [Solinist data logger](https://www.solinst.com/) in a river in West Virginia. Has multiple metadata rows.
- [`US-Dk3_1980_2013.csv`](https://github.com/berdaniera/data-shave/blob/master/example-files/US-Dk3_1980_2013.csv) - from the Ameriflux network. Metadata and empty rows (a special case for readLines).
- [`US-WCr-Clean-2004-L0-vMar2013.csv`](https://github.com/berdaniera/data-shave/blob/master/example-files/US-WCr-Clean-2004-L0-vMar2013.csv) - from the Ameriflux network. Has metadata rows that are delimited to match the number of data columns. A challenge for classifying the start of the data rows.

### Exceptions
I think the defaults will work for many cases. There are some known situations where the function struggles.

- Rows with missing data may not be classified as a "data" row (based on the majority). In some of the example data files, having a strict column specificity gives false negatives and excludes initial rows with missing data. Relaxing the `col_spec` parameter a little bit (like, to 0.8) can make it work better.
- What else? Give me issues!

# Coming soon
- [ ] Better documentation
- [ ] More examples - send me files with a pull request!
- [ ] Python version

# Contact
Get in touch at aaron.berdanier at gmail.com
