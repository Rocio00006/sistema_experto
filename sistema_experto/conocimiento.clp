;;; ============================================================
;;; SISTEMA EXPERTO - RECOMENDACION DE SMARTPHONES
;;; Universidad Católica de Santa María - Sistemas Inteligentes
;;; Motor: CLIPS 6.4
;;; ============================================================

;;; ============================================================
;;; TEMPLATES (Plantillas de hechos estructurados)
;;; ============================================================

(deftemplate usuario
  (slot nombre (type STRING) (default "Anonimo"))
  (slot edad (type INTEGER) (default 25))
  (slot presupuesto-min (type FLOAT) (default 0.0))
  (slot presupuesto-max (type FLOAT) (default 9999.0))
  (slot uso-principal (type SYMBOL)
    (allowed-values gaming fotografia trabajo redes-sociales llamadas multimedia desconocido))
  (slot preferencia-marca (type SYMBOL)
    (allowed-values Samsung Apple Xiaomi Motorola Sony Huawei cualquiera))
  (slot sistema-operativo (type SYMBOL)
    (allowed-values Android iOS indiferente))
  (slot prioridad-bateria (type SYMBOL) (allowed-values alta media baja))
  (slot prioridad-camara (type SYMBOL) (allowed-values alta media baja))
  (slot prioridad-rendimiento (type SYMBOL) (allowed-values alta media baja))
  (slot compras-previas (type STRING) (default ""))
  (slot valoracion-anterior (type FLOAT) (default 3.0))
  (slot perfil-validado (type SYMBOL) (allowed-values si no) (default no))
)

(deftemplate smartphone
  (slot id (type SYMBOL))
  (slot nombre (type STRING))
  (slot marca (type SYMBOL)
    (allowed-values Samsung Apple Xiaomi Motorola Sony Huawei))
  (slot precio (type FLOAT))
  (slot sistema-operativo (type SYMBOL) (allowed-values Android iOS))
  (slot ram-gb (type INTEGER))
  (slot almacenamiento-gb (type INTEGER))
  (slot camara-mp (type INTEGER))
  (slot bateria-mah (type INTEGER))
  (slot refresh-rate (type INTEGER))
  (slot procesador-score (type INTEGER))   ; benchmark normalizado 1-100
  (slot tiene-5g (type SYMBOL) (allowed-values si no))
  (slot carga-rapida (type SYMBOL) (allowed-values si no))
  (slot disponible (type SYMBOL) (allowed-values si no) (default si))
  (slot descuento-pct (type FLOAT) (default 0.0))
)

(deftemplate recomendacion
  (slot smartphone-id (type SYMBOL))
  (slot puntaje (type FLOAT) (default 0.0))
  (slot nivel (type SYMBOL) (allowed-values principal alternativa descartado))
  (slot justificacion (type STRING) (default ""))
)

(deftemplate historial-compra
  (slot marca (type SYMBOL))
  (slot valoracion (type FLOAT))
)

(deftemplate error-validacion
  (slot campo (type STRING))
  (slot mensaje (type STRING))
)

(deftemplate feedback
  (slot smartphone-id (type SYMBOL))
  (slot satisfaccion (type INTEGER))   ; 1-5
  (slot comentario (type STRING) (default ""))
)

(deftemplate sesion
  (slot fase (type SYMBOL)
    (allowed-values inicio validacion inferencia resultado feedback finalizado))
  (slot recomendaciones-generadas (type INTEGER) (default 0))
)

;;; ============================================================
;;; HECHOS INICIALES - Catálogo de smartphones
;;; ============================================================

