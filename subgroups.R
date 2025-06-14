baseline_data = function(seed)
{
  set.seed(seed)
  N = sample(100:150, size=1)
  pFem = 0.3
  Sex = factor(rbinom(N, size=1, prob=pFem), levels=c(0, 1), labels=c("M", "F"))
  AgeMo = round(runif(N, min=30, max=80))
  Ill = rnorm(N, mean=6 - as.numeric(Sex) + 0.05*AgeMo, sd=2)
  T0 = round(rnorm(N, mean=Ill, sd=2), 1)
  d = data.frame(ID=1:N, Sex, AgeMo, T0)
  
  # Inclusion criteria
  Ill = Ill[d$T0 > 2 & d$T0 < 10]
  d = d[d$T0 > 2 & d$T0 < 10, ]
  N = nrow(d)
  
  # Randomization
  d$Therapy = factor(rbinom(N, size=1, prob=0.5), levels=c(0, 1), labels=c("Lidcombe", "TAU"))
  
  # Treatment fidelity
  d$Fidel = pmin(100, pmax(20, round(rnorm(N, mean=70, sd=15))))
  
  # EOT depends on therapy and fidelity
  d$EOT = pmax(0, pmin(10, round(digits=1, rnorm(N,
                                                 mean=Ill-5.1-d$Fidel*0.03+1.2*as.numeric(d$Therapy), sd=2))))
  d$FU = pmax(0, pmin(10, round(digits=1, rnorm(N,
                                                mean=Ill-6.3-d$Fidel*0.02+1.5*as.numeric(d$Therapy), sd=2))))
  
  d$Therapy = as.character(d$Therapy)
  return(d)
}

data  <- baseline_data(seed=4711)
N     <- nrow(data)
m_T0  <- by(data$T0, data$Therapy, mean)
s_T0  <- by(data$T0, data$Therapy, sd)
m_EOT <- by(data$EOT, data$Therapy, mean)
s_EOT <- by(data$EOT, data$Therapy, sd)
m_FU  <- by(data$FU, data$Therapy, mean)
s_FU  <- by(data$FU, data$Therapy, sd)
alpha <- 0.05
tails <- "two-tailed"

Lidcombe_T0_Mean  <- m_T0["Lidcombe"]
Lidcombe_T0_SD    <- s_T0["Lidcombe"]
Lidcombe_T0       <- sprintf("%.1f (%.1f)", Lidcombe_T0_Mean, Lidcombe_T0_SD)
TAU_T0_Mean       <- m_T0["TAU"]
TAU_T0_SD         <- s_T0["TAU"]
TAU_T0            <- sprintf("%.1f (%.1f)", TAU_T0_Mean, TAU_T0_SD)
Lidcombe_EOT_Mean <- m_EOT["Lidcombe"]
Lidcombe_EOT_SD   <- s_EOT["Lidcombe"]
Lidcombe_EOT      <- sprintf("%.1f (%.1f)", Lidcombe_EOT_Mean, Lidcombe_EOT_SD)
TAU_EOT_Mean      <- m_EOT["TAU"]
TAU_EOT_SD        <- s_EOT["TAU"]
TAU_EOT           <- sprintf("%.1f (%.1f)", TAU_EOT_Mean, TAU_EOT_SD)

# Export data for download
download <- function(fname)
  write.csv2(data, fname, row.names=FALSE)

ancova_f = function(Prim, Cov, Strata, Other, Int, Ex, Main) {
  Predictors = paste(c(Cov, Strata, Int, list(Main)), collapse="+")
  formula = sprintf("%s ~ %s", Prim, Predictors)
  m = lm(formula, data=data)
  terms = attr(terms(m), "term.labels")
  Int_index = which(terms == Int)
  anova(m)[Int_index, "F value"]
}

ancova_p = function(Prim, Cov, Strata, Other, Int, Ex, Main)
{
  Predictors = paste(c(Cov, Strata, Int, list(Main)), collapse="+")
  formula = sprintf("%s ~ %s", Prim, Predictors)
  m = lm(formula, data=data)
  terms = attr(terms(m), "term.labels")
  Int_index = which(terms == Int)
  anova(m)[Int_index, "Pr(>F)"]
}


library(emmeans)
ancova_ci = function(Prim, Cov, Strata, Other, Int, Ex, Main)
{
  Predictors = paste(c(Cov, Strata, list(Main)), collapse="+")
  formula = sprintf("%s ~ %s", Prim, Predictors)
  m <- lm(formula, data=data)
  emm <- emmeans(m, Main, contr="trt.vs.ctrl1")
  ci <- confint(emm)$contrasts
  lower <- ci[1, "lower.CL"]
  upper <- ci[1, "upper.CL"]
  substitute(call("ci", lower, upper), list(lower = lower, upper = upper))
}