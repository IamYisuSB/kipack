<div align="center">

<img src="logos/kipick-feature-graphic-1024x500.png" alt="Kipack" width="100%" />

# Kipack

**Tu maleta, lista en segundos.**
Listas de equipaje inteligentes generadas con IA para cada viaje.

[![Google Play](https://img.shields.io/badge/Google_Play-Descargar-34A853?style=for-the-badge&logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=com.fooserd.kipack)
[![Web](https://img.shields.io/badge/Web-kipack--app.vercel.app-000000?style=for-the-badge&logo=vercel&logoColor=white)](https://kipack-app.vercel.app)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3FCF8E?style=flat-square&logo=supabase&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-00B4AB?style=flat-square)
![Android](https://img.shields.io/badge/Android-3DDC84?style=flat-square&logo=android&logoColor=white)

</div>

---

## ✈️ ¿Qué es Kipack?

Kipack es una app móvil que te ayuda a preparar el equipaje sin olvidarte de nada. Le dices a dónde vas, cuántos días y qué vas a hacer, y la IA genera una lista personalizada teniendo en cuenta el destino, el clima previsto y tus actividades. Después puedes organizarla por maletas, marcar lo que ya has guardado y compartirla con tus acompañantes.

## ✨ Funcionalidades

| | |
|---|---|
| 🤖 **Listas con IA** | Sugerencias según destino, duración, tipo de viaje y actividades concretas (buceo, senderismo, esquí…). Incluye un chat para pedir ajustes: *"llevo poco espacio, optimízala"*. |
| 🌦️ **Clima del viaje** | Previsión del destino con desglose día a día: temperaturas, probabilidad de lluvia y estado del cielo. |
| 🧳 **Varias maletas** | Reparte los artículos entre maletas y marca lo que ya está empacado. |
| 👥 **Listas compartidas** | Invita a tus acompañantes por correo y asigna cada artículo a quien lo lleva. Sincronización en tiempo real. |
| 📋 **Plantillas** | Guarda listas reutilizables ("negocios", "playa"…) y aplícalas a cualquier viaje nuevo. |
| 🗺️ **Mapa de países** | Mapa mundial con los países visitados y los próximos destinos. |
| 🔔 **Recordatorios** | Avisos inteligentes: *"faltan 3 días y aún no has hecho la maleta"*. |
| 📄 **Exportar a PDF** | Genera un PDF de la lista por categorías y compártelo por WhatsApp, Drive o imprímelo. |
| ☁️ **Sincronización en la nube** | Copia de seguridad de viajes y maletas en tu cuenta, disponible en todos tus dispositivos. |
| 🌍 **Multidioma** | Español, inglés y francés. |

## 🛠️ Stack técnico

- **Frontend:** Flutter / Dart con [Riverpod](https://riverpod.dev) para la gestión de estado
- **Backend:** [Supabase](https://supabase.com) — autenticación, PostgreSQL con Row Level Security, Realtime, Storage y Edge Functions
- **IA:** modelos LLM a través de [OpenRouter](https://openrouter.ai)
- **Pagos:** Google Play Billing (`in_app_purchase`) con verificación de compras en servidor
- **Otros:** notificaciones locales, generación de PDF (`pdf` + `printing`), mapas (`countries_world_map`), i18n con ARB

## 📁 Estructura del proyecto

```
lib/
├── core/            # Lógica transversal: auth, billing, sync, premium, tema, idioma…
├── features/        # Pantallas por funcionalidad
│   ├── trips/          # Viajes
│   ├── packing_list/   # Listas de equipaje y maletas
│   ├── weather/        # Clima del destino
│   ├── map/            # Mapa de países
│   ├── account/        # Perfil y cuenta
│   ├── onboarding/
│   └── legal/
├── l10n/            # Traducciones (es, en, fr)
└── main.dart
supabase/
├── functions/       # Edge Functions (emails de auth, verificación de compras…)
└── sql/             # Esquema, políticas RLS y migraciones
```

## 🚀 Ejecutar en local

**Requisitos:** Flutter SDK (Dart ^3.12), un proyecto de Supabase y una API key de OpenRouter.

```bash
git clone https://github.com/IamYisuSB/kipack.git
cd kipack
flutter pub get
```

Crea un archivo `.env` en la raíz a partir de `.env.example`:

```env
SUPABASE_URL=https://<tu-proyecto>.supabase.co
SUPABASE_ANON_KEY=<tu-anon-key>
OPENROUTER_API_KEY=<tu-api-key>
OPENROUTER_MODEL=<modelo>
```

Aplica los scripts de `supabase/sql/` en tu proyecto de Supabase y ejecuta:

```bash
flutter run
```

## 👤 Autor

Desarrollado por **Jesús Guerrero** — [@IamYisuSB](https://github.com/IamYisuSB) · [Portfolio](https://jesus-guerrero-portfolio.vercel.app)

Desarrollado con la ayuda de [Claude Code](https://claude.com/claude-code).

---

<div align="center">

© 2026 Kipack · [Política de privacidad](privacy-policy.html) · [Eliminación de cuenta](account-deletion.html)

</div>