(deffacts catalogo-smartphones
  ;; --- GAMA BAJA (hasta S/ 800) ---
  (smartphone
    (id moto-g54)
    (nombre "Motorola Moto G54 5G")
    (marca Motorola)
    (precio 549.0)
    (sistema-operativo Android)
    (ram-gb 8) (almacenamiento-gb 128)
    (camara-mp 50) (bateria-mah 5000)
    (refresh-rate 120) (procesador-score 45)
    (tiene-5g si) (carga-rapida si)
    (disponible si) (descuento-pct 5.0)
  )
  (smartphone
    (id xiaomi-redmi-13)
    (nombre "Xiaomi Redmi 13")
    (marca Xiaomi)
    (precio 499.0)
    (sistema-operativo Android)
    (ram-gb 6) (almacenamiento-gb 128)
    (camara-mp 108) (bateria-mah 5000)
    (refresh-rate 90) (procesador-score 40)
    (tiene-5g no) (carga-rapida si)
    (disponible si) (descuento-pct 10.0)
  )
  (smartphone
    (id samsung-a15)
    (nombre "Samsung Galaxy A15")
    (marca Samsung)
    (precio 699.0)
    (sistema-operativo Android)
    (ram-gb 4) (almacenamiento-gb 128)
    (camara-mp 50) (bateria-mah 5000)
    (refresh-rate 90) (procesador-score 42)
    (tiene-5g no) (carga-rapida no)
    (disponible si) (descuento-pct 0.0)
  )

  ;; --- GAMA MEDIA (S/ 800 - S/ 2000) ---
  (smartphone
    (id samsung-a55)
    (nombre "Samsung Galaxy A55 5G")
    (marca Samsung)
    (precio 1399.0)
    (sistema-operativo Android)
    (ram-gb 8) (almacenamiento-gb 256)
    (camara-mp 50) (bateria-mah 5000)
    (refresh-rate 120) (procesador-score 65)
    (tiene-5g si) (carga-rapida si)
    (disponible si) (descuento-pct 8.0)
  )
  (smartphone
    (id xiaomi-poco-x6)
    (nombre "Xiaomi POCO X6 Pro")
    (marca Xiaomi)
    (precio 1199.0)
    (sistema-operativo Android)
    (ram-gb 12) (almacenamiento-gb 256)
    (camara-mp 64) (bateria-mah 5100)
    (refresh-rate 144) (procesador-score 72)
    (tiene-5g si) (carga-rapida si)
    (disponible si) (descuento-pct 15.0)
  )
  (smartphone
    (id motorola-edge-50)
    (nombre "Motorola Edge 50 Fusion")
    (marca Motorola)
    (precio 1099.0)
    (sistema-operativo Android)
    (ram-gb 8) (almacenamiento-gb 256)
    (camara-mp 50) (bateria-mah 5000)
    (refresh-rate 144) (procesador-score 63)
    (tiene-5g si) (carga-rapida si)
    (disponible si) (descuento-pct 0.0)
  )

  ;; --- GAMA ALTA (S/ 2000 - S/ 4000) ---
  (smartphone
    (id samsung-s24)
    (nombre "Samsung Galaxy S24")
    (marca Samsung)
    (precio 3299.0)
    (sistema-operativo Android)
    (ram-gb 8) (almacenamiento-gb 256)
    (camara-mp 50) (bateria-mah 4000)
    (refresh-rate 120) (procesador-score 90)
    (tiene-5g si) (carga-rapida si)
    (disponible si) (descuento-pct 5.0)
  )
  (smartphone
    (id xiaomi-14)
    (nombre "Xiaomi 14")
    (marca Xiaomi)
    (precio 2899.0)
    (sistema-operativo Android)
    (ram-gb 12) (almacenamiento-gb 512)
    (camara-mp 50) (bateria-mah 4610)
    (refresh-rate 120) (procesador-score 92)
    (tiene-5g si) (carga-rapida si)
    (disponible si) (descuento-pct 0.0)
  )

  ;; --- GAMA PREMIUM (S/ 4000+) ---
  (smartphone
    (id iphone-16)
    (nombre "Apple iPhone 16")
    (marca Apple)
    (precio 4599.0)
    (sistema-operativo iOS)
    (ram-gb 8) (almacenamiento-gb 128)
    (camara-mp 48) (bateria-mah 3561)
    (refresh-rate 60) (procesador-score 97)
    (tiene-5g si) (carga-rapida si)
    (disponible si) (descuento-pct 0.0)
  )
  (smartphone
    (id iphone-16-pro)
    (nombre "Apple iPhone 16 Pro")
    (marca Apple)
    (precio 5899.0)
    (sistema-operativo iOS)
    (ram-gb 8) (almacenamiento-gb 256)
    (camara-mp 48) (bateria-mah 3582)
    (refresh-rate 120) (procesador-score 99)
    (tiene-5g si) (carga-rapida si)
    (disponible si) (descuento-pct 0.0)
  )
  (smartphone
    (id samsung-s24-ultra)
    (nombre "Samsung Galaxy S24 Ultra")
    (marca Samsung)
    (precio 5499.0)
    (sistema-operativo Android)
    (ram-gb 12) (almacenamiento-gb 256)
    (camara-mp 200) (bateria-mah 5000)
    (refresh-rate 120) (procesador-score 95)
    (tiene-5g si) (carga-rapida si)
    (disponible si) (descuento-pct 10.0)
  )
)

