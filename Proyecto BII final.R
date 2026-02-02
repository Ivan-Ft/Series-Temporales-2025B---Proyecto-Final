###############################################################################
#        PROYECTO SERIES DE TIEMPO – PAGOS DE DESEMPLEO IESS (FPP3)
###############################################################################

# ===========================================
# Paquetes
# ===========================================
# Limpiar el entorno de trabajo
rm(list = ls())
gc()
library(readxl)
library(dplyr)
library(purrr)
library(tsibble)
library(lubridate)
library(stringr)
library(ggplot2)
library(fpp3)
library(zoo)
library(tidyr)
library(conflicted)
library(GGally)

# Usar conflicted para evitar conflictos de funciones
conflict_prefer("filter", "dplyr")
conflict_prefer("select", "dplyr")

# ===========================================
# Directorio de trabajo
# ===========================================
setwd("C:/Users/crist/Dropbox/PC/Documents/Proyecto 1/Proyecto 1")

# ===========================================
# Función para procesar cada archivo
# ===========================================
procesar_archivo <- function(nombre_archivo, nombre_hoja, mes_label) {
  cat("Procesando:", nombre_archivo, "\n")
  
  datos <- read_excel(nombre_archivo, sheet = nombre_hoja) %>%
    as.data.frame()
  
  if (!"Provincia" %in% names(datos)) {
    stop("No existe la columna 'Provincia' en ", nombre_archivo)
  }
  
  datos %>%
    group_by(Provincia) %>%
    summarise(
      total_valor_pagado = sum(`Valor Pagado`, na.rm = TRUE),
      total_beneficiarios = sum(`Número Beneficiarios`, na.rm = TRUE)
    ) %>%
    mutate(mes = mes_label) %>%
    filter(!is.na(Provincia))
}

# ===========================================
#  Lista de archivos (2021–2025)
# ===========================================
archivos <- list(
  # 2021
  c("pagos-desempleo-julio-2021.xlsx", "Hoja1", "jul2021"),
  c("pagos-desempleo-agosto-2021.xlsx", "pagos-desempleo-agosto-2021", "agos2021"),
  c("pagos-desempleo-septiembre-2021.xlsx", "pagos-desempleo-septiembre-2021", "sept2021"),
  c("pagos-desempleo-octubre-2021.xlsx", "pagos-desempleo-octubre-2021", "oct2021"),
  c("pagos-desempleo-noviembre-2021.xlsx", "pagos-desempleo-noviembre-2021", "nov2021"),
  c("pagos-desempleo-diciembre-2021.xlsx", "pagos-desempleo-diciembre-2021", "dic2021"),
  
  # 2022
  c("pagos-desempleo-enero-2022.xlsx", "pagos-desempleo-enero-2022", "ene2022"),
  c("pagos-desempleo-febrero-2022.xlsx", "pagos-desempleo-febrero-2022", "feb2022"),
  c("pagos-desempleo-marzo-2022.xlsx", "pagos-desempleo-marzo-2022", "mar2022"),
  c("pagos-desempleo-abril-2022.xlsx", "pagos-desempleo-abril-2022", "abr2022"),
  c("pagos-desempleo-mayo-2022.xlsx", "pagos-desempleo-mayo-2022", "may2022"),
  c("pagos-desempleo-junio-2022.xlsx", "pagos-desempleo-junio-2022", "jun2022"),
  c("pagos-desempleo-julio-2022.xlsx", "pagos-desempleo-julio-2022", "jul2022"),
  c("pagos-desempleo-agosto-2022.xlsx", "pagos-desempleo-agosto-2022", "agos2022"),
  c("pagos-desempleo-septiembre-2022.xlsx", "pagos-desempleo-septiembre-2022", "sept2022"),
  c("pagos-desempleo-octubre-2022.xlsx", "pagos-desempleo-octubre-2022", "oct2022"),
  c("pagos-desempleo-noviembre-2022.xlsx", "pagos-desempleo-noviembre-2022", "nov2022"),
  c("pagos-desempleo-diciembre-2022.xlsx", "pagos-desempleo-diciembre-2022", "dic2022"),
  
  # 2023 (sin abril ni mayo)
  c("pagos-desempleo-enero-2023.xlsx", "pagos-desempleo-enero-2023", "ene2023"),
  c("pagos-desempleo-febrero-2023.xlsx", "pagos-desempleo-febrero-2023", "feb2023"),
  c("pagos-desempleo-marzo-2023.xlsx", "pagos-desempleo-marzo-2023", "mar2023"),
  c("pagos-desempleo-junio-2023.xlsx", "pagos-desempleo-junio-2023", "jun2023"),
  c("pagos-desempleo-julio-2023.xlsx", "pagos-desempleo-julio-2023", "jul2023"),
  c("pagos-desempleo-agosto-2023.xlsx", "pagos-desempleo-agosto-2023", "agos2023"),
  c("pagos-desempleo-septiembre-2023.xlsx", "pagos-desempleo-septiembre-2023", "sept2023"),
  c("pagos-desempleo-octubre-2023.xlsx", "pagos-desempleo-octubre-2023", "oct2023"),
  c("pagos-desempleo-noviembre-2023.xlsx", "pagos-desempleo-noviembre-2023", "nov2023"),
  c("pagos-desempleo-diciembre-2023.xlsx", "pagos-desempleo-diciembre-2023", "dic2023"),
  
  # 2024
  c("pagos-desempleo-enero-2024.xlsx", "pagos-desempleo-enero-2024", "ene2024"),
  c("pagos-desempleo-febrero-2024.xlsx", "pagos-desempleo-febrero-2024", "feb2024"),
  c("pagos-desempleo-marzo-2024.xlsx", "pagos-desempleo-marzo-2024", "mar2024"),
  c("pagos-desempleo-abril-2024.xlsx", "pagos-desempleo-abril-2024", "abr2024"),
  c("pagos-desempleo-mayo-2024.xlsx", "pagos-desempleo-mayo-2024", "may2024"),
  c("pagos-desempleo-junio-2024.xlsx", "pagos-desempleo-junio-2024", "jun2024"),
  c("pagos-desempleo-julio-2024.xlsx", "pagos-desempleo-julio-2024", "jul2024"),
  c("pagos-desempleo-agosto-2024.xlsx", "pagos-desempleo-agosto-2024", "agos2024"),
  c("pagos-desempleo-septiembre-2024.xlsx", "pagos-desempleo-septiembre-2024", "sept2024"),
  c("pagos-desempleo-octubre-2024.xlsx", "pagos-desempleo-octubre-2024", "oct2024"),
  c("pagos-desempleo-noviembre-2024.xlsx", "pagos-desempleo-noviembre-2024", "nov2024"),
  c("pagos-desempleo-diciembre-2024.xlsx", "pagos-desempleo-diciembre-2024", "dic2024"),
  
  # 2025 (sin abril)
  c("pagos-desempleo-enero-2025.xlsx", "pagos-desempleo-enero-2025", "ene2025"),
  c("pagos-desempleo-febrero-2025.xlsx", "pagos-desempleo-febrero-2025", "feb2025"),
  c("pagos-desempleo-marzo-2025.xlsx", "pagos-desempleo-marzo-2025", "mar2025"),
  c("pagos-desempleo-mayo-2025.xlsx", "pagos-desempleo-mayo-2025", "may2025"),
  c("pagos-desempleo-junio-2025.xlsx", "pagos-desempleo-junio-2025", "jun2025"),
  c("pagos-desempleo-julio-2025.xlsx", "pagos-desempleo-julio-2025", "jul2025"),
  c("pagos-desempleo-agosto-2025.xlsx", "pagos-desempleo-agosto-2025", "agos2025"),
  c("pagos-desempleo-septiembre-2025.xlsx", "pagos-desempleo-septiembre-2025", "sept2025")
)


