"""
Sistema Experto - Recomendación de Smartphones
Backend Flask + CLIPS (clipspy)
Universidad Católica de Santa María - Sistemas Inteligentes 2025-1
"""

import os
import clips
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CLIPS_FILE = os.path.join(BASE_DIR, "conocimiento.clp")


def crear_entorno():
    """Crea y carga un entorno CLIPS limpio con deffacts activados."""
    env = clips.Environment()
    env.load(CLIPS_FILE)
    env.reset()   # activa los deffacts (catálogo de smartphones)
    return env


def afirmar_usuario(env, datos):
    """Construye y afirma el hecho usuario en CLIPS."""
    compras = datos.get("compras_previas", "")
    env.eval(f"""
        (assert (usuario
            (nombre "{datos.get('nombre', 'Usuario')}")
            (edad {datos.get('edad', 25)})
            (presupuesto-min {float(datos.get('presupuesto_min', 0))})
            (presupuesto-max {float(datos.get('presupuesto_max', 9999))})
            (uso-principal {datos.get('uso_principal', 'desconocido')})
            (preferencia-marca {datos.get('preferencia_marca', 'cualquiera')})
            (sistema-operativo {datos.get('sistema_operativo', 'indiferente')})
            (prioridad-bateria {datos.get('prioridad_bateria', 'baja')})
            (prioridad-camara {datos.get('prioridad_camara', 'baja')})
            (prioridad-rendimiento {datos.get('prioridad_rendimiento', 'baja')})
            (compras-previas "{compras}")
            (valoracion-anterior {float(datos.get('valoracion_anterior', 3.0))})
            (perfil-validado no)
        ))
    """)


def afirmar_feedback(env, feedback_list):
    """Afirma hechos de feedback si existen."""
    for fb in feedback_list:
        env.eval(f"""
            (assert (feedback
                (smartphone-id {fb['smartphone_id']})
                (satisfaccion {fb['satisfaccion']})
                (comentario "{fb.get('comentario', '')}")
            ))
        """)


def cambiar_fase(env, fase):
    """Cambia la fase de la sesión."""
    for fact in env.facts():
        try:
            if fact.template.name == "sesion":
                fact.retract()
                break
        except Exception:
            pass
    env.eval(f"(assert (sesion (fase {fase}) (recomendaciones-generadas 0)))")


def leer_resultados(env):
    """Lee los hechos de recomendación y smartphone y los estructura."""
    recomendaciones = []
    errores = []
    smartphones = {}

    for fact in env.facts():
        try:
            nombre = fact.template.name
            if nombre == "smartphone":
                sid = str(fact["id"])
                smartphones[sid] = {
                    "id": sid,
                    "nombre": str(fact["nombre"]),
                    "marca": str(fact["marca"]),
                    "precio": float(fact["precio"]),
                    "sistema_operativo": str(fact["sistema-operativo"]),
                    "ram_gb": int(fact["ram-gb"]),
                    "almacenamiento_gb": int(fact["almacenamiento-gb"]),
                    "camara_mp": int(fact["camara-mp"]),
                    "bateria_mah": int(fact["bateria-mah"]),
                    "refresh_rate": int(fact["refresh-rate"]),
                    "procesador_score": int(fact["procesador-score"]),
                    "tiene_5g": str(fact["tiene-5g"]) == "si",
                    "carga_rapida": str(fact["carga-rapida"]) == "si",
                    "descuento_pct": float(fact["descuento-pct"]),
                }
            elif nombre == "error-validacion":
                errores.append({
                    "campo": str(fact["campo"]),
                    "mensaje": str(fact["mensaje"]),
                })
        except Exception:
            pass

    for fact in env.facts():
        try:
            if fact.template.name == "recomendacion":
                sid = str(fact["smartphone-id"])
                nivel = str(fact["nivel"])
                if nivel == "descartado":
                    continue
                puntaje = float(fact["puntaje"])
                rec = {
                    "smartphone_id": sid,
                    "puntaje": round(min(puntaje, 100.0), 1),
                    "nivel": nivel,
                    "justificacion": str(fact["justificacion"]),
                }
                if sid in smartphones:
                    rec["smartphone"] = smartphones[sid]
                recomendaciones.append(rec)
        except Exception:
            pass

    recomendaciones.sort(key=lambda x: x["puntaje"], reverse=True)
    return recomendaciones, errores


# ─────────────────────────────────────────────
# RUTAS API
# ─────────────────────────────────────────────

@app.route("/api/recomendar", methods=["POST"])
def recomendar():
    """Endpoint principal: recibe perfil de usuario, devuelve recomendaciones."""
    datos = request.get_json()
    if not datos:
        return jsonify({"error": "Se requiere JSON con datos del usuario"}), 400

    try:
        env = crear_entorno()
        afirmar_usuario(env, datos)

        # Afirmar feedback si viene en la petición
        feedback_list = datos.get("feedback", [])
        if feedback_list:
            afirmar_feedback(env, feedback_list)

        # Cambiar fase a inferencia y correr
        cambiar_fase(env, "inferencia")
        env.run(500)

        recomendaciones, errores = leer_resultados(env)

        if errores:
            return jsonify({
                "estado": "error_validacion",
                "errores": errores,
                "recomendaciones": []
            }), 422

        principales = [r for r in recomendaciones if r["nivel"] == "principal"]
        alternativas = [r for r in recomendaciones if r["nivel"] == "alternativa"]

        return jsonify({
            "estado": "ok",
            "errores": [],
            "recomendaciones": {
                "principales": principales[:3],
                "alternativas": alternativas[:3],
            }
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/catalogo", methods=["GET"])
def catalogo():
    """Devuelve el catálogo completo de smartphones disponibles."""
    try:
        env = crear_entorno()
        smartphones = []
        for fact in env.facts():
            try:
                if fact.template.name == "smartphone":
                    smartphones.append({
                        "id": str(fact["id"]),
                        "nombre": str(fact["nombre"]),
                        "marca": str(fact["marca"]),
                        "precio": float(fact["precio"]),
                        "sistema_operativo": str(fact["sistema-operativo"]),
                        "ram_gb": int(fact["ram-gb"]),
                        "almacenamiento_gb": int(fact["almacenamiento-gb"]),
                        "camara_mp": int(fact["camara-mp"]),
                        "bateria_mah": int(fact["bateria-mah"]),
                        "refresh_rate": int(fact["refresh-rate"]),
                        "procesador_score": int(fact["procesador-score"]),
                        "tiene_5g": str(fact["tiene-5g"]) == "si",
                        "carga_rapida": str(fact["carga-rapida"]) == "si",
                        "descuento_pct": float(fact["descuento-pct"]),
                    })
            except Exception:
                pass
        smartphones.sort(key=lambda x: x["precio"])
        return jsonify({"estado": "ok", "smartphones": smartphones})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"estado": "ok", "mensaje": "Sistema Experto activo"})


if __name__ == "__main__":
    print("=== Sistema Experto Smartphones ===")
    print(f"CLIPS file: {CLIPS_FILE}")
    app.run(debug=True, port=5000)