(deffacts estado-inicial
  (sesion (fase inicio) (recomendaciones-generadas 0))
)

;;; ============================================================
;;; REGLAS DE VALIDACION (R1-R7)
;;; ============================================================

(defrule R1-validar-presupuesto
  "Verifica que el rango de presupuesto sea coherente"
  (usuario (presupuesto-min ?min) (presupuesto-max ?max) (perfil-validado no))
  (test (> ?min ?max))
  =>
  (assert (error-validacion
    (campo "presupuesto")
    (mensaje "El presupuesto mínimo no puede ser mayor al máximo")))
  (printout t "ERROR: Presupuesto inválido - mínimo > máximo" crlf)
)

(defrule R2-validar-edad
  "Verifica que la edad esté en rango razonable"
  (usuario (edad ?edad) (perfil-validado no))
  (test (or (< ?edad 12) (> ?edad 100)))
  =>
  (assert (error-validacion
    (campo "edad")
    (mensaje "La edad debe estar entre 12 y 100 años")))
  (printout t "ERROR: Edad fuera de rango" crlf)
)

(defrule R3-validar-valoracion-anterior
  "Verifica que la valoración anterior esté entre 1 y 5"
  (usuario (valoracion-anterior ?val) (perfil-validado no))
  (test (or (< ?val 1.0) (> ?val 5.0)))
  =>
  (assert (error-validacion
    (campo "valoracion-anterior")
    (mensaje "La valoración debe estar entre 1.0 y 5.0")))
  (printout t "ERROR: Valoración fuera de rango" crlf)
)

(defrule R4-perfil-valido-sin-errores
  "Marca el perfil como validado si no hay errores"
  ?u <- (usuario (perfil-validado no))
  (not (error-validacion))
  =>
  (modify ?u (perfil-validado si))
  (printout t ">> Perfil validado correctamente." crlf)
)

(defrule R5-bloquear-inferencia-si-hay-errores
  "Detiene la inferencia si hay errores de validación pendientes"
  (error-validacion (campo ?campo) (mensaje ?msg))
  (sesion (fase inicio))
  =>
  (printout t "SISTEMA: No se puede continuar. Error en campo [" ?campo "]: " ?msg crlf)
)

(defrule R6-validar-presupuesto-minimo-razonable
  "Advierte si el presupuesto máximo es muy bajo para cualquier smartphone"
  (usuario (presupuesto-max ?max) (perfil-validado no))
  (test (< ?max 400.0))
  =>
  (assert (error-validacion
    (campo "presupuesto-max")
    (mensaje "El presupuesto es muy bajo. El mínimo disponible en catálogo es S/499")))
)

(defrule R7-inferir-prioridades-por-uso
  "Si el usuario no especificó prioridades, las infiere del uso principal"
  ?u <- (usuario
    (uso-principal ?uso)
    (prioridad-camara baja)
    (prioridad-bateria baja)
    (prioridad-rendimiento baja)
    (perfil-validado si))
  (test (neq ?uso desconocido))
  =>
  (if (eq ?uso fotografia)
    then (modify ?u (prioridad-camara alta) (prioridad-rendimiento media) (prioridad-bateria media))
  )
  (if (eq ?uso gaming)
    then (modify ?u (prioridad-rendimiento alta) (prioridad-camara baja) (prioridad-bateria alta))
  )
  (if (eq ?uso trabajo)
    then (modify ?u (prioridad-rendimiento alta) (prioridad-bateria alta) (prioridad-camara media))
  )
  (if (or (eq ?uso redes-sociales) (eq ?uso multimedia))
    then (modify ?u (prioridad-camara alta) (prioridad-bateria media) (prioridad-rendimiento media))
  )
  (if (eq ?uso llamadas)
    then (modify ?u (prioridad-bateria alta) (prioridad-camara baja) (prioridad-rendimiento baja))
  )
  (printout t ">> Prioridades inferidas para uso: " ?uso crlf)
)

