source("shaver.R")
dd = "example-files/"
ff = list.files(dd)
for(f in ff){
  fi = paste0(dd, f)
  x = strip_csv(fi)
  print(x)
}