# ===========================================
# Procesar todos los archivos y rellenar los gaps
# ===========================================
# Ya tienes el código para cargar y procesar los datos. Vamos a aplicar el mismo proceso a todas las provincias y rellenar los valores faltantes.

# Procesar todos los archivos de forma similar a lo que ya tienes
datos_completos <- map_dfr(archivos, ~ procesar_archivo(.x[1], .x[2], .x[3]))

# ===========================================
# Crear serie temporal para cada provincia
# ===========================================
# Vamos a crear una lista con todas las provincias para trabajar con ellas
provincias <- unique(datos_completos$Provincia)

# Asumiendo que ya tienes 'datos_completos' cargado y las librerías necesarias
# Convertimos el mes a formato adecuado para todas las provincias

datos_completos <- datos_completos %>%
  mutate(
    # Convertir a minúsculas y eliminar espacios y caracteres no alfanuméricos
    mes = str_to_lower(mes),
    mes = str_trim(mes),
    mes = str_replace_all(mes, "[^a-z0-9]", ""),
    
    # Asignar el número de mes correspondiente a cada mes
    mes_num = case_when(
      str_detect(mes, "ene") ~ "01",
      str_detect(mes, "feb") ~ "02",
      str_detect(mes, "mar") ~ "03",
      str_detect(mes, "abr") ~ "04",
      str_detect(mes, "may") ~ "05",
      str_detect(mes, "jun") ~ "06",
      str_detect(mes, "jul") ~ "07",
      str_detect(mes, "ago") ~ "08",
      str_detect(mes, "sep|set|sept") ~ "09",
      str_detect(mes, "oct") ~ "10",
      str_detect(mes, "nov") ~ "11",
      str_detect(mes, "dic") ~ "12",
      TRUE ~ NA_character_
    ),
    
    # Extraer el año del mes
    anio = str_extract(mes, "\\d{4}"),
    
    # Crear la variable 'mes_fmt' con el formato "yyyy-mm"
    mes_fmt = paste0(anio, "-", mes_num),
    
    # Convertir 'mes_fmt' a un objeto de tipo yearmonth
    mes = yearmonth(mes_fmt)
  ) %>%
  # Filtrar para eliminar filas con 'mes' NA
  filter(!is.na(mes)) %>%
  arrange(mes)