;;; ============================================================
;;; REGLAS DE FILTRADO POR PRESUPUESTO (R8-R10)
;;; ============================================================

(defrule R8-filtrar-por-presupuesto
  "Descarta smartphones fuera del rango de presupuesto"
  (usuario (presupuesto-min ?min) (presupuesto-max ?max) (perfil-validado si))
  (smartphone (id ?id) (precio ?precio) (nombre ?nombre))
  (test (or (< ?precio ?min) (> ?precio ?max)))
  (not (recomendacion (smartphone-id ?id)))
  =>
  (assert (recomendacion
    (smartphone-id ?id)
    (puntaje 0.0)
    (nivel descartado)
    (justificacion (str-cat "Precio S/" ?precio " fuera del rango S/" ?min "-" ?max))))
)

(defrule R9-filtrar-por-sistema-operativo
  "Descarta smartphones con SO incompatible si el usuario tiene preferencia"
  (usuario (sistema-operativo ?so-pref) (perfil-validado si))
  (smartphone (id ?id) (sistema-operativo ?so-prod) (nombre ?nombre))
  (test (and (neq ?so-pref indiferente) (neq ?so-pref ?so-prod)))
  (not (recomendacion (smartphone-id ?id)))
  =>
  (assert (recomendacion
    (smartphone-id ?id)
    (puntaje 0.0)
    (nivel descartado)
    (justificacion (str-cat "SO " ?so-prod " no coincide con preferencia " ?so-pref))))
)

(defrule R10-filtrar-por-disponibilidad
  "Descarta smartphones sin stock"
  (usuario (perfil-validado si))
  (smartphone (id ?id) (disponible no) (nombre ?nombre))
  (not (recomendacion (smartphone-id ?id)))
  =>
  (assert (recomendacion
    (smartphone-id ?id)
    (puntaje 0.0)
    (nivel descartado)
    (justificacion "Producto sin stock disponible")))
)

;;; ============================================================
;;; REGLAS DE PUNTUACION BASE (R11-R20)
;;; ============================================================

(defrule R11-puntaje-base-candidatos
  "Asigna puntaje base 50 a todos los candidatos válidos"
  (usuario (perfil-validado si)
    (presupuesto-min ?min) (presupuesto-max ?max)
    (sistema-operativo ?so-pref))
  (smartphone (id ?id) (precio ?precio) (sistema-operativo ?so-prod) (disponible si))
  (test (and (>= ?precio ?min) (<= ?precio ?max)))
  (test (or (eq ?so-pref indiferente) (eq ?so-pref ?so-prod)))
  (not (recomendacion (smartphone-id ?id)))
  =>
  (assert (recomendacion
    (smartphone-id ?id)
    (puntaje 50.0)
    (nivel alternativa)
    (justificacion "Candidato válido - evaluando criterios")))
)

(defrule R12-bonus-prioridad-camara-alta
  "Añade puntos si la cámara es prioridad alta y el teléfono tiene buena cámara"
  (usuario (prioridad-camara alta) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (camara-mp ?mp))
  (test (neq ?n descartado))
  (test (>= ?mp 64))
  =>
  (modify ?rec (puntaje (+ ?p 15.0))
    (justificacion (str-cat "Cámara " ?mp "MP excelente para fotografía")))
)

(defrule R13-bonus-prioridad-bateria-alta
  "Añade puntos si la batería es prioridad alta y el teléfono tiene buena batería"
  (usuario (prioridad-bateria alta) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (bateria-mah ?bat))
  (test (neq ?n descartado))
  (test (>= ?bat 5000))
  =>
  (modify ?rec (puntaje (+ ?p 12.0))
    (justificacion (str-cat "Batería " ?bat "mAh ideal para uso intensivo")))
)

(defrule R14-bonus-prioridad-rendimiento-alta
  "Añade puntos si el rendimiento es prioridad alta"
  (usuario (prioridad-rendimiento alta) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (procesador-score ?score) (ram-gb ?ram))
  (test (neq ?n descartado))
  (test (and (>= ?score 65) (>= ?ram 8)))
  =>
  (modify ?rec (puntaje (+ ?p 15.0))
    (justificacion (str-cat "Alto rendimiento: score=" ?score " RAM=" ?ram "GB")))
)

