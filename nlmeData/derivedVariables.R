# load partial columns from PPMI data and examine aggregate measures as indicated by the variable derivation documentation. 
setwd("~/documents/data/PPMI/nonmotorassess")
# invoke SQL functionality for CSV reading. This will allow us to select subsets of full .csv files
install.packages('sqldf') 

library(sqldf)


#Benton_Judgment_of_Line_Orientation.csv

testBJLO = read.table("Benton_Judgment_of_Line_Orientation.csv", na.rm=T)