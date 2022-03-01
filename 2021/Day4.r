selections <- c(7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1)

temp <- c(
22,13,17,11,0,
8,2,23,4,24,
21,9,14,16,7,
6,10,3,18,5,
1,12,20,15,19,

3,15,0,2,22,
9,18,13,17,5,
19,8,7,25,23,
20,11,10,24,4,
14,21,16,12,6,

14,21,17,24,4,
10,16,15,9,19,
18,8,23,26,20,
22,11,13,6,5,
2,0,12,3,7)

boards <- array(temp, dim=c(5,5,3))

for (chosen in selections) {
  boards[boards==chosen] <- -1
  bingo <- 0
  
  # check if any column or row is bingo
  for (row in 1:5) {
    for (board in 1:length(boards[1,1,])) {
      if (sum(boards[row,,board]) == -5) {  # check == -5
        print (boards[,,board])
        boards[boards==-1] <- 0
        score <- sum(boards[,,board]) * chosen
        bingo <- 1
      }
    }
  }
  
  for (column in 1:5) {
    for (board in 1:length(boards[1,1,])) {
      if (sum(boards[,column,board]) == -5) { # check == -5
        print (boards[,,board])
        boards[boards==-1] <- 0
        score <- sum(boards[,,board]) * chosen
        bingo <- 1
      }
    }
  }
  if (bingo == 1)
    break;
}

print (score)

## ---- Part 2

completedBoards <- 0
totalBoards <- 100

for (chosen in selections) {
  boards[boards==chosen] <- -1
  bingo <- 0
  
  # check if any column or row is bingo
  for (board in 1:length(boards[1,1,])) {
    for (row in 1:5) {
      if (sum(boards[row,,board]) == -5 || sum(boards[,row,board]) == -5) {  
        #This board has won
        completedBoards <- completedBoards + 1
        if (completedBoards == totalBoards) {
          boards[boards==-1] <- 0  #remove the -1s before calculating the score
          score <- sum(boards[,,board]) * chosen
          break;
        }
        boards[,,board] <- -1000
      }
    }
  }
}

print (score)