(defrule R15-bonus-gaming-refresh-alto
  "Bonus extra para gaming si tiene refresh rate alto"
  (usuario (uso-principal gaming) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (refresh-rate ?hz))
  (test (neq ?n descartado))
  (test (>= ?hz 120))
  =>
  (modify ?rec (puntaje (+ ?p 10.0))
    (justificacion (str-cat "Pantalla " ?hz "Hz óptima para gaming")))
)

(defrule R16-bonus-oferta-destacada
  "Añade puntos si hay descuento significativo"
  (usuario (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (descuento-pct ?desc))
  (test (neq ?n descartado))
  (test (>= ?desc 10.0))
  =>
  (modify ?rec (puntaje (+ ?p 8.0))
    (justificacion (str-cat "Oferta: " ?desc "% de descuento")))
)

(defrule R17-bonus-preferencia-marca
  "Añade puntos si el teléfono coincide con la preferencia de marca"
  (usuario (preferencia-marca ?marca-pref) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (marca ?marca-prod))
  (test (neq ?n descartado))
  (test (and (neq ?marca-pref cualquiera) (eq ?marca-pref ?marca-prod)))
  =>
  (modify ?rec (puntaje (+ ?p 10.0))
    (justificacion "Coincide con tu marca preferida"))
)

(defrule R18-bonus-historial-positivo
  "Añade puntos si el usuario tuvo buena experiencia con esta marca"
  (usuario (valoracion-anterior ?val) (compras-previas ?hist) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (marca ?marca))
  (test (neq ?n descartado))
  (test (>= ?val 4.0))
  (test (str-index (str-cat ?marca) ?hist))
  =>
  (modify ?rec (puntaje (+ ?p 8.0))
    (justificacion "Marca con experiencia previa positiva"))
)

(defrule R19-penalizacion-historial-negativo
  "Resta puntos si el usuario tuvo mala experiencia con esta marca"
  (usuario (valoracion-anterior ?val) (compras-previas ?hist) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (marca ?marca))
  (test (neq ?n descartado))
  (test (< ?val 3.0))
  (test (str-index (str-cat ?marca) ?hist))
  =>
  (modify ?rec (puntaje (- ?p 15.0))
    (justificacion "Marca con experiencia previa negativa"))
)

(defrule R20-bonus-5g-trabajo
  "Añade puntos si el uso es trabajo y el teléfono tiene 5G"
  (usuario (uso-principal trabajo) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (tiene-5g si))
  (test (neq ?n descartado))
  =>
  (modify ?rec (puntaje (+ ?p 7.0))
    (justificacion "Conectividad 5G para mayor productividad"))
)

;;; ============================================================
;;; REGLAS DE CLASIFICACION FINAL (R21-R28)
;;; ============================================================

(defrule R21-clasificar-principal
  "Clasifica como recomendación principal si puntaje >= 80"
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel alternativa))
  (test (>= ?p 80.0))
  =>
  (modify ?rec (nivel principal))
  (printout t ">> Recomendacion PRINCIPAL: " ?id " (puntaje=" ?p ")" crlf)
)

(defrule R22-clasificar-alternativa
  "Mantiene como alternativa si puntaje está entre 60 y 79"
  (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel alternativa))
  (test (and (>= ?p 60.0) (< ?p 80.0)))
  =>
  (printout t ">> Recomendacion ALTERNATIVA: " ?id " (puntaje=" ?p ")" crlf)
)

(defrule R23-bonus-joven-fotografia
  "Los usuarios jóvenes con interés en redes reciben bonus de cámara frontal implícita"
  (usuario (edad ?edad) (uso-principal redes-sociales) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (camara-mp ?mp))
  (test (neq ?n descartado))
  (test (< ?edad 25))
  (test (>= ?mp 50))
  =>
  (modify ?rec (puntaje (+ ?p 5.0))
    (justificacion "Cámara adecuada para contenido en redes sociales"))
)