# Verificar los primeros registros para asegurarse de que el formato es correcto
head(datos_completos)


# Inicializamos una lista vacía para almacenar los datos procesados
ts_datos_provincias <- list()

# Bucle para procesar y rellenar los gaps de todas las provincias
for (provincia in provincias) {
  ts_provincia <- datos_completos %>%
    filter(Provincia == provincia) %>%
    as_tsibble(index = mes) %>%  # Convertir a tsibble
    fill_gaps() %>%  # Rellenar los gaps (muestra faltantes)
    mutate(
      # Aquí aplicamos interpolación para rellenar los gaps (NAs)
      total_valor_pagado = zoo::na.approx(total_valor_pagado, na.rm = FALSE),
      total_valor_pagado = zoo::na.locf(total_valor_pagado, na.rm = FALSE),
      total_valor_pagado = zoo::na.locf(total_valor_pagado, fromLast = TRUE),
      
      total_beneficiarios = zoo::na.approx(total_beneficiarios, na.rm = FALSE),
      total_beneficiarios = zoo::na.locf(total_beneficiarios, na.rm = FALSE),
      total_beneficiarios = zoo::na.locf(total_beneficiarios, fromLast = TRUE)
    ) %>%
    # Aquí rellenamos las columnas que faltan con `fill()`
    fill(Provincia, anio, mes_num, mes_fmt) %>%
    mutate(
      # Convertir 'mes' a formato yearmonth después de rellenar
      mes = yearmonth(mes)
    ) %>%
    as_tibble()  # Convertir tsibble a tibble normal para combinar
  
  # Guardamos el resultado procesado para la provincia
  ts_datos_provincias[[provincia]] <- ts_provincia
}

# ===========================================
# Combinamos todos los datos procesados
# ===========================================
# Convertimos la lista de resultados en un solo dataframe
datos_finales <- bind_rows(ts_datos_provincias)

# Verificación final de los primeros registros
head(datos_finales)

fecha_train <- "2024-11"

# 1. Leer correctamente el CSV (delimitado por ;)
desempleo_raw <- read_excel(
  path  = "Desempleo.xlsx",  # <-- CAMBIA EL NOMBRE
  sheet = 1                          # o "Ark1" si esa es la hoja
)

desempleo_ts <- desempleo_raw %>%
  rename(
    periodo   = `Período`,
    tasa = `Tasa de desempleo nacional en Porcentaje - Mensual`
  ) %>%
  mutate(
    # Asegurar fecha (si ya viene como POSIXct/Date, esto no molesta)
    periodo = as.Date(periodo),
    
    # Convertir a yearmonth para tsibble
    mes = yearmonth(periodo),
    
    # Limpiar números si vienen como texto con coma decimal
    across(c(tasa), ~ {
      if (is.character(.x)) {
        .x <- str_replace_all(.x, ",", ".")
      }
      as.numeric(.x)
    })
  ) %>%
  select(mes, tasa)%>%
  arrange(mes) %>%
  as_tsibble(index = mes)

desempleo_ts
# Filtrar desempleo desde 2021-07 hasta 2025-10

inicio <- yearmonth("2021-07")
fin    <- yearmonth("2025-09")

desempleo<- desempleo_ts %>%
  filter(mes >= inicio, mes <= fin)

desempleo

#Inflacion
inflacion_raw <- read_excel(
  path  = "Inflacion.xlsx",  # <-- CAMBIA EL NOMBRE
  sheet = 1                          # o "Ark1" si esa es la hoja
)

inflacion_ts <- inflacion_raw %>%
  rename(
    periodo   = `Período`,
    infl_mens = Mensual
  ) %>%
  mutate(
    # Asegurar fecha (si ya viene como POSIXct/Date, esto no molesta)
    periodo = as.Date(periodo),
    
    # Convertir a yearmonth para tsibble
    mes = yearmonth(periodo),
    
    # Limpiar números si vienen como texto con coma decimal
    across(c(infl_mens), ~ {
      if (is.character(.x)) {
        .x <- str_replace_all(.x, ",", ".")
      }
      as.numeric(.x)
    })
  ) %>%
  select(mes, infl_mens)%>%
  arrange(mes) %>%
  as_tsibble(index = mes)

inflacion_ts
inflacion <- inflacion_ts %>%
  filter(mes >= inicio, mes <= fin)

datos_modelo <- datos_finales %>%
  left_join(as_tibble(inflacion), by = "mes") %>%
  left_join(as_tibble(desempleo), by = "mes")

datos_modelo

library(readr)
riesgo_pais_raw<- read_csv("riesgo-pas.csv")

