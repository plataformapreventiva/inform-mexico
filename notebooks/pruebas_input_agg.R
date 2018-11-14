library(mice)
c <- mice(data = capacidades, m = 5, method = "pmm", maxit = 10, seed = 500)
v <- mice(data = vulnerabilidades, m = 5, method = "pmm", maxit = 10, seed = 500)
a <- mice(data = amenazas, m = 5, method = "pmm", maxit = 10, seed = 500)

i <- complete(c,1) 
i2 <- complete(v,1) 
i3 <- complete(a,1) 

create_reports(select_if(c, is.numeric),
               task_name = "capacidades_mun_input", 
               output_dir = "/home/alicia/workspace/inform-mexico/eda/reportes/capacidades")

imp_1 <- a$imp$cve_muni
imp_2 <- a$imp$n_usuarios
imp_3 <- a$imp$densidad_medicos
imp_4 <- a$imp$densidad_hospitales
imp_5 <- a$imp$densidad_camas
imp_6 <- a$imp$cobertura_dren
imp_7 <- a$imp$nd_spnn1
imp_8 <- a$imp$nd_nsnn4
imp_9 <- a$imp$aut_cobr
imp_10 <- a$imp$indice
imp_11 <- a$imp$capacidad_inversion
imp_12 <- a$imp$flexibilidad_financiera
imp_13 <- a$imp$complejidad_2014
imp_14 <- a$imp$pct_viv_con_internet
imp_15 <- a$imp$basura_porcent_cab
imp_16 <- a$imp$totalpo1


b <- mice(data = capacidades, m = 5, method = "2lonly.pmm", maxit = 50, seed = 500)
c <- mice(data = capacidades, m = 5, method = "cart", maxit = 50, seed = 500)
d <- mice(data = capacidades, m = 5, method = "rf", maxit = 50, seed = 500)


inform_pca <- select_if(inform_mun,is.numeric) %>% 
  nest() %>% 
  mutate(pca = map(data, ~ prcomp(.x, 
                                  center = TRUE, scale = TRUE)),
         pca_aug = map2(pca, data, ~augment(.x, data = .y)))