(defrule R24-bonus-carga-rapida-si-bateria-prioridad
  "Bonus por carga rápida cuando la batería es prioridad"
  (usuario (prioridad-bateria alta) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (carga-rapida si))
  (test (neq ?n descartado))
  =>
  (modify ?rec (puntaje (+ ?p 5.0))
    (justificacion "Carga rápida disponible"))
)

(defrule R25-penalizacion-sin-carga-rapida-bateria-alta
  "Penaliza si batería es prioridad pero no tiene carga rápida"
  (usuario (prioridad-bateria alta) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (carga-rapida no))
  (test (neq ?n descartado))
  =>
  (modify ?rec (puntaje (- ?p 5.0))
    (justificacion "Sin carga rápida - puede ser limitante"))
)

(defrule R26-bonus-almacenamiento-alto-multimedia
  "Bonus si uso es multimedia y tiene almacenamiento >= 256GB"
  (usuario (uso-principal multimedia) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (almacenamiento-gb ?gb))
  (test (neq ?n descartado))
  (test (>= ?gb 256))
  =>
  (modify ?rec (puntaje (+ ?p 8.0))
    (justificacion (str-cat "Almacenamiento " ?gb "GB ideal para multimedia")))
)

(defrule R27-penalizacion-ram-baja-gaming
  "Penaliza si el uso es gaming pero la RAM es menor a 8GB"
  (usuario (uso-principal gaming) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (ram-gb ?ram))
  (test (neq ?n descartado))
  (test (< ?ram 8))
  =>
  (modify ?rec (puntaje (- ?p 20.0))
    (justificacion (str-cat "RAM insuficiente (" ?ram "GB) para gaming")))
)

(defrule R28-ajuste-por-feedback-negativo
  "Reduce el puntaje de smartphones similares si hubo feedback negativo reciente"
  (feedback (smartphone-id ?fid) (satisfaccion ?sat))
  (smartphone (id ?fid) (marca ?marca-mala))
  (test (< ?sat 3))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (marca ?marca-mala))
  (test (neq ?n descartado))
  (test (neq ?id ?fid))
  =>
  (modify ?rec (puntaje (- ?p 10.0))
    (justificacion "Ajustado por feedback negativo de marca similar"))
)

;;; ============================================================
;;; REGLAS DE SALIDA Y REPORTE (R29-R35)
;;; ============================================================

(defrule R29-contar-recomendaciones
  "Actualiza el contador de recomendaciones generadas"
  ?ses <- (sesion (fase inferencia) (recomendaciones-generadas ?n))
  (recomendacion (nivel principal))
  =>
  (modify ?ses (recomendaciones-generadas (+ ?n 1)))
)

(defrule R30-sin-recomendaciones-principales
  "Si no hay ninguna recomendación principal, baja el umbral a 65"
  (sesion (fase inferencia))
  (not (recomendacion (nivel principal)))
  ?rec <- (recomendacion (puntaje ?p) (nivel alternativa))
  (test (>= ?p 65.0))
  =>
  (modify ?rec (nivel principal))
  (printout t ">> Umbral relajado - promoviendo mejor alternativa disponible" crlf)
)

(defrule R31-reporte-recomendacion-principal
  "Muestra en consola las recomendaciones principales"
  (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel principal))
  (smartphone (id ?id) (nombre ?nombre) (precio ?precio) (marca ?marca) (descuento-pct ?desc))
  =>
  (printout t "=== RECOMENDACION PRINCIPAL ===" crlf)
  (printout t "  Modelo: " ?nombre crlf)
  (printout t "  Marca : " ?marca crlf)
  (printout t "  Precio: S/" ?precio crlf)
  (if (> ?desc 0.0)
    then (printout t "  Oferta: " ?desc "% descuento" crlf)
  )
  (printout t "  Score : " ?p "/100" crlf)
  (printout t "==============================" crlf)
)

(defrule R32-reporte-alternativa
  "Muestra las alternativas"
  (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel alternativa))
  (smartphone (id ?id) (nombre ?nombre) (precio ?precio))
  =>
  (printout t "-- Alternativa: " ?nombre " | S/" ?precio " | Score: " ?p crlf)
)