riesgo_pais_raw <- riesgo_pais_raw %>%
  separate(
    col = 'Período;Riesgo País en Puntos Básicos',
    into = c("fecha", "riesgo_pais"),
    sep = ";"
  )

riesgo_pais_raw <- riesgo_pais_raw %>%
  mutate(
    fecha = as.POSIXct(fecha, format = "%Y-%m-%d %H:%M:%S"),
    riesgo_pais = as.numeric(riesgo_pais)
  )

riesgo_pais_raw <- riesgo_pais_raw %>%
  mutate(
    mes = yearmonth(fecha)
  )


riesgo_pais_mensual <- riesgo_pais_raw %>%
  group_by(mes) %>%
  summarise(
    riesgo_pais = mean(riesgo_pais, na.rm = TRUE),
    .groups = "drop"
  )


riesgo_pais_mensual <- riesgo_pais_mensual %>%
  filter(
    mes >= yearmonth("2021 Jul"),
    mes <= yearmonth("2025 Sep")
  )


riesgo_pais_ts <- riesgo_pais_mensual %>%
  arrange(mes) %>%
  as_tsibble(index = mes)

datos_modelo <- datos_modelo %>%
  group_by(mes) %>%
  summarise(
    total_pagos = sum(total_valor_pagado, na.rm = TRUE),
    total_beneficiarios = sum(total_beneficiarios, na.rm = TRUE),
    
    infl_mens = dplyr::first(infl_mens),
    tasa_desempleo = dplyr::first(tasa)
  ) %>%
  ungroup() %>%
  arrange(mes)

datos_modelo <- datos_modelo %>%
  left_join(as_tibble(riesgo_pais_mensual), by = "mes") 
datos_modelo

# ==========================================================
# 0) Asegurar tsibble y ordenar
# ==========================================================
ts <- datos_modelo %>%
  arrange(mes) %>%
  as_tsibble(index = mes)


#===================================================
# ANALISIS EXPLORATORIO
#==============================================

ts %>%
  select(mes, total_beneficiarios, infl_mens, tasa_desempleo, riesgo_pais) %>%
  pivot_longer(-mes, names_to = "variable", values_to = "valor") %>%
  ggplot(aes(x = mes, y = valor)) +
  geom_line() +
  facet_wrap(~ variable, scales = "free_y", ncol = 2) +
  labs(
    title = "Series mensuales (jul-2021 a sep-2025)",
    x = "Mes", y = NULL
  ) +
  theme_minimal()

#TENDENCIA, ESTACIONALIDAD Y CICLOS
# 2.1 Desempleo
ts %>%
  model(STL(tasa_desempleo ~ season(window = "periodic"))) %>%
  components() %>%
  autoplot() +
  labs(title = "STL – Tasa de desempleo")

# 2.2 Inflación mensual
ts %>%
  model(STL(infl_mens ~ season(window = "periodic"))) %>%
  components() %>%
  autoplot() +
  labs(title = "STL – Inflación mensual")

# 2.3 Riesgo país
ts %>%
  model(STL(riesgo_pais ~ season(window = "periodic"))) %>%
  components() %>%
  autoplot() +
  labs(title = "STL – Riesgo país")

# 2.4 Beneficiarios 
ts %>%
  model(STL(total_beneficiarios ~ season(window = "periodic"))) %>%
  components() %>%
  autoplot() +
  labs(title = "STL – Beneficiarios")

ts %>% mutate(log_ben = log(total_beneficiarios + 1)) %>%
  model(STL(log_ben ~ season(window="periodic"))) %>%
  components() %>% autoplot() +
  labs(title="STL – log(Beneficiarios)")


#ACF y PACF
ts %>%
  ACF(tasa_desempleo) %>%
  autoplot() +
  labs(title = "ACF – Tasa de desempleo")

ts %>%
  PACF(tasa_desempleo) %>%
  autoplot() +
  labs(title = "PACF – Tasa de desempleo")


ts %>%
  ACF(infl_mens) %>%
  autoplot() +
  labs(title = "ACF – Inflación mensual")

ts %>%
  PACF(infl_mens) %>%
  autoplot() +
  labs(title = "PACF – Inflación mensual")

ts %>%
  ACF(riesgo_pais) %>%
  autoplot() +
  labs(title = "ACF – Riesgo país")

ts %>%
  PACF(riesgo_pais) %>%
  autoplot() +
  labs(title = "PACF – Riesgo país")

ts %>%
  ACF(total_beneficiarios) %>%
  autoplot() +
  labs(title = "ACF – Beneficiarios")

ts %>%
  PACF(total_beneficiarios) %>%
  autoplot() +
  labs(title = "PACF – Beneficiarios")


##########CORRELACIONES
library(GGally)

ts_corr <- ts %>%
  select(
    total_pagos,
    tasa_desempleo,
    total_beneficiarios,
    infl_mens,
    riesgo_pais
  ) %>%
  as_tibble() %>%
  select(-mes)

