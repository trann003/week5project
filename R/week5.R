# R Studio API Code
library(rstudioapi)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Data import
library(tidyverse)
Adata_tbl <- read_delim("../data/Aparticipants.dat", delim = "-", col_names = c("casenum", "parnum", "stimver", "datadate", "qs"))
Anotes_tbl <- read_csv("../data/Anotes.csv", quote = ",", col_names = T)
Bdata_tbl <- read_delim("../data/Bparticipants.dat", delim = "\t", col_names = c("casenum", "parnum", "stimver", "datadate", "q1", "q2", "q3", "q4", "q5", "q6", "q7", "q8", "q9", "q10"))
Bnotes_tbl <- read_delim("../data/Bnotes.txt", delim = "\t", col_names = T)

# Data cleaning
Adata_tbl <- Adata_tbl %>% 
  separate(qs, c("q1", "q2", "q3", "q4", "q5"), sep = " - ") %>%
  mutate(datadate = lubridate::mdy_hms(datadate)) %>%
  mutate_at(vars(starts_with("q")), as.numeric)

Aaggr_tbl <- Adata_tbl %>% mutate(mean_q = rowMeans(select(.,starts_with("q")), na.rm = T)) %>%
   select(parnum, stimver, mean_q) %>%
   spread(., stimver, mean_q) 
Baggr_tbl <- Bdata_tbl %>% mutate(mean_q = rowMeans(select(.,starts_with("q")), na.rm = T)) %>%
  select(parnum, stimver, mean_q) %>%
  spread(., stimver, mean_q)
Aaggr_tbl <- Aaggr_tbl %>% left_join(Anotes_tbl, by = "parnum")
Baggr_tbl <- Baggr_tbl %>% left_join(Bnotes_tbl, by = "parnum")    
bind_rows(Aaggr_tbl, Baggr_tbl, .id = "datasource") %>% filter(is.na(notes)) %>% count(datasource, sort = T)