(defrule R33-sugerir-accesorio-por-ecosistema
  "Si recomienda un iPhone, sugiere el ecosistema Apple"
  (recomendacion (smartphone-id ?id) (nivel principal))
  (smartphone (id ?id) (marca Apple))
  =>
  (printout t ">> Accesorios recomendados: AirPods, Apple Watch, MagSafe" crlf)
)

(defrule R34-sugerir-accesorio-samsung
  "Si recomienda Samsung, sugiere accesorios Galaxy"
  (recomendacion (smartphone-id ?id) (nivel principal))
  (smartphone (id ?id) (marca Samsung))
  =>
  (printout t ">> Accesorios recomendados: Galaxy Buds, Galaxy Watch, cargador inalámbrico" crlf)
)

(defrule R35-fin-sesion
  "Registra el fin del proceso de recomendación"
  ?ses <- (sesion (fase inferencia))
  (not (recomendacion (nivel alternativa)))
  =>
  (modify ?ses (fase resultado))
  (printout t ">> Proceso de recomendación completado." crlf)
)

;;; ============================================================
;;; REGLAS COMPLEMENTARIAS (R36-R42)
;;; ============================================================

(defrule R36-bonus-relacion-precio-calidad
  "Bonus para teléfonos con buen score/precio"
  (usuario (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (procesador-score ?score) (precio ?precio))
  (test (neq ?n descartado))
  (test (> (/ ?score ?precio) 0.05))
  =>
  (modify ?rec (puntaje (+ ?p 6.0))
    (justificacion "Excelente relación rendimiento/precio"))
)

(defrule R37-penalizacion-precio-alto-presupuesto-bajo
  "Penaliza si el precio supera el 90% del presupuesto máximo en gama baja"
  (usuario (presupuesto-max ?max) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (precio ?precio))
  (test (neq ?n descartado))
  (test (and (< ?max 1000.0) (> ?precio (* ?max 0.9))))
  =>
  (modify ?rec (puntaje (- ?p 8.0))
    (justificacion "Precio al límite del presupuesto"))
)

(defrule R38-bonus-mayor-adulto-bateria
  "Usuarios mayores de 50 priorizan batería y pantalla grande"
  (usuario (edad ?edad) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (bateria-mah ?bat))
  (test (neq ?n descartado))
  (test (> ?edad 50))
  (test (>= ?bat 4500))
  =>
  (modify ?rec (puntaje (+ ?p 8.0))
    (justificacion "Batería duradera recomendada para usuarios maduros"))
)

(defrule R39-xiaomi-budget-bonus
  "Xiaomi tiene mejor relación calidad-precio en gama baja"
  (usuario (presupuesto-max ?max) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (marca Xiaomi) (precio ?precio))
  (test (neq ?n descartado))
  (test (and (< ?max 1500.0) (< ?precio 1200.0)))
  =>
  (modify ?rec (puntaje (+ ?p 5.0))
    (justificacion "Xiaomi destaca en calidad-precio gama media-baja"))
)

(defrule R40-apple-ecosistema-conocido
  "Bonus para Apple si el usuario ya usó iOS"
  (usuario (sistema-operativo iOS) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (marca Apple))
  (test (neq ?n descartado))
  =>
  (modify ?rec (puntaje (+ ?p 7.0))
    (justificacion "Continuidad con ecosistema iOS ya conocido"))
)

(defrule R41-samsung-marca-confiable
  "Samsung bonus por ser marca con amplio soporte técnico en Perú"
  (usuario (uso-principal trabajo) (perfil-validado si))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (marca Samsung))
  (test (neq ?n descartado))
  =>
  (modify ?rec (puntaje (+ ?p 5.0))
    (justificacion "Samsung con amplio soporte técnico local"))
)

(defrule R42-feedback-positivo-boost
  "Si el usuario dio feedback positivo de una marca, la boostea"
  (feedback (smartphone-id ?fid) (satisfaccion ?sat))
  (smartphone (id ?fid) (marca ?marca-buena))
  (test (>= ?sat 4))
  ?rec <- (recomendacion (smartphone-id ?id) (puntaje ?p) (nivel ?n))
  (smartphone (id ?id) (marca ?marca-buena))
  (test (neq ?n descartado))
  (test (neq ?id ?fid))
  =>
  (modify ?rec (puntaje (+ ?p 10.0))
    (justificacion "Boost por feedback positivo de marca previamente usada"))
)