GGally::ggpairs(
  ts_corr,
  lower = list(continuous = wrap("smooth", alpha = 0.6)),
  diag  = list(continuous = "densityDiag"),
  upper = list(continuous = "cor")
)

#justificacion para no usar pagos

ccf(ts$tasa_desempleo, ts$riesgo_pais, lag.max = 12)
ccf(ts$tasa_desempleo, ts$total_beneficiarios, lag.max = 12)


# ==========================================================
# 1) Split temporal Train/Test (80/20)
# ==========================================================
n <- nrow(ts)
h_test <- ceiling(0.2 * n)          # tamaño test
n_train <- n - h_test
fecha_corte <- ts %>% slice(n_train) %>% pull(mes)

train_ts <- ts %>% filter(mes <= fecha_corte)
test_ts  <- ts %>% filter(mes >  fecha_corte)

h_test <- nrow(test_ts)  # por seguridad

# ==========================================================
# 2) Función: ajustar ETS/ARIMA a una X y elegir mejor por RMSE
# ==========================================================


modelar_x <- function(train_ts, test_ts, varname, h_future = 6) {
  
  # =====================
  # TRAIN / TEST (solo la variable)
  # =====================
  train_x <- train_ts %>%
    select(mes, !!sym(varname)) %>%
    as_tsibble(index = mes)
  
  test_x <- test_ts %>%
    select(mes, !!sym(varname)) %>%
    as_tsibble(index = mes)
  
  h_test <- nrow(test_x)
  
  # =====================
  # AJUSTE DE MODELOS EN TRAIN
  # (ETS sin fórmula, ARIMA sin fórmula)
  # =====================
  fit_train <- train_x %>%
    model(
      ETS   = ETS(!!sym(varname)),
      ARIMA = ARIMA(!!sym(varname), stepwise = FALSE, approximation = FALSE)
    )
  
  # =====================
  # FORECAST EN TEST
  # =====================
  fc_test <- fit_train %>% forecast(h = h_test)
  acc_test <- fc_test %>% accuracy(test_x)
  
  # =====================
  # SELECCIÓN DEL MEJOR MODELO
  # =====================
  mejor_modelo <- acc_test %>%
    arrange(RMSE) %>%
    slice(1) %>%
    pull(.model)
  
  # =====================
  # REENTRENAR CON TRAIN + TEST (serie completa)
  # =====================
  full_x <- bind_rows(train_x, test_x) %>%
    as_tsibble(index = mes)
  
  fit_full <- full_x %>%
    model(
      ETS   = ETS(!!sym(varname)),
      ARIMA = ARIMA(!!sym(varname), stepwise = FALSE, approximation = FALSE)
    )
  
  # =====================
  # FORECAST FUTURO (h_future) usando el mejor modelo
  # =====================
  fc_future <- fit_full %>%
    forecast(h = h_future) %>%
    filter(.model == mejor_modelo) %>%
    as_tibble() %>%
    transmute(mes, .mean) %>%
    rename(!!varname := .mean)
  
  # =====================
  # Forecast TEST del mejor modelo (para new_data del ARIMAX)
  # =====================
  fc_test_best <- fc_test %>%
    filter(.model == mejor_modelo) %>%
    as_tibble() %>%
    transmute(mes, .mean) %>%
    rename(!!varname := .mean)
  
  # =====================
  # SALIDA
  # =====================
  list(
    var = varname,
    best_model = mejor_modelo,
    accuracy_test = acc_test,
    forecast_test = fc_test_best,
    forecast_future = fc_future,
    fit_train = fit_train,
    fit_full = fit_full
  )
}

# ==========================================================
# 3) Modelar cada X (Pagos, Beneficiarios, Inflación, Riesgo País)
# ==========================================================
h_future <- 6  # o 12, lo que pida tu proyecto

res_pagos <- modelar_x(train_ts, test_ts, "total_pagos", h_future)
res_ben   <- modelar_x(train_ts, test_ts, "total_beneficiarios", h_future)
res_inf   <- modelar_x(train_ts, test_ts, "infl_mens", h_future)
res_rp    <- modelar_x(train_ts, test_ts, "riesgo_pais", h_future)

sapply(list(res_pagos, res_ben, res_inf, res_rp), \(x) x$best_model)

res_pagos
# ==========================================================
# 4) new_data para TEST con X pronosticadas
# ==========================================================
newdata_test <- test_ts %>%
  select(mes) %>%
  left_join(res_ben$forecast_test,   by = "mes") %>%
  left_join(res_pagos$forecast_test, by = "mes") %>%
  left_join(res_inf$forecast_test,   by = "mes") %>%
  left_join(res_rp$forecast_test,    by = "mes") %>%
  as_tsibble(index = mes)

# Verificar que no haya NA en new_data
colSums(is.na(as_tibble(newdata_test)))

