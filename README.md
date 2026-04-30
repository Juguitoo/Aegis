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

Para ejecutar este proyecto en tu entorno local, asegúrate de tener Flutter instalado y configurado.

1. **Clonar el repositorio:**
   ```bash
   git clone [https://github.com/tu-usuario/aegis.git](https://github.com/tu-usuario/aegis.git)
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

   *   **Para Escritorio (ej. Windows):**
       ```bash
       flutter run -d windows
       ```
       *(Sustituye `windows` por `macos` o `linux` según tu sistema operativo)*

   *   **Para Móvil (Emulador Android o dispositivo físico):**
       ```bash
       flutter run -d android
       ```

## 📱 Capturas de Pantalla

> **Nota:** Puedes añadir aquí capturas de pantalla de la aplicación. Crea una carpeta `/docs/images` en tu repositorio y enlaza las imágenes así:

| Escritorio | Móvil |
| :---: | :---: |
| ![Escritorio Tareas](ruta/a/tu/imagen_desktop.png) | ![Móvil Tareas](ruta/a/tu/imagen_mobile.png) |
| ![Escritorio Estadísticas](ruta/a/tu/estadisticas_desktop.png) | ![Móvil Pomodoro](ruta/a/tu/pomodoro_mobile.png) |

## 👨‍💻 Autor

* **[Tu Nombre]** - *Desarrollo UI/UX y Backend Local* - [Tu GitHub/LinkedIn]
