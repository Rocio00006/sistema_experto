# 📱 SmartExpert — Sistema Experto de Recomendación de Smartphones

> Proyecto Final · Laboratorio de Sistemas Inteligentes · UCSM 2025-1

## Descripción

Sistema experto desarrollado en **CLIPS 6.4** con interfaz web (Python/Flask + HTML/JS) que recomienda smartphones personalizados según el perfil del usuario: presupuesto, uso principal, preferencias de marca, historial de compras y feedback.

## Equipo

- [Nombre 1]
- [Nombre 2]
- [Nombre 3]
- [Nombre 4]
- [Nombre 5]

---

## Estructura del proyecto

```
sistema_experto/
├── conocimiento.clp     # Base de conocimiento CLIPS (42 reglas + hechos)
├── app.py               # Backend Flask + conector clipspy
├── index.html           # Interfaz de usuario web
├── requirements.txt     # Dependencias Python
└── README.md
```

---

## Instalación y ejecución

### 1. Requisitos

- Python 3.8+
- pip

### 2. Instalar dependencias

```bash
pip install -r requirements.txt
```

### 3. Ejecutar el servidor

```bash
python app.py
```

### 4. Abrir la interfaz

Abre `index.html` en tu navegador (doble clic o con Live Server en VSCode).

> El backend corre en `http://localhost:5000`

---

## Base de conocimiento

### Templates (plantillas de hechos)

| Template | Descripción |
|---|---|
| `usuario` | Perfil completo del usuario |
| `smartphone` | Catálogo de productos |
| `recomendacion` | Resultado con puntaje y nivel |
| `historial-compra` | Compras previas del usuario |
| `error-validacion` | Errores de entrada de datos |
| `feedback` | Retroalimentación del usuario |
| `sesion` | Estado de la sesión activa |

### Distribución de las 42 reglas

| Categoría | Reglas | Descripción |
|---|---|---|
| Validación | R1–R7 | Verificación de datos de entrada |
| Filtrado | R8–R10 | Descarte por presupuesto, SO, disponibilidad |
| Puntuación base | R11 | Candidatos válidos reciben puntaje 50 |
| Bonus positivos | R12–R20, R23–R24, R26 | Incrementos por criterios |
| Penalizaciones | R19, R25, R27, R37 | Decrementos por criterios negativos |
| Clasificación | R21–R22, R30 | Principal (≥80) / Alternativa (≥60) |
| Salida | R31–R35 | Reportes y sugerencias de accesorios |
| Complementarias | R36–R42 | Relación precio/calidad, ecosistemas, feedback |

### Catálogo de smartphones (11 modelos)

| Gama | Rango | Modelos |
|---|---|---|
| Baja | S/499–S/799 | Xiaomi Redmi 13, Motorola G54, Samsung A15 |
| Media | S/800–S/2000 | Samsung A55, POCO X6 Pro, Motorola Edge 50 |
| Alta | S/2001–S/4000 | Samsung S24, Xiaomi 14 |
| Premium | S/4000+ | iPhone 16, iPhone 16 Pro, Samsung S24 Ultra |

---

## API REST

### `POST /api/recomendar`

**Body:**
```json
{
  "nombre": "Carlos",
  "edad": 22,
  "presupuesto_min": 800,
  "presupuesto_max": 1500,
  "uso_principal": "gaming",
  "preferencia_marca": "cualquiera",
  "sistema_operativo": "Android",
  "prioridad_camara": "baja",
  "prioridad_bateria": "baja",
  "prioridad_rendimiento": "baja",
  "compras_previas": "Xiaomi",
  "valoracion_anterior": 4.5
}
```

**Respuesta:**
```json
{
  "estado": "ok",
  "recomendaciones": {
    "principales": [...],
    "alternativas": [...]
  }
}
```

### `GET /api/catalogo`

Devuelve el catálogo completo de smartphones.

### `GET /api/health`

Estado del servidor.

---

## Tecnologías

- **CLIPS 6.4** — Motor de inferencia (encadenamiento hacia adelante)
- **clipspy** — Binding Python para CLIPS
- **Flask** — API REST
- **HTML/CSS/JavaScript** — Interfaz de usuario
- **GitHub** — Control de versiones

---

## Referencias

- Smith, J. (2023). *Introduction to Prolog Programming*. Artificial Intelligence Hub.
- Hayes-Roth, F. (Ed.). *Readings in Artificial Intelligence*. Morgan Kaufmann.
- McDermott, D. (1982). A Critique of Pure Reason. *Computational Intelligence*, 1(1), 46–61.
- CLIPS Reference Manual: https://www.clipsrules.net/