# ==========================================================
# 5) Modelo dinámico (ARIMAX) para Y = tasa_desempleo en TRAIN
# ==========================================================
fit_y_train <- train_ts %>%
  model(
    ARIMAX = ARIMA(
      tasa_desempleo ~
        total_beneficiarios +
        total_pagos +
        infl_mens +
        riesgo_pais +
        trend(),
      stepwise = FALSE,
      approximation = FALSE
    )
  )

report(fit_y_train)
fit_y_train %>% gg_tsresiduals()

# ==========================================================
# 6) Pronóstico de desempleo en TEST usando X pronosticadas
# ==========================================================
fc_y_test <- forecast(fit_y_train, new_data = newdata_test)

# Métricas en TEST (lo importante para elegir y justificar)
acc_y_test <- accuracy(fc_y_test, test_ts)
acc_y_test

# Gráfico de validación
autoplot(fc_y_test, test_ts) +
  labs(
    title = "Validación TEST – Pronóstico de tasa de desempleo (ARIMAX)",
    y = "Tasa de desempleo"
  )

# ==========================================================
# 7) new_data FUTURO (h_future) con X pronosticadas
# ==========================================================
# ts debe ser tu serie completa (datos_modelo como tsibble)
future_index <- ts %>%
  new_data(n = h_future) %>%
  select(mes)

newdata_future <- future_index %>%
  left_join(res_ben$forecast_future,   by = "mes") %>%
  left_join(res_pagos$forecast_future, by = "mes") %>%
  left_join(res_inf$forecast_future,   by = "mes") %>%
  left_join(res_rp$forecast_future,    by = "mes") %>%
  as_tsibble(index = mes)

colSums(is.na(as_tibble(newdata_future)))


# ==========================================================
# 8) Reentrenar ARIMAX con toda la data y pronosticar futuro
# ==========================================================
fit_y_full <- ts %>%
  model(
    ARIMAX = ARIMA(
      tasa_desempleo ~
        total_beneficiarios +
        total_pagos +
        infl_mens +
        riesgo_pais +
        trend(),
      stepwise = FALSE,
      approximation = FALSE
    )
  )

report(fit_y_full)

fc_y_future <- forecast(fit_y_full, new_data = newdata_future)

# Gráfico final: histórico + pronóstico futuro
autoplot(fc_y_future, ts) +
  labs(
    title = paste0("Pronóstico de tasa de desempleo – h = ", h_future, " meses"),
    y = "Tasa de desempleo"
  )

# (Opcional) tabla del pronóstico futuro
fc_y_future %>%
  as_tibble() %>%
  select(mes, .mean) %>%
  rename(pronostico_desempleo = .mean)



newdata_test_A <- test_ts %>%
  select(mes) %>%
  left_join(res_ben$forecast_test, by = "mes") %>%
  left_join(res_inf$forecast_test, by = "mes") %>%
  left_join(res_rp$forecast_test,  by = "mes") %>%
  as_tsibble(index = mes)

colSums(is.na(as_tibble(newdata_test_A)))

fit_y_train_A <- train_ts %>%
  model(
    ARIMAX = ARIMA(
      tasa_desempleo ~
        total_beneficiarios +
        infl_mens +
        riesgo_pais +
        trend(),
      stepwise = FALSE,
      approximation = FALSE
    )
  )

report(fit_y_train_A)
fit_y_train_A %>% gg_tsresiduals()

fc_y_test_A <- forecast(fit_y_train_A, new_data = newdata_test_A)

acc_y_test_A <- accuracy(fc_y_test_A, test_ts)
acc_y_test_A

autoplot(fc_y_test_A, test_ts) +
  labs(
    title = "Validación TEST – Tasa de desempleo (ARIMAX) sin pagos",
    y = "Tasa de desempleo"
  )

# Asegura que ts sea tu serie completa
ts <- datos_modelo %>%
  arrange(mes) %>%
  as_tsibble(index = mes)

future_index <- ts %>%
  new_data(n = h_future) %>%
  select(mes)

newdata_future_A <- future_index %>%
  left_join(res_ben$forecast_future, by = "mes") %>%
  left_join(res_inf$forecast_future, by = "mes") %>%
  left_join(res_rp$forecast_future,  by = "mes") %>%
  as_tsibble(index = mes)

colSums(is.na(as_tibble(newdata_future_A)))

fit_y_full_A <- ts %>%
  model(
    ARIMAX = ARIMA(
      tasa_desempleo ~
        total_beneficiarios +
        infl_mens +
        riesgo_pais +
        trend(),
      stepwise = FALSE,
      approximation = FALSE
    )
  )

report(fit_y_full_A)

fc_y_future_A <- forecast(fit_y_full_A, new_data = newdata_future_A)

autoplot(fc_y_future_A, ts) +
  labs(
    title = paste0("Pronóstico final de tasa de desempleo (sin pagos) – h = ", h_future, " meses"),
    y = "Tasa de desempleo"
  )

