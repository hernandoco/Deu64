# Deu64
# Deu64

Monorepo con:
- `backend/`: API REST en Go (net/http)
- `mobile/`: App Flutter (escenas + quiz en carrusel)

## Backend (Go)
### Requisitos
- Go 1.22+

### Ejecutar
```bash
cd backend
go run .
```

API en:
- http://localhost:8080
- En la red: http://192.168.1.5:8080 (según IP LAN de tu PC)

Endpoints:
- GET `/api/v1/leer_tema`
- GET `/api/v1/preguntas_tema`

Los datos se leen desde:
- `backend/data/tema.json`
- `backend/data/preguntas.json`

## Mobile (Flutter)
### Requisitos
- Flutter SDK (Dart 3+)

### Configurar URL del backend
Editar `mobile/lib/config.dart`:
- `baseUrl = http://192.168.1.5:8080`

### Ejecutar
```bash
cd mobile
flutter pub get
flutter run
```

### Placeholder
Debes agregar una imagen real en:
- `mobile/assets/images/placeholder.png`
y mantenerla declarada en `pubspec.yaml`.
