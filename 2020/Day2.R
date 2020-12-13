library("stringr")
library("tidyr")

#day 1

Input <- read.table("C:\\Users\\Gail\\Source\\AdventOfCode\\2020\\Day2.txt", stringsAsFactors = FALSE, header = FALSE, col.names = c("Rule","Letter","Password"))
Input %>% mutate(Letter = str_replace(Letter,":", "")) %>% separate(Rule, into = c("Min","Max"), sep = "-") %>% mutate(ProcessedPassword = str_replace_all(Password,Letter,"")) %>% mutate(LengthDifference = nchar(Password) - nchar(ProcessedPassword)) %>% mutate(Valid = if_else(LengthDifference >= as.integer(Min) & LengthDifference <= as.integer(Max), 1, 0)) %>% filter(Valid == 1) %>% count()

#day 2

Input %>% mutate(Letter = str_replace(Letter,":", "")) %>% separate(Rule, into = c("First","Second"), sep = "-") %>% mutate(ValidChars = nchar(str_replace_all(str_c(str_sub(Password, start=First, end=First),str_sub(Password, start=Second, end=Second)),Letter, ""))) %>% filter(ValidChars==1) %>% count()
 