# Tabla final (por si la quieres en el informe)
tabla_pronostico <- fc_y_future_A %>%
  as_tibble() %>%
  select(mes, .mean) %>%
  rename(pronostico_desempleo = .mean)

tabla_pronostico


train_lag <- train_ts %>%
  mutate(
    ben_l1 = dplyr::lag(total_beneficiarios, 1),
    inf_l1 = dplyr::lag(infl_mens, 1),
    rp_l1  = dplyr::lag(riesgo_pais, 1)
  ) %>%
  drop_na()



fit_y_final <- train_lag %>%
  model(
    ARIMAX = ARIMA(
      tasa_desempleo ~ rp_l1,
      stepwise = FALSE,
      approximation = FALSE
    )
  )
report(fit_y_final)
bind_rows(
  glance(fit_y_train)     %>% mutate(modelo = "Completo"),
  glance(fit_y_train_A)   %>% mutate(modelo = "Sin pagos"),
  glance(fit_y_final)     %>% mutate(modelo = "Solo riesgo país (lag)")
) %>%
  select(modelo, AIC, BIC)


###########################################################
#### Contraste con el modelo simple sobre la tasa de desemplo


# 1. Leer correctamente el CSV (delimitado por ;)
tasa_de_desempleo_nacion <- read_delim(
  "tasa-de-desempleo-nacion.csv",
  delim = ";",
  col_types = cols(.default = "c")  # forzamos lectura como texto
)

# 2. Renombrar columnas
tasa_de_desempleo_nacion <- tasa_de_desempleo_nacion %>%
  rename(
    periodo = `Período`,
    tasa_desempleo = `Tasa de desempleo nacional en Porcentaje - Mensual`
  )

# 3. Corrección del separador decimal (PASO CLAVE)
tasa_de_desempleo_nacion <- tasa_de_desempleo_nacion %>%
  mutate(
    tasa_desempleo = tasa_desempleo %>%   # ← AQUÍ estaba el error
      str_replace(",", ".") %>%
      as.numeric()
  )

summary(tasa_de_desempleo_nacion$tasa_desempleo)

desempleo_ts <- tasa_de_desempleo_nacion %>%
  mutate(
    mes = yearmonth(as.Date(periodo))
  ) %>%
  select(mes, tasa_desempleo) %>%
  arrange(mes) %>%
  as_tsibble(index = mes)

desempleo_ts



desempleo_ts %>%
  autoplot(tasa_desempleo) +
  labs(
    title = "Tasa de desempleo mensual ",
    y = "Porcentaje (%)",
    x = "Mes"
  )


# Gráfico estacional

desempleo_ts %>%
  gg_season(tasa_desempleo) +
  labs(
    title = "Patrón estacional de la tasa de desempleo",
    x = "Mes del año",
    y = "Tasa de desempleo (%)"
  )

desempleo_ts %>%
  gg_subseries(tasa_desempleo) +
  labs(
    title = "Subseries estacionales de la tasa de desempleo",
    y = "Tasa de desempleo (%)"
  )


# Descomposición STL

desempleo_ts %>%
  model(
    stl = STL(tasa_desempleo)
  ) %>%
  components() %>%
  autoplot() +
  labs(
    title = "Descomposición STL de la tasa de desempleo"
  )

##ACF

desempleo_ts %>%
  ACF(tasa_desempleo) %>%
  autoplot() +
  labs(
    title = "Función de Autocorrelación (ACF)",
    y = "ACF"
  )


## PACF

desempleo_ts %>%
  PACF(tasa_desempleo) %>%
  autoplot() +
  labs(
    title = "Función de Autocorrelación Parcial (PACF)",
    y = "PACF"
  )


## Train - test

n_total <- nrow(desempleo_ts)
n_train <- floor(0.8 * n_total)

train_ts <- desempleo_ts %>% slice(1:n_train)
test_ts  <- desempleo_ts %>% slice((n_train + 1):n_total)

range(train_ts$mes)
range(test_ts$mes)

### Modelos clásicos
# Estimar Box-Cox

lambda_bc <- train_ts %>%
  features(tasa_desempleo, guerrero) %>%
  pull(lambda_guerrero)

lambda_bc

fits <- train_ts %>%
  model(
    tslm   = TSLM(tasa_desempleo ~ trend() + season()),
    ets    = ETS(tasa_desempleo),
    arima  = ARIMA(tasa_desempleo),
    arma   = ARIMA(tasa_desempleo ~ pdq(6,1,7)),
    sarima = ARIMA(tasa_desempleo ~ pdq(1,1,1) + PDQ(1,0,1))
  )


fits %>%
  select(tslm) %>%
  report()

fits %>%
  select(ets) %>%
  report()

fits %>%
  select(arima) %>%
  report()

fits %>%
  select(arma) %>%
  report()

fits %>%
  select(sarima) %>%
  report()


criterios_info <- fits %>%
  glance() %>%
  select(.model, AICc, BIC, log_lik)

criterios_info


fc_test <- fits %>%
  forecast(new_data = test_ts)


