#' Analyze Kano Type Items.
#'
#' Die Funktion \code{Kano()} transformiert Kano-Fragebogen zur Kano-Kodierung
#'
#' http://www.eric-klopp.de/texte/angewandte-psychologie/18-die-kano-methode
#' https://de.wikipedia.org/wiki/Kano-Modell
#'
#'  \subsection{M Basis-Faktoren (Mussfaktoren)}{
#'  Basis-Merkmale (\strong{M}ustbe) werden vom Kunden Vorausgesetzt schaffen
#'  Unzufriedenheit wenn sie nicht vorhanden sind.
#'  }
#'   \subsection{O Leistungs- Faktoren}{
#'  Leistungs-Merkmale (\strong{O}ne-dimensional) werden vom Kunden verlangt
#'  }
#'  \subsection{A Begeisterung-Faktoren}{
#'  Begeisterungs-Merkmale (\strong{A}ttractive) Kunde rechnet nicht damit hebt das
#'  Produkt vom Konkurrenten  ab.
#'  }
#'  \subsection{I Unerhebliche- Faktoren }{
#'  Unerhebliche-Merkmale (\strong{I}ndifferent) werden vom Kunden ignoriert.
#'  }
#'  \subsection{R Rueckweisende- Faktoren }{
#'  Ablehnende-Merkmale (\strong{R}) werden vom Kunden abgelehnt. Fuehren bei Vorhandensein zu Unzufriedenheit, bei Fehlen jedoch nicht zu Zufriedenheit.
#'  }
#'
#'
#'
#'  \tabular{lrrrrr}{
#'  \strong{Func/Dyfunc} \tab like (1) \tab must-be (2) \tab neutral (3) \tab live with (4)  \tab dislike (5) \cr
#'    like (1) \tab O \tab A \tab A \tab A \tab O \cr
#'    must-be (2) \tab R \tab I \tab I \tab I \tab M \cr
#'    neutral (3) \tab R \tab I \tab I \tab I \tab M \cr
#'    live with (4) \tab R \tab I \tab I \tab I \tab M \cr
#'    dislike (5) \tab R \tab R \tab R \tab R \tab Q
#'
#'      }
#'
#'
#' \strong{Kodierung}
#'
#' Das würde mich sehr freuen (1)
#' Das setze ich voraus (2)
#' Das ist mir egal (3)
#' Das könnte ich in Kauf nehmen (4)
#' Das würde mich sehr stören (5)
#'
#'
#'
#'
#' M O A I R Q Heufigkeit
#'
#' max Category
#'
#' M>O>A>I  max Category mit Hierarchie  M Wichtiger als O usw.
#' also wen der Unterschied zwischen den zwei am hoechsten gelisteten Attributen
#' zwei Kategorien gleich ist,  5% Schwelle, dann gilt die Regel M>O>A>I
#'
#' Total Strength als zweite Masszahl gibt an wie hoch der Anteil an bedeutenden
#' Produktmerkmalen ist.
#'
#' Category Strength ist eine Masszahl die die angibt ob eine Anforderung nur in
#' eine Kategorie gehoert
#'
#' CS plus	Index Positiv  CS.plus=  (A+O)/(A+O+M+I)
#'
#' CS minus	Index Negativ CS.minus= (O+M)/(A+O+M+I)
#'
#' Chi-Test	ist eigentlich Unsinn, Testet ob die Verteilung von M, A, O und I gleich ist.
#' Wird aber in wissenschaftlichen Arebitengerne angegeben.
#'
#' Fong-Test Vergleich der zwei Haeufigsten-Kategorien gegenueber der Gesamtzahl
#' Ergebnis ist entweder ein signifikante oder ein nicht signifikante Verteilung.
#' Ich verwende zur Berechnung die Kategorien A,O,M,I und R. Q verwende ich nur für die Gesamtsumme
#'
#'
#' @param type type Fragetype entweder  vollstaendig (5) oder gekuerzt (3)
#' @param umcodieren umcodieren logical False
#' @param rm_Q Remove Q Kategorien Q entfernen  Anzahl an erlaubten Qs
#' @param rm_I Remove I Kategorien I entfernen  Anzahl an erlaubten Is
#' @param methode wie sind die Items geordnet default = 1  (func dfunk func dfunc func)
#' @param ...   x, data, by, subset, na.action
#' @param vars_func,vars_dysfunc weche Variablen sind die zwei Dimensionen
#' @name Kano
#'
#' @return
#'  Liste mit:
#' data: data mit der Kano-Kodierung.
#' molten: Daten-Lang
#' scors:  Scors sind eine Alternative Codierung zum Zweck der Transformierung zu einer metrischen Skala.
#' formula, removed=Errorrs, N, attributes, answers
#' @export
Kano <-function( ...,
                type = 5,
                umcodieren = FALSE,
                rm_Q = 10000,
                rm_I = 10000,
                methode = 1,
                vars_func = NULL,
                vars_dysfunc = NULL

){

  X <- stp25tools::prepare_data2(...)
  grouping_data <- if (is.null(X$group.vars)) NULL else X$data[X$group.vars]
  measuer_data <- X$data[X$measure.vars]

  n <- ncol(measuer_data)
  note <- ""
  kano_levels <-  c("M", "O", "A", "I", "R", "Q")
  attributes <- c(
    "Must-be",
    "One-dimensional",
    "Attractive",
    "Indifferent",
    "Reverse",
    "Questionable"
  )
  answers <- c(
    "I like it that way",
    "It must be that way",
    "I am neutral",
    "I can live with it that way",
    "I dislike it that whay"
  )

  if(n %% 2 != 0) return("Die Anzahl dan Funktionalen und Dysfunktionalen Items ist ungleich!")

  
 # print(summary(measuer_data[1:4]))
  if (!is.null(vars_func) &
      !is.null(vars_dysfunc)) {
    measuer_data <- measuer_data[c(rbind(vars_func, vars_dysfunc))]
  } else{
    if (methode == 2) {
      measuer_data <- measuer_data[c(rbind(1:(n / 2), (n / 2 + 1):n))]
    }
  }

 # print(summary(measuer_data[1:4]))
  
  ANS <- NULL
  vars <- seq(1, n, by = 2)
  vars_func <- seq(1, n , by = 2)
  vars_dysfunc <- seq(2, n , by = 2)


  nams <- stp25tools::get_label(measuer_data[vars])

  if (is.factor(measuer_data[[1]])) {
    message("in is.factor(measuer_data)")
    note <- paste(note,
                  "Transform to numeric, ",
                  paste(levels(measuer_data[[1]]), collapse = ", "))
    measuer_data <- stp25tools:::dapply1(measuer_data, as.numeric)
  }
 # print(summary(measuer_data[1:4]))
control_levels <- sapply(measuer_data,
                         function(x) {
                           min(x, na.rm=TRUE) <1 | max(x, na.rm=TRUE)>type
                           }
                         )

  if(any(control_levels)){
    cat("\ncontrol_levels\n")
    print(lapply(measuer_data, function(x) range(x, na.rm=TRUE)) )
    stop("Zu viele Levels! Nur 5 oder 3 sind bei Kano erlaubt.")
  }

  Scors <- measuer_data
  Scors[vars_func] <- sapply(Scors[vars_func], function(a)
                                 as.numeric(as.character(factor(
                                   a, 1:5, c(1, .5, 0, -.25, -.5)))))
  Scors[vars_dysfunc] <- sapply(Scors[vars_dysfunc], function(a)
                                    as.numeric(as.character(factor(
                                      a, 1:5, c(-.5, -.25, 0, .5, 1)))))
  Scors <- as.data.frame(Scors)
  names(Scors) <- paste0(names(Scors), ".s")

note<- paste( note, "\ntransform kano (type=",type, ")" )

  for (i in vars){

    X_func <- measuer_data[i]
    X_dysf <- measuer_data[(i+1)]
     if (umcodieren) X_dysf <-  type + 1 - X_dysf
    if(type==3){ #-- Kurzversion
      myrow  <-  ifelse( X_func==1 & X_dysf==1, "A"
                ,ifelse( X_func==1 & X_dysf==2, "A"
                ,ifelse( X_func==1 & X_dysf==3, "O"
                ,ifelse( X_func==2 & X_dysf==1, "I"
                ,ifelse( X_func==2 & X_dysf==2, "I"
                ,ifelse( X_func==2 & X_dysf==3, "M"
                ,ifelse( X_func==3 & X_dysf==1, "I"
                ,ifelse( X_func==3 & X_dysf==2, "I"
                ,ifelse( X_func==3 & X_dysf==3, "M"
                ,NA)))))))))
    }else if(type==5){

      myrow<-  ifelse(X_func==1 & X_dysf==1, "Q"
             ,ifelse( X_func==1 & X_dysf==2, "A"
             ,ifelse( X_func==1 & X_dysf==3, "A"
             ,ifelse( X_func==1 & X_dysf==4, "A"
             ,ifelse( X_func==1 & X_dysf==5, "O"
             ,ifelse( X_func==2 & X_dysf==1, "R"
             ,ifelse( X_func==2 & X_dysf==2, "I"
             ,ifelse( X_func==2 & X_dysf==3, "I"
             ,ifelse( X_func==2 & X_dysf==4, "I"
             ,ifelse( X_func==2 & X_dysf==5, "M"
             ,ifelse( X_func==3 & X_dysf==1, "R"
             ,ifelse( X_func==3 & X_dysf==2, "I"
             ,ifelse( X_func==3 & X_dysf==3, "I"
             ,ifelse( X_func==3 & X_dysf==4, "I"
             ,ifelse( X_func==3 & X_dysf==5, "M"
             ,ifelse( X_func==4 & X_dysf==1, "R"
             ,ifelse( X_func==4 & X_dysf==2, "I"
             ,ifelse( X_func==4 & X_dysf==3, "I"
             ,ifelse( X_func==4 & X_dysf==4, "I"
             ,ifelse( X_func==4 & X_dysf==5, "M"
             ,ifelse( X_func==5 & X_dysf==1, "R"
             ,ifelse( X_func==5 & X_dysf==2, "R"
             ,ifelse( X_func==5 & X_dysf==3, "R"
             ,ifelse( X_func==5 & X_dysf==4, "R"
             ,ifelse( X_func==5 & X_dysf==5, "Q"
             ,NA)))))))))))))))))))))))))
    }
 #  n<- sample.int(length(X_func))[1]

    note<- paste(note, "\nnr:", #n,
                 X$measure.vars[i], "|", X$measure.vars[i+1]
                 #, X_func[n],"+", X_dysf[n], "=", myrow[n]
                 )
    ANS<-cbind(ANS, myrow)
  }

  Errorrs <- rep(FALSE, n)
  if (rm_Q < 10000 | rm_I < 10000) {
    note <- paste(note, "\nFilter: ")
    if (rm_Q < 10000)
      note<-  paste(note, "Entferne Fälle die mehr als", rm_Q, "(Q)-Antworten haben ")
    if (rm_I < 10000)
      note<-  paste(note, "Entferne Fälle die mehr als", rm_I, "(I)-Antworten haben")

    Errorrs <- apply(ANS, 1,
                     function(x)
                       any(c(
                         sum(x == "Q", na.rm = TRUE) > rm_Q , sum(x == "I", na.rm = TRUE) > rm_I
                       )))
    n_rm <- sum(Errorrs)
    note <- paste(note, "(N =", length(Errorrs) - n_rm, ", removed =", n_rm, ")")

    ANS[which(Errorrs), ] <-  NA
    Scors[which(Errorrs), ] <- NA
  }


  ANS <-
    as.data.frame(lapply(as.data.frame(ANS), function(x)
      factor(x, levels = kano_levels)))
  colnames(ANS) <- nams

  if (is.null(grouping_data)) {
    data <-  cbind(nr = 1:nrow(ANS), ANS)
    molten <- stp25tools::Long(data, id.vars=1)
    fm <- value ~ variable
  } else{
    data <- cbind(nr = 1:nrow(ANS), grouping_data, ANS)
    molten <- stp25tools::Long(data, id.vars = 1:(ncol(grouping_data)+1))
    fm <-
      formula(paste("value~",
                    paste(c(X$group.vars, "variable"),
                          collapse ="+")))
  }

 molten$value <- factor(molten$value, kano_levels)

 res<-list(data= data,
            molten=molten,
            scors=Scors,
            formula= fm,
            func=vars_func,
            dysfunc= vars_dysfunc,
            groups=X$group.vars,
            removed=Errorrs,
            N =c(  total=nrow(data),
                   N=nrow(data)-sum(Errorrs),
                   removed=sum(Errorrs)),
            attributes=  attributes,
            answers= answers[1:type],
            note=note)
  class(res)<-"Kano"

 res
}


