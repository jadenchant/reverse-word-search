#!/usr/bin/Rscript --vanilla

# b - a - -     angle   blank
# s - - - -     leap    link
# t - - - -     sink    snack
# - * - - -     stop    tag
# - - - l s

# b l a n k     angle   blank
# s i n k c     leap    link
# t a g n a     sink    snack
# o * l i n     stop    tag
# p a e l s

# Creating letter DFs
starting_letters <- data.frame(letter = c("b","a","s","t","*","l","s"), 
                               row = c(1,1,2,3,4,5,5),
                               col = c(1,3,1,1,2,4,5))

answer_letters <- data.frame(letter = c("b", "l", "a", "n", "k",
                                       "s", "i", "n", "k", "c",
                                       "t", "a", "g", "n", "a",
                                       "o", "*", "l", "i", "n",
                                       "p", "a", "e", "l", "s"
                                       ),
                            row = rep(1:5, each = 5),
                            col = c(1:5))

# Creates matrix with letters
create_matrix <- function(lets,dim) {
  m <- data.frame(replicate(dim, replicate(dim, "-")))
  colnames(m)[1:dim] = 1:dim

  add_letter <- function(l, r, c){
    m[r,c] <<- l
  }

  apply(lets, 1, function(row) {
    add_letter(row["letter"], row["row"], row["col"])
  })

  m
}

print_matrix <- function(m,pos) {
  cat("\n\n\n\n\n\n\n")
  for (i in 1:nrow(m)) {
    for (j in 1:ncol(m)) {
      if(pos[1] == i && pos[2] == j) {
        cat("@", " ")
      } else {
        cat(m[i,j], " ")
      }
    }
    cat("\n")
  }
}

check_answer <- function(m, a) {
  for (i in 1:nrow(m)) {
    for (j in 1:ncol(m)) {
      if(m[i,j] != a[i,j]) {
        return(FALSE)
      } 
    }
  }
  return(TRUE)
}

handle_pos <- function(pos,key) {
  if(key %in% letters) {
    return(list(pos = pos, char = key))
  }

  switch(
    key,
    "up" = { pos[1] <- pos[1] - 1 },
    "down" = { pos[1] <- pos[1] + 1 },
    "left" = { pos[2] <- pos[2] - 1 },
    "right" = { pos[2] <- pos[2] + 1 }
  )

  return(list(pos = pos, char = ""))
}

matrix <- create_matrix(starting_letters, 5)

answer_matrix <- create_matrix(answer_letters, 5)
# answer_matrix

#install.packages("/home/users/chant1/PL/keypress_1.3.0.tar.gz", lib = "~/", repos = NULL)
library(keypress, lib.loc = "~/")

pos <- c(1,2)
key <- ""
print_matrix(matrix, pos)
check_result <- FALSE

while(key != "q") {
  key <- keypress()
  result <- handle_pos(pos, key)
  pos <- result$pos
  char <- result$char
  if(char != "") {
    matrix[pos[1],pos[2]] <- char
  }
  print_matrix(matrix, pos)

  if(check_result <-check_answer(matrix, answer_matrix)) {
    break
  }
  
}

if(check_result) {
  cat("You Win\n")
} else {
  cat("You Loose\n")
}
