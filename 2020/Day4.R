library("dplyr")
library("stringr")
library("tidyr")


Input <- read.delim("C:/Users/Gail/Source/AdventOfCode/2020/Day4Input.txt", header=FALSE)
Required <- c("byr","iyr","eyr","hgt","hcl","ecl","pid")

Passports <- Input %>% mutate(Matches = 0) %>% mutate(HasCID = 0)

HasCID <- grep("cid", Input[,1])
Passports[HasCID,3] <- 1

for (i in c(1:length(Required))) {
  
  Valid <- grep(Required[i], Input[,1])
  Passports[Valid,2] <- Passports[Valid,2] + 1
  
}

Passports %>% filter(Matches >= 7) %>% count()

#end part 1


Passports <- Passports %>% filter(Matches >= 7) %>% separate(V1, into = c("c1","c2","c3","c4","c5","c6","c7","c8"), sep = " ", fill = "right")

Validation <- data.frame(BirthYear=integer(), IssueYear=integer(), ExpirationYear=integer(), 
                         Height=character(), Hair=character(), Eye=character(), PassportID=character(), Valid = logical())

for (i in c(1:length(Passports[,1]))) {
  
  c1=as.integer(str_replace(Passports[i,apply(Passports[i,], 2, function(x) any(grepl(Required[1], x)))],str_c(Required[1],":"),""))
  c2=as.integer(str_replace(Passports[i,apply(Passports[i,], 2, function(x) any(grepl(Required[2], x)))],str_c(Required[2],":"),""))
  c3=as.integer(str_replace(Passports[i,apply(Passports[i,], 2, function(x) any(grepl(Required[3], x)))],str_c(Required[3],":"),""))
  c4=str_replace(Passports[i,apply(Passports[i,], 2, function(x) any(grepl(Required[4], x)))],str_c(Required[4],":"),"")
  c5=str_replace(Passports[i,apply(Passports[i,], 2, function(x) any(grepl(Required[5], x)))],str_c(Required[5],":"),"")
  c6=str_replace(Passports[i,apply(Passports[i,], 2, function(x) any(grepl(Required[6], x)))],str_c(Required[6],":"),"")
  c7=str_replace(Passports[i,apply(Passports[i,], 2, function(x) any(grepl(Required[7], x)))],str_c(Required[7],":"),"")

  Validation<-rbind(Validation, setNames(data.frame(c(c1), c(c2), c(c3), c(c4), c(c5), c(c6), c(c7), c(TRUE)),names(Validation)))
  
}
  
#
#byr (Birth Year) - four digits; at least 1920 and at most 2002.
#iyr (Issue Year) - four digits; at least 2010 and at most 2020.
#eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
#hgt (Height) - a number followed by either cm or in:
#  If cm, the number must be at least 150 and at most 193.
#  If in, the number must be at least 59 and at most 76.
#hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
#ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
#pid (Passport ID) - a nine-digit number, including leading zeroes.
#cid (Country ID) - ignored, missing or not.

Validation <- Validation %>% mutate(Valid = if_else(condition = BirthYear<1920 | BirthYear>2002, true = FALSE, false = Valid))
Validation <- Validation %>% mutate(Valid = if_else(condition = IssueYear<2010 | IssueYear>2020, true = FALSE, false = Valid))
Validation <- Validation %>% mutate(Valid = if_else(condition = ExpirationYear<2020 | ExpirationYear>2030, true = FALSE, false = Valid))
Validation <- Validation %>% mutate(Valid = if_else(condition = str_detect(Height,"cm",negate=TRUE) & str_detect(Height,"in",negate=TRUE), true = FALSE, false = Valid))
Validation <- Validation %>% mutate(Valid = if_else(condition = str_detect(Height,"cm",negate=TRUE) & str_detect(Height,"in",negate=TRUE), true = FALSE, false = Valid))



