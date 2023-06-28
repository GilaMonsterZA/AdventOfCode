library(tidyverse)

Input <- '16,1,2,0,4,2,7,1,2,14'

StartingPositions <- as.integer(str_split_1(Input, ','))
max(StartingPositions)
min(StartingPositions)


PossiblePositions <- seq(from=min(StartingPositions), to=max(StartingPositions))
FuelCosts <- integer(length(PossiblePositions))

for (i in 1:17) {
  FuelCosts[i] = sum(abs(StartingPositions-PossiblePositions[i]))
}

PossiblePositions
FuelCosts

