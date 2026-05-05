# 🛡️ Aegis - Personal Productivity & Focus App

Aegis es una aplicación multiplataforma (Móvil y Escritorio) diseñada para centralizar y potenciar la productividad personal. Combina la gestión avanzada de tareas con técnicas de concentración, análisis de datos y bienestar digital en un único ecosistema fluido y adaptativo.

Este proyecto ha sido desarrollado como Trabajo de Fin de Grado (TFG) en Ingeniería Informática.

## ✨ Funcionalidades Principales

*   **Gestión Integral de Tareas:** Creación de tareas con subtareas (checklists), estimaciones de tiempo, prioridades, fechas de vencimiento y recordatorios.
*   **Organización por Proyectos y Etiquetas:** Clasificación de tareas mediante proyectos personalizables (con colores) y etiquetas múltiples para un filtrado rápido.
*   **Calendario Inteligente:** Vista unificada de eventos y tareas programadas con marcadores visuales y formularios de creación rápida.
*   **Temporizador Pomodoro Inmersivo:** Sesiones de enfoque personalizables (trabajo, descanso corto, descanso largo) con interfaz inmersiva.
*   **Bloqueo de Aplicaciones (Solo Android):** Sistema de bienestar digital que detecta y bloquea aplicaciones distractoras durante las sesiones de concentración.
*   **Seguimiento de Hábitos:** Matriz de progreso semanal para construir y mantener rutinas productivas.
*   **Diario Personal:** Espacio de reflexión diario vinculado al calendario.
*   **Análisis y Estadísticas:** Panel de métricas avanzadas (gráficos de barras, líneas y circulares) para visualizar el rendimiento, la precisión de las estimaciones y la distribución del tiempo.
*   **Copia de Seguridad:** Exportación e importación completa de la base de datos en formato JSON.

## 🛠️ Stack Tecnológico y Arquitectura

La aplicación está construida siguiendo los principios de **Clean Architecture** y el patrón de diseño **MVVM** (Model-View-ViewModel) para garantizar la escalabilidad, testeabilidad y separación de responsabilidades.

*   **Framework:** [Flutter](https://flutter.dev/) (Soporte adaptativo para Mobile y Desktop)
*   **Lenguaje:** Dart
*   **Gestor de Estado:** [Riverpod](https://riverpod.dev/) (StateNotifier, StreamProvider, AsyncValue)
*   **Base de Datos Local:** [Drift](https://drift.simonbinder.eu/) (SQLite reactivo con soporte para Streams)
*   **Componentes UI Destacados:**
    *   `table_calendar`: Renderizado avanzado del calendario.
    *   `fl_chart`: Visualización de datos y estadísticas.
    *   `flutter_local_notifications`: Gestión de recordatorios nativos.

## 🚀 Instalación y Ejecución

Para poder ejecutar este proyecto sigue estos pasos para configurar tu entorno local correctamente.

### 📋 Requisitos Previos

*   **[Flutter SDK](https://docs.flutter.dev/get-started/install):** Versión `>=3.4.0`
*   **Para compilar en Windows:** Es obligatorio instalar **[Visual Studio](https://visualstudio.microsoft.com/downloads/)** (la versión completa de IDE, no VS Code) y marcar la carga de trabajo *"Desarrollo para el escritorio con C++"* durante la instalación.
*   **Para compilar en Android:** 
    1. Instala **[Android Studio](https://developer.android.com/studio)**. 
    2. Abre el **SDK Manager** (dentro de Android Studio) y asegúrate de tener instalado al menos un **Android SDK** reciente y las **Android SDK Command-line Tools** (pestaña *SDK Tools*).
    3. Abre tu terminal y acepta las licencias ejecutando: `flutter doctor --android-licenses`

### 🛠️ Instalación

1. **Clonar el repositorio:**
   ```bash
   git clone [https://github.com/Juguitoo/Aegis.git](https://github.com/Juguitoo/Aegis.git)
   cd aegis
2. **Instalar dependencias:**
   ```bash
   flutter pub get
3. **Generar código fuente (Drift y Riverpod):**
Dado que el proyecto utiliza generación de código para la base de datos, es fundamental ejecutar el build_runner antes de compilar:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
4. **Ejecutar la aplicación:**
   Dependiendo del entorno donde quieras probar la aplicación, utiliza el comando correspondiente:

   *   **Para Escritorio:**
       ```bash
       flutter run -d windows
       ```
       *(Sustituye `windows` por `macos` o `linux` según tu sistema operativo)*

   *   **Para Móvil (Emulador Android o dispositivo físico):**
       ```bash
       flutter run -d android
       ```
### 🩺 Solución de problemas (Troubleshooting)

Si la aplicación no compila o tienes conflictos con tu entorno local, ejecuta la herramienta de diagnóstico de Flutter:

```bash
flutter doctor -v
```
Este comando escaneará tu ordenador y te mostrará una lista de lo que está correctamente instalado y lo que falta. Presta especial atención a cualquier elemento marcado con una cruz roja ([x]) y sigue las instrucciones que la propia consola te proporcionará para solucionarlo.

## 📱 Capturas de Pantalla

| Escritorio | Móvil |
| :---: | :---: |
| ![Escritorio Tareas](/docs/images/VistaTareasEscritorio.png) | ![Móvil Tareas](/docs/images/VistaTareasMovil.png) |
| ![Escritorio Estadísticas](/docs/images/VistaAnalisisEscritorio.png) | ![Móvil Pomodoro](/docs/images/VistaAnalisisMovil.png) |

## 👨‍💻 Autor

* **Hugo Juan Gómez** - *Desarrollo UI/UX y Backend Local*
