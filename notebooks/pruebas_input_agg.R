library(mice)

source("../utils.R")
md.pattern(capacidades)

c <- mice(data = capacidades, m=5, method = "pmm", maxit = 10, seed = 500)
c1 <- complete(c,1)
c2 <- complete(c,2) 
c3 <- complete(c,3) 
c4 <- complete(c,4) 
c5 <- complete(c,5) 

c_predictor_matrix <- c$predictorMatrix

c$chainMean
c$chainVar

imp_c1 <- c$imp$complejidad_2014
imp_c2 <- c$imp$flexibilidad_financiera
imp_c3 <- c$imp$capacidad_inversion
imp_c4 <- c$imp$n_usuarios
imp_c5 <- c$imp$pct_viv_con_internet
imp_c6 <- c$imp$densidad_camas
imp_c7 <- c$imp$densidad_hospitales
imp_c8 <- c$imp$densidad_medicos

md.pattern(vulnerabilidades)

v <- mice(data = vulnerabilidades, m = 5, method = "pmm", maxit = 10, seed = 500)
v1 <- complete(v,1) 
v2 <- complete(v,2) 
v3 <- complete(v,3) 
v4 <- complete(v,4) 
v5 <- complete(v,5) 

imp_v1 <- v$imp$ic_rezedu_porcentaje
imp_v2 <- v$imp$ic_asalud_porcentaje
imp_v3 <- v$imp$ic_segsoc_porcentaje
imp_v4 <- v$imp$ic_cv_porcentaje
imp_v5 <- v$imp$ic_sbv_porcentaje
imp_v6 <- v$imp$pobreza_porcentaje
imp_v7 <- v$imp$vul_ing_porcentaje

v_predictor_matrix <- v$predictorMatrix

v$chainMean
v$chainVar

stripplot(y1 ~ .imp, data = imp_tot2, jit = TRUE, col = col, xlab = "imputation Number")

# 2. Capping
# For missing values that lie outside the 1.5 * IQR limits, we could cap it by replacing those
# observations outside the lower limit with the value of 5th %ile and those that lie above the 
# upper limit, with the value of 95th %ile. Below is a sample code that achieves this.
#x <- vulnerabilidades$brecha_horas_cuidados
#qnt <- quantile(x, probs=c(.25, .75), na.rm = T)
#caps <- quantile(x, probs=c(.05, .95), na.rm = T)
#H <- 1.5 * IQR(x, na.rm = T)
#x[x < (qnt[1] - H)] <- caps[1]
#x[x > (qnt[2] + H)] <- caps[2]

# Ejemplo pca tidyverse
#inform_pca <- select_if(inform_mun,is.numeric) %>% 
#  nest() %>% 
#  mutate(pca = map(data, ~ prcomp(.x, 
#                                  center = TRUE, scale = TRUE)),
#        pca_aug = map2(pca, data, ~augment(.x, data = .y)))