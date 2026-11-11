---
name: flutter-kids-reading-design
description: Design System infantil (Material 3, degradado morado #7957F3 → #8769FF) para la app Deu64 y especificación de la pantalla principal (HomeScreen) basada en el modelo "Modelo home screem.pdf": marco blanco con mensaje y niño pastor, menú Devocional/Ayuda/Premios/Donación, tarjeta de mensaje de voz, versículo del día, tarjeta del título del devocional y barra inferior flotante Home/Enseñanzas/Perfil. Úsalo al crear o modificar pantallas, temas, colores, tipografía o componentes visuales de la app.
---

# Flutter Kids Reading Design (Deu64)

Guía para construir interfaces infantiles de lectura en Flutter con Material 3. Textos de UI en español. El proyecto ya usa `useMaterial3: true` en `lib/main.dart`; este skill reemplaza `colorSchemeSeed: Colors.deepPurple` por el tema de abajo.

**Referencia visual:** `Modelo home screem.pdf` (carpeta Downloads del usuario). Estilo: fondo lavanda muy claro, una tarjeta blanca grande y redondeada que se superpone al encabezado, iconos sobre círculos pastel, una tarjeta con degradado morado, tarjetas blancas con sombra suave y barra inferior flotante en forma de píldora.

## Principios

- **Legible primero:** texto grande, alto contraste, mucho espacio.
- **Táctil:** objetivos de toque de al menos 56×56 dp (el mínimo de M3 es 48).
- **Formas suaves:** esquinas muy redondeadas, sombras difusas y de baja opacidad.
- **Icono + etiqueta siempre.**
- **Pocas opciones por fila:** máximo 3 acciones.
- **Sin dependencias nuevas** para tema ni iconos: `ThemeData`, `Icons.*` y los assets existentes.

## Tokens

### Color

| Token | Valor | Uso |
|---|---|---|
| `primary` | `#7957F3` | botones, icono activo, enlaces |
| `primaryEnd` | `#8769FF` | final del degradado |
| `background` | `#F4F1FF` | fondo de pantalla (lavanda) |
| `surface` | `#FFFFFF` | tarjetas |
| `onSurface` | `#2B2350` | texto principal (morado muy oscuro) |
| `onSurfaceVariant` | `#6E6896` | texto secundario |
| `tileDevocional` | `#E9E3FF` | fondo lavanda del icono del versículo e indicador de la barra inferior |
| `menuDevocional` | `#EDE7FF` | fondo pastel (lavanda) del cuadro Devocional |
| `menuAyuda` | `#D9F6F0` | fondo pastel (menta) del cuadro Ayuda |
| `menuPremios` | `#FFF1CC` | fondo pastel (crema) del cuadro Premios |
| `menuDonacion` | `#FFE2EC` | fondo pastel (rosa) del cuadro Donación |
| `error` | `#D64545` | solo errores |

**Degradado de marca** (tarjeta de voz, encabezado de botones principales):

```dart
const kBrandGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFF7957F3), Color(0xFF8769FF)],
);
```

El texto sobre el degradado es blanco (contraste ≥ 4.5:1 con ambos extremos; comprobarlo si se cambia el color).

### Tipografía

Fuente del sistema; no añadir paquetes sin pedirlo.

| Estilo | Tamaño | Peso | Uso |
|---|---|---|---|
| headlineMedium | 26 | w800 | título del devocional |
| titleLarge | 20 | w700 | encabezados de sección |
| titleMedium | 16 | w700 | etiquetas del menú, títulos de tarjeta |
| bodyLarge | 20, altura 1.5 | w400 | texto de lectura |
| bodyMedium | 14 | w400 | subtítulos |
| labelLarge | 14 | w700 | botones, enlaces |

### Espaciado y forma

- Espaciado: 4 / 8 / 12 / 16 / 24 / 32. Margen lateral de pantalla: 16.
- Radios: tarjetas 28, miniaturas 20, barra inferior 32.
- Sombra de tarjeta: `BoxShadow(color: Color(0x1A7957F3), blurRadius: 20, offset: Offset(0, 8))`.

### Tema base

```dart
// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

const kBrandGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFF7957F3), Color(0xFF8769FF)],
);

ThemeData buildKidsTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF7957F3),
    primary: const Color(0xFF7957F3),
    surface: const Color(0xFFFFFFFF),
    onSurface: const Color(0xFF2B2350),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF4F1FF),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(fontSize: 20, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE9E3FF),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
```

## Pantalla principal (`lib/screens/home_screen.dart`)

Fondo `background`. Cuerpo en `SingleChildScrollView` dentro de `SafeArea` para que no desborde en pantallas pequeñas. De arriba abajo:

1. **Marco del niño pastor con mensaje.** Contenedor de ancho completo con **fondo blanco** (para no contrastar con la imagen), esquinas inferiores de 28, sombra `kCardShadow` y alto = **57,6 % de la altura de pantalla**. Dentro (con `SafeArea` arriba), una `Row` con `crossAxisAlignment: stretch` dividida **mitad y mitad** (dos `Expanded` iguales, 16 dp entre ellos): a la izquierda una `Column` centrada verticalmente con la cita **"Deu 6:4"** (`titleLarge` a 24, w800, `letterSpacing: 1`, color `primary` para que destaque) y debajo, a 4 dp, el mensaje **"Oye papi: El Señor nuestro Dios, Jehová es... estas palabras... me las repetirás."** (`headlineMedium` reducido a 20 con `height: 1.25`, color de texto normal, varias líneas, dentro de `Flexible` con `TextOverflow.fade` para no desbordar) y a la derecha la imagen `assets/images/pastor.jpg` (alternativa `pastor1.jpg`) llenando toda su mitad, `BoxFit.cover`, `alignment: topCenter`, radio 20, `semanticLabel`. Dejar `overlap + 12` dp de espacio inferior para la tarjeta del punto 2, que se superpone ≈ 40 dp sobre el borde del marco (`Transform.translate`).
2. **Tarjeta blanca con menú de iconos: Devocional · Ayuda · Premios · Donación** (en ese orden). `Card` de ancho completo con `Row`, 4 botones iguales (`Expanded`). Cada uno: cuadro redondeado de 76 dp (radio 26, borde blanco de 2, degradado de `menu*` aclarado arriba a `menu*` abajo, sombra suave del mismo tono) y, encima, una **ilustración 3D "inflada" a todo color de 60 dp** (cada pieza con degradado claro→oscuro, canto inferior más oscuro y brillo blanco) dibujada con `CustomPainter` en `lib/widgets/menu_illustrations.dart` (lienzo 100×100, sin PNG/SVG ni dependencias); etiqueta `titleMedium` debajo. Revisar que "Donación" no se corte en 360 dp de ancho.
   - Devocional → `BookIllustration` (Biblia abierta, cruz dorada, cinta roja)
   - Ayuda → `HelpIllustration` (globo de diálogo turquesa con "?" y destellos)
   - Premios → `TrophyIllustration` (copa dorada, estrella roja, base morada)
   - Donación → `PiggyIllustration` (alcancía cerdito con moneda de corazón)
3. **Tarjeta de mensaje de voz** (equivale a la tarjeta "Daily Goal" del modelo). Ancho completo, fondo `kBrandGradient`, radio 28, texto blanco. Contenido: botón circular blanco de 56 dp con `Icons.play_arrow_rounded` / `Icons.pause_rounded` en `primary`; título "Mensaje de hoy" (`titleMedium`); subtítulo "Toca para escuchar" (`bodyMedium`); barra `LinearProgressIndicator` blanca sobre pista translúcida, con la duración a la derecha. Sin autoplay.
4. **Versículo del día** (tarjeta horizontal blanca, entre la tarjeta de voz y la sección del devocional). Círculo lavanda de 48 dp con `Icons.auto_stories_rounded` en `primary`; a la derecha, la etiqueta **"Versículo del día:"** (`labelLarge`, `primary`) y debajo el texto **"Jesús es mi pastor"** (`titleLarge`). Texto fijo por ahora; cuando el backend lo provea, leerlo de los datos.
5. **Tarjeta del título del devocional** (equivale a "Continue Learning"). Fila de encabezado de sección con "Devocional de hoy" (`titleLarge`) y, a la derecha, "Ver todo" (`labelLarge`, `primary`) solo si hay más devocionales. Debajo, `Card` blanca con sombra: miniatura cuadrada de 88 dp (radio 20), título (`headlineMedium` reducido a 20 si no cabe, máx. 2 líneas, ellipsis), subtítulo y, al final, botón circular `primary` con `Icons.play_arrow_rounded`. El título viene de `ApiClient.fetchTopic()`; no hardcodear.
6. **Barra inferior flotante: Home · Enseñanzas · Perfil.** `NavigationBar` M3 envuelto en un `Container` blanco con radio 32 y sombra, con margen de 16 respecto a los bordes (efecto píldora flotante). Icono y etiqueta activos en `primary`, inactivos en `onSurfaceVariant`.
   - Home → `Icons.home_rounded`
   - Enseñanzas → `Icons.school_rounded`
   - Perfil → `Icons.face_rounded`

### Del modelo que NO se incluye
Botón de menú y de búsqueda del encabezado, saludo "Hi, Champ" (lo reemplaza el mensaje del pastor), mascota de estrella, filas "Recomendado para ti" y las pestañas Games/Rewards. Añadir solo si el usuario lo pide.

### Navegación y flujo

- Flujo: `LoadingScreen` → `LoginPage` (pop con token) → `ApiClient.fetchTopic()` → **`HomeScreen`** → `ScenesCarouselScreen` → `StartQuestionsScreen` → `QuizCarouselScreen` → `ResultScreen`. Solo cambia el destino del `pushReplacement` que hoy lleva a `ScenesCarouselScreen`.
- Devocional (menú) y tarjeta del título → `ScenesCarouselScreen` con el tema ya cargado.
- Ayuda, Donación, Premios, Enseñanzas y Perfil → pantallas placeholder con "Próximamente" hasta que se definan.
- La barra inferior cambia el cuerpo con `IndexedStack` dentro de `HomeScreen` (índice en `State`); no usar `pushReplacement` entre pestañas.

### Audio
Pendiente de decisión: usar `just_audio` (recomendado) cuando exista una fuente de audio (URL del backend o asset). **Preguntar antes de añadirlo a `pubspec.yaml`.** Mientras tanto, estado play/pausa local con un `TODO`.

## Accesibilidad

- `Semantics`/`tooltip` en todos los botones de icono.
- Respetar `MediaQuery.textScaler`; no fijar alturas que corten texto escalado.
- No transmitir información solo con color (el icono y la etiqueta siempre acompañan al color del icono; el ámbar sobre blanco tiene poco contraste, por eso la etiqueta es obligatoria).
- Animaciones cortas (≤ 300 ms) y sin parpadeos.

## Checklist antes de dar por terminado

- [ ] `flutter analyze` sin errores nuevos.
- [ ] Se ve bien en pantalla pequeña (≈ 360×640) y con texto al 130 %.
- [ ] Todos los toques ≥ 56 dp.
- [ ] Ninguna cadena de UI en inglés.
- [ ] `main.dart` usa `buildKidsTheme()`.
