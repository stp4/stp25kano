#' @rdname Kano
#' @examples
#'
#' require(stp25stat2)
#' require(stp25tools)
#' kano_labels <- c( "like",
#'                   "must be",
#'                   "neutral",
#'                   "live with",
#'                   "dislike")
#'
#' DF<-stp25tools::get_data(
#'   "sex Edu f1 d1 f2 d2 f3 d3 f4 d4 f5  d5  f6  d6  f7  d7  f8  d8  f9  d9  f10 d10
#'   w  med 1  1  1  2  1  3  1  5  1   5   5   1   3   3   5   2   5   1   5   2
#'   w  med 1  2  2  5  2  3  1  5  1   5   2   5   3   3   2   5   2   5   5   2
#'   m  med 1  3  3  5  1  5  3  4  1   5   5   1   3   3   5   2   5   1   5   2
#'   m  med 1  4  4  2  1  5  4  4  1   5   5   1   3   3   5   2   5   1   5   2
#'   w  med 1  5  5  5  5  3  1  5  1   5   5   1   3   3   5   2   5   1   5   2
#'   w  med NA NA NA NA NA NA NA NA NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#'   m  med 2  1  1  5  2  5  1  5  1   5   2   5   3   3   1   5   2   5   5   2
#'   w  med 2  2  2  5  1  3  1  5  1   5   3   3   3   3   1   4   1   3   5   2
#'   m  med 2  3  2  5  2  3  1  3  1   5   1   3   3   3   2   4   3   3   5   2
#'   m  med 2  4  1  5  1  5  1  5  1   5   1   4   3   3   2   5   1   3   5   2
#'   w  med 2  5  2  5  1  4  1  5  1   5   1   4   3   3   2   5   1   4   5   2
#'   m  med NA NA NA NA NA NA NA NA NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#'   w  med 3  1  2  5  3  3  1  5  2   5   1   5   3   3   3   3   3   3   5   2
#'   m  med 3  2  1  5  1  5  2  5  2  NA   1   5   3   3   2   5   1   5   5   2
#'   w  med 3  3  2  5  1  3  1  5  1   5   1   3   3   3   2   5   1   3   5   2
#'   w  low 3  4  2  5  2  5  2  5  1   5   1   4   3   3   2   5   1   3   5   2
#'   w  low 3  5  2  5  1  5  1  5  2   5   1   4   3   3   2   5   1   4   5   2
#'   w  low NA NA NA NA NA NA NA NA NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#'   m  low 4  1  2  5  1  5  2  5  2   5   1   4   2   3   2   5   1   3   5   2
#'   w  low 4  2  2  5  2  5  2  5  2   5   1   3   3   3   2   5   1   3   5   2
#'   w  low 4  3  2  5  1  5  2  5  2   5   1   5   1   3   2   5   1   3   5   2
#'   m  low 4  4  2  5  1  5  2  5  2   5   1   3   3   3   1   3   1   3   5   2
#'   w  low 4  5  2  5  3  3  2  5  2   5   1   4   1   3   2   5   1   4   5   2
#'   w  low NA NA NA NA NA NA NA NA NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#'   m  hig 5  1  1  5  1  5  2  4  1   5   1   3   3   5   2   4   1   3   5   2
#'   w  hig 5  2  1  5  1  3  1  5  1   5   1   3   1   5   1   5   3   3   5   2
#'   w  hig 5  3  2  5  3  3  1  4  2   4   1   3   3   5   3   3   5   1   5   2
#'   w  hig 5  4  2  5  1  4  2  5  1   5   1   3   3   5   2   5   4   1   5   2
#'   w  hig 5  5  2  5  2  4  2  4  2   5   1   4   1   5   1   5   1   4   5   2
#'   m  hig NA NA 2  5  1  5  1  3  1   4   1   3   1   5   1   3   1   3   5   2
#'   m  hig NA NA 2  1  1  5  1  4  3   3   5   2   3   5  NA  NA   1   3   5   2")
#'
#'
#'
#' DF <- Label(
#'   DF,
#'   labels = c(
#'     f1 = "Fahreigenschaften",
#'     f2 = "Sicherheit",
#'     f3 = "Beschleunigung",
#'     f4 = "Verbrauch",
#'     f5 = "Lebensdauer",
#'     f6 = "Sonderausstattung",
#'     f7 = "Schiebedach",
#'     f8 = "Rostschutz",
#'     f9 = "Design",
#'     f10 = "Rostflecken"
#'   )
#' )
#'
#'
#' kano_res1 <- Kano(~ ., DF[-c(1, 2)])
#' ## Test ob auch Zahlen funktionieren
#' # DF[-c(1,2)] <- stp25tools::dapply2(DF[-c(1,2)],
#' #                                        function(x) factor( x, 1:5, kano_labels))
#' # kano_res2 <- Kano( ~ . , DF[-c(1,2)])
#' # kano_res1$scors
#' # kano_res2$scors
#'
#' kano_plot(kano_res1)
#' # library(lattice)
#' # x <- data.frame (xtabs( ~ value + variable, kano_res1$molten))
#' # barchart(Freq ~ value | variable, x, origin = 0)
#' kano_barchart(kano_res1)
#'
#' Tbll_kano(kano_res1)
#'
#' kano_res3 <- Kano( .~ sex, DF[-2])
#'
#' Tbll_kano(kano_res3,  include.percent=FALSE)
#' # kano_plot(kano_res3,
#' #           legend.position = list(x = .75, y = 1),
#' #           #legend.title= "HAllo",
#' #           cex.legend=1)
#'
#' # kano_res4 <- Kano( .~ sex + Edu, DF )
#'
#' # # Kontrolle der Logik
#' # kano_res1 <-  Kano( ~ . , DF[-c(1,2)], na.action = na.pass)
#' # dat<- na.omit(cbind(DF[c("f1", "d1")], kano_res1$data[2]))
#' # dat
#'
print.Kano <- function(x,
                       ...) {
  cat("\n", names(x), "\n", x$note, "\n\n")
  print(x$formula)
  print(head(x$molten))
}