#' tbll_extract_kano
#'
#' @noRd
tbll_extract_kano  <- function(x,
                            caption = "",
                            note = "",
                            formula = x$formula,
                            data = x$molten[-1],
                            digits = 1,
                            include.n = TRUE,
                            include.percent = TRUE,
                            include.total = TRUE,
                            include.test = TRUE,
                            include.fong = TRUE
                            ,rnd_output = TRUE
                            ) {
  var_names = c(
    n = "Total",
    M = "M",
    O = "O",
    A = "A",
    I = "I",
    R = "R",
    Q = "Q",
    max.Kat = "max Category",
    M.O.A.I = "M>O>A>I",
    Total.Strength = "Total Strength",
    Category.Strength = "Category Strength",
    CS.plus = "CS plus",
    CS.minus = "CS minus",
    Chi = "Chi-squared Test",
    Fong = "Fong-Test"
  )

  kano_kategorien <- c("M", "O", "A", "I", "R", "Q")

  Fong <- function(x) {
    if (length(x) == 0) {
      "ns"
    }
    else{
      n <- sum(x)
      x <- sort(as.numeric(x[1:5]), decreasing = TRUE)
      a <- x[1]
      b <- x[2]

      lhs <- abs(a - b)
      rhs <- round(1.65 * sqrt(((a + b) * (2 * n - a - b)) /
                                 (2 * n)), 1)
      fm <- paste(lhs, "<", rhs)

      ifelse(lhs < rhs , paste(fm, "ns") , paste(fm, "sig."))
    }
 }


  kano_aggregate <- function(x) {
    x     <-   factor(x, levels = kano_kategorien)
    tab   <-   table(x)
    proptab <- prop.table(tab)

    if (include.percent) {
      if (include.n) {
        myTab <- stp25stat2:::rndr_percent(as.vector(proptab * 100), as.vector(tab))
      } else{
        myTab <- stp25stat2:::rndr_percent(as.vector(proptab * 100))
      }
    } else{
      myTab <- as.vector(tab)
    }

    names(myTab) <- names(tab)

    Kat <-   names(sort(tab, decreasing = TRUE))
    max.Kat <- Kat[1]
    Cat <-
      as.numeric(diff(sort(proptab[c("O", "A", "M", "I", "R")], decreasing = TRUE)[2:1]))    # Category.Strength
    Tot <-
      as.numeric(proptab["A"] + proptab["O"] + proptab["M"])        # Total.Strength
    # q.value <-  (tab["A"]*3+ tab["O"]*2+ tab["M"])/(tab["A"]+ tab["O"]+ tab["M"])
    Auswertregel <- ifelse(Cat > 0.06,           max.Kat
                           , ifelse(any(Kat[1:2] == "M"), "M"
                                    , ifelse(
                                      any(Kat[1:2] == "O"), "O"
                                      , ifelse(any(Kat[1:2] == "A"), "A"
                                               , ifelse(any(Kat[1:2] == "I"), "I"
                                                        , NA))
                                    )))

    #Auswertung nach (O + A + M) >< (I + Q + R)
    #Wenn M + A + O > I + Q + R, dann Max (M, A, O)
    #Wenn M + A + O < I + Q + R, dann Max (I, Q, R)

    res <- c(
      n = length(na.omit(x)),
      myTab,
      max.Kat = max.Kat,
      M.O.A.I = Auswertregel,
      Total.Strength =   stp25stat2:::rndr_percent(Tot * 100),
      Category.Strength =  stp25stat2:::rndr_percent(Cat * 100),
      #,q.value=round(q.value,2)

      CS.plus = round(as.numeric(
                 (tab["A"] + tab["O"]) /
                 (tab["A"] + tab["O"] + tab["M"] + tab["I"])
                ), 3),
      CS.minus = round(as.numeric(
                  (tab["O"] + tab["M"]) /
                  (tab["A"] + tab["O"] + tab["M"] + tab["I"])
                ), 3) * -1

    )
    if (include.test) {
      if (length(x) == 0 | sum(tab[1:4]) < 12) {
        res <- c(res, Chi = "n.a.")
      } else{
        chi <- suppressWarnings(stats::chisq.test(tab[1:4]))
        res <-
          c(res, Chi = stp25stat2:::rndr_Chisq_stars(chi$statistic, chi$p.value))
      }
    }

    if (include.fong) {
      if (length(x) == 0 | sum(tab[1:4]) < 12) {
        res <- c(res, Fong = "n.a.")
      } else{
        res <- c(res,
                 Fong = Fong(tab))
      }
    }
        if (include.total)
      res
    else
      res[-1]
  }


  kano_aggregate_num <- function(x) {
    x   <-   factor(x, levels = kano_kategorien)
    tab <-   table(x)
    proptab <- prop.table(tab)
    myTab <- as.vector(tab)
    names(myTab) <- names(tab)
    Kat <-   names(sort(tab, decreasing = TRUE))
    max.Kat <- Kat[1]
    Cat <-
      as.numeric(diff(sort(proptab[c("O", "A", "M", "I", "R")], decreasing = TRUE)[2:1]))    # Category.Strength
    Tot <-
      as.numeric(proptab["A"] + proptab["O"] + proptab["M"])        # Total.Strength
    # q.value <-  (tab["A"]*3+ tab["O"]*2+ tab["M"])/(tab["A"]+ tab["O"]+ tab["M"])
    Auswertregel <- ifelse(Cat > 0.06, max.Kat
                           , ifelse(any(Kat[1:2] == "M"), "M"
                                    , ifelse(
                                      any(Kat[1:2] == "O"), "O"
                                      , ifelse(any(Kat[1:2] == "A"), "A"
                                               , ifelse(any(Kat[1:2] == "I"), "I"
                                                        , NA))
                                    )))


    c(
      n = length(na.omit(x)),
      myTab,
      max.Kat =  as.numeric(factor(max.Kat, levels = kano_kategorien))  ,
      M.O.A.I = as.numeric(factor(Auswertregel, levels = kano_kategorien)) ,
      Total.Strength =    Tot ,
      Category.Strength = Cat,
      CS.plus =  as.numeric((tab["A"] + tab["O"]) / (tab["A"] + tab["O"] + tab["M"] + tab["I"])),
      CS.minus = (as.numeric((tab["O"] + tab["M"]) / (
        tab["A"] + tab["O"] + tab["M"] + tab["I"]
      ))) * -1
    )


  }

  if (rnd_output) {
    #Formatierte Ausgabe
    ans <-
      as.data.frame(aggregate(formula, data, FUN = kano_aggregate))
    n_names <- length(names(ans))
    #result ist eine liste
    ans_value <-  as.data.frame(ans[n_names]$value)

    var_names <-
      var_names[intersect(names(var_names), names(ans_value))]

    names(ans_value) <- var_names
    ans <- cbind(ans[-n_names], ans_value)

    stp25stat2::prepare_output(ans,
                   caption = caption,
                   note = note,
                   N = x$N["N"])
   }
  else{
    ans <-
      as.data.frame(aggregate(formula, data, FUN = kano_aggregate_num))

    n_names <- length(names(ans))
    ans_value <-  as.data.frame(ans[n_names]$value)
    ans <- cbind(ans[-n_names], ans_value)

    ans$max.Kat <-
      as.character(factor(ans$max.Kat, 1:length(kano_kategorien),  kano_kategorien))
    ans$M.O.A.I <-
      as.character(factor(ans$M.O.A.I, 1:length(kano_kategorien),  kano_kategorien))

    ans
  }
}





#' Tbll Kano
#'
#' @param include.n,include.percent Anzahl, Prozent
#' @param include.total N und Total
#' @param include.test,include.fong Fong und Chie-Test
#' @param include.total Anzahl Total
#'
#' @return data.frame
#' @rdname Kano
#' @export
Tbll_kano  <- function(x,
                       digits = 1,
                       include.n = TRUE,
                       include.percent = TRUE,
                       include.total = TRUE,
                       include.test = TRUE,
                       include.fong = TRUE) {
tbll_extract_kano(
    x,
    caption = "Kano",
    note = "",
    digits = digits,
    include.n = include.n,
    include.percent = include.percent,
    include.total = include.total,
    include.test = include.test,
    include.fong = include.fong,
    rnd_output = TRUE
  )

}