metricas_test <- fc_test %>%
  accuracy(test_ts) %>%
  select(.model, RMSE, MAE, MAPE, MASE)

metricas_test


ranking_modelos <- metricas_test %>%
  left_join(criterios_info, by = ".model") %>%
  arrange(RMSE)

ranking_modelos


fits %>%
  select(arima) %>%
  gg_tsresiduals()

fits %>%
  select(sarima) %>%
  gg_tsresiduals()



diagnostico_residuos <- fits %>%
  augment() %>%
  group_by(.model) %>%
  features(.innov, ljung_box, lag = 12)

diagnostico_residuos

fc_test %>%
  autoplot(train_ts, level = NULL) +
  autolayer(test_ts, tasa_desempleo, color = "black") +
  labs(
    title = "Comparación de pronósticos fuera de muestra",
    x = "Mes",
    y = "Tasa de desempleo (%)"
  )


#### fin
desempleo_ts %>% features(tasa_desempleo, unitroot_ndiffs)

desempleo_diff <- desempleo_ts %>%
  mutate(
    tasa_desempleo_diff = difference(tasa_desempleo)
  ) %>%
  filter(!is.na(tasa_desempleo_diff))


desempleo_diff %>%
  autoplot(tasa_desempleo_diff) +
  labs(
    title = "Tasa de desempleo diferenciada",
    y = "Δ Tasa de desempleo",
    x = "Mes"
  )


desempleo_diff %>%
  gg_tsdisplay(
    tasa_desempleo_diff,
    plot_type = "partial",
    lag_max = 24
  )

n_total <- nrow(desempleo_diff)
n_train <- floor(0.8 * n_total)

train_diff <- desempleo_diff %>% slice(1:n_train)
test_diff  <- desempleo_diff %>% slice((n_train + 1):n_total)


fits_diff <- train_diff %>%
  model(
    arima_manual = ARIMA(tasa_desempleo_diff ~ pdq(1,0,1)),
    sarima       = ARIMA(tasa_desempleo_diff ~ pdq(1,0,1) + PDQ(0,1,1)),
    ets          = ETS(tasa_desempleo_diff),
    tslm         = TSLM(tasa_desempleo_diff ~ trend())
  )



fc_diff <- fits_diff %>%
  forecast(new_data = test_diff)


metricas_diff <- accuracy(fc_diff, test_diff)

metricas_diff



fits_diff %>%
  select(arima_manual) %>%
  gg_tsresiduals()

fits_diff %>%
  select(ets) %>%
  gg_tsresiduals()


fits_diff %>%
  select(tslm) %>%
  gg_tsresiduals()


fits_diff %>%
  augment() %>%
  group_by(.model) %>%
  features(.innov, ljung_box, lag = 12)



desempleo_diff %>%
  ACF(tasa_desempleo_diff) %>%
  autoplot()

desempleo_diff %>%
  PACF(tasa_desempleo_diff) %>%
  autoplot()



fc_diff %>%
  autoplot(desempleo_diff) +
  labs(
    title = "Pronósticos sobre la serie diferenciada de la tasa de desempleo",
    y = "Δ Tasa de desempleo"
  )


modelo_final <- desempleo_diff %>%
  model(
    sarima_final = ARIMA(
      tasa_desempleo_diff ~
        pdq(1,0,1) +     # parte no estacional
        PDQ(0,1,1)       # parte estacional
    )
  )

# Descripción formal del modelo
modelo_final %>% report()


fc_6m_diff <- modelo_final %>%
  forecast(h = 6)

fc_6m_diff %>%
  autoplot(desempleo_diff) +
  labs(
    title = "Pronóstico sobre la serie diferenciada de la tasa de desempleo",
    subtitle = "Modelo SARIMA (horizonte: 6 meses)",
    x = "Mes",
    y = expression(Delta~"Tasa de desempleo")
  ) +
  theme_minimal()


ultimo_valor <- desempleo_ts %>%
  arrange(desc(mes)) %>%
  slice(1) %>%
  pull(tasa_desempleo)


predicciones_6m <- fc_6m_diff %>%
  as_tibble() %>%
  mutate(
    tasa_desempleo_pred = ultimo_valor + cumsum(.mean)
  ) %>%
  select(mes, tasa_desempleo_pred)

predicciones_6m


library(ggplot2)

ggplot() +
  geom_line(
    data = desempleo_ts,
    aes(x = mes, y = tasa_desempleo),
    color = "black",
    linewidth = 0.8
  ) +
  geom_line(
    data = predicciones_6m,
    aes(x = mes, y = tasa_desempleo_pred),
    color = "blue",
    linewidth = 1
  ) +
  labs(
    title = "Pronóstico de la tasa de desempleo (6 meses)",
    subtitle = "Modelo SARIMA aplicado a la serie diferenciada",
    x = "Mes",
    y = "Tasa de desempleo (%)"
  ) +
  theme_minimal()




