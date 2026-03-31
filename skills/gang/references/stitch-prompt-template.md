# Google Stitch UI Generation Instructions

This template is read by the `gang-ux-researcher` agent to structure its Stitch output.
Replace all `{placeholders}` with values derived from the context brief and UX analysis.

---

## App Overview
- **Name:** {app_name}
- **Purpose:** {one_line_purpose}
- **Platform:** {web | iOS | Android | cross-platform}
- **Design Style:** {describe the aesthetic direction — NOT "modern" or "clean", be specific: e.g., "dense data dashboard with muted earth tones", "playful consumer app with rounded geometry and saturated accents"}

## Target Users
- **Primary Persona:** {name, role, key goal}
- **Secondary Persona:** {name, role, key goal}
- **Accessibility Level:** WCAG AA minimum

---

## Design System

### Colors (OKLCH)
All colors defined in OKLCH for perceptual uniformity. Hex fallbacks provided for Stitch.

- **Primary:** {oklch value} / {hex fallback}
- **Primary Variant:** {oklch} / {hex}
- **Secondary:** {oklch} / {hex}
- **Background:** {oklch} / {hex}
- **Surface:** {oklch} / {hex}
- **Surface Elevated:** {oklch} / {hex}
- **Text Primary:** {oklch} / {hex} — NEVER pure #000000, use tinted near-black
- **Text Secondary:** {oklch} / {hex}
- **Text Disabled:** {oklch} / {hex}
- **Success:** {oklch} / {hex}
- **Error:** {oklch} / {hex}
- **Warning:** {oklch} / {hex}
- **Info:** {oklch} / {hex}
- **Border:** {oklch} / {hex}
- **Neutrals:** All grays tinted toward the primary hue — NEVER use pure gray (#808080 or similar)

### Typography
- **Heading Font:** {font_family — NOT Inter, Poppins, or Montserrat}
- **Body Font:** {font_family — must pair well with heading font}
- **Monospace:** {font_family — for code/data if applicable}
- **Scale (modular ratio {ratio}):**
  - Display: {size}px / {line_height}
  - H1: {size}px / {line_height}
  - H2: {size}px / {line_height}
  - H3: {size}px / {line_height}
  - Body: {size}px / {line_height}
  - Body Small: {size}px / {line_height}
  - Caption: {size}px / {line_height}
  - Label: {size}px / {line_height} / UPPERCASE {letter_spacing}
- **Font Weights:** Regular (400), Medium (500), Semibold (600), Bold (700)

### Spacing (4px base grid)
- 4px (xxs) — inner padding, icon gaps
- 8px (xs) — compact element spacing
- 12px (sm) — form field padding
- 16px (md) — standard content padding
- 24px (lg) — section padding
- 32px (xl) — major section breaks
- 48px (2xl) — page-level spacing
- 64px (3xl) — hero/header spacing

### Corners
- None: 0px — tables, full-bleed elements
- Small: {value}px — inputs, small cards
- Medium: {value}px — cards, modals
- Large: {value}px — featured cards, images
- Full: 9999px — pills, avatars, tags

### Shadows
- Subtle: {value} — cards at rest
- Medium: {value} — dropdowns, popovers
- Prominent: {value} — modals, dialogs
- NO shadow on flat/embedded elements

### Motion
- Easing: cubic-bezier(0.4, 0, 0.2, 1) for standard transitions
- Duration: 150ms (micro), 250ms (standard), 400ms (emphasis)
- NEVER use bounce or elastic easing
- All motion respects prefers-reduced-motion

---

## Screens

### Screen 1: {screen_name}
**Purpose:** {what the user accomplishes here}
**Entry Point:** {how user arrives — e.g., app launch, navigation tap, deep link}

**Layout (top to bottom):**
- **Header:** {description — e.g., "top app bar with back arrow, title '{Title}', and settings icon button"}
- **Section A:** {description — e.g., "hero card with user avatar (48px circle), greeting text, and primary metric"}
- **Section B:** {description — e.g., "horizontal scroll of 3-4 category cards, each 120px wide with icon + label"}
- **Section C:** {description — e.g., "vertical list of recent items, each row: thumbnail (40px), title, subtitle, timestamp, chevron"}
- **Footer/Bottom Nav:** {description — if applicable}

**Components with Properties:**
1. {ComponentType} — {text content}, {color token}, {size}, {interactive states}
2. {ComponentType} — {text content}, {color token}, {size}, {interactive states}
3. ...

**Content Examples (realistic placeholder data):**
- {Example data that looks real, not "Lorem ipsum" — e.g., "Sarah Chen", "$4,230.50", "Mar 15, 2026"}

**Navigation:**
- Tapping {element} navigates to {Screen N}
- Back button returns to {Screen N}
- {Swipe/gesture} performs {action}

**States:**
- **Loading:** {skeleton screen with shimmer on content areas / spinner}
- **Empty:** {illustration + message "{text}" + CTA button "{label}"}
- **Error:** {inline error banner with retry button / full-screen error}

### Screen 2: {screen_name}
...

---

## Global Patterns

### Navigation
- **Type:** {bottom tab bar | side drawer | top tabs | stack only}
- **Tabs:** {tab1_label + icon, tab2_label + icon, ...}
- **Active Indicator:** {filled icon + label + primary color underline}

### Loading States
- **Lists:** Skeleton rows with shimmer animation (3-5 placeholder rows)
- **Cards:** Skeleton card shapes matching real card dimensions
- **Full Page:** Centered spinner with {brand color} only if skeleton not feasible

### Empty States
- **Pattern:** Illustration (subtle, on-brand) + message (1 sentence) + CTA button
- **Message tone:** Encouraging, action-oriented (e.g., "No projects yet. Create your first one.")

### Error Handling
- **Form Validation:** Inline below field, red text with error icon, appears on blur
- **Network Errors:** Toast at bottom, auto-dismiss 5s, with retry action
- **Fatal Errors:** Full-screen with illustration, message, and "Try Again" button

### Toasts & Notifications
- **Position:** Bottom center, 16px margin from bottom edge
- **Duration:** 3s (success), 5s (error/warning), persistent (action required)
- **Style:** Surface elevated background, rounded corners, subtle shadow

### Accessibility
- All touch targets minimum 44x44px
- Focus rings visible on keyboard navigation (2px solid primary, 2px offset)
- Color is never the only indicator (always paired with icon or text)
- Screen reader announcements for dynamic content changes

---

## Design Quality Rules (Anti-Patterns to Avoid)

These rules MUST be followed. Violating them produces generic "AI slop" UI.

### NEVER DO
- Use Inter, Poppins, or Montserrat as default fonts
- Use pure gray (#808080 or similar) — always tint neutrals toward the brand hue
- Use pure black (#000000) for text — use near-black with warm/cool tint
- Nest cards inside cards (flatten the hierarchy instead)
- Use bounce or elastic easing for animations
- Skip focus states on interactive elements
- Use touch targets smaller than 44px on mobile
- Use "Lorem ipsum" placeholder text — use realistic content
- Default to a white background with blue primary (choose an intentional palette)
- Use more than 2 font families (heading + body is enough)
- Add drop shadows to everything — shadows should convey elevation, not decoration
- Use low-contrast text (all text must meet WCAG AA: 4.5:1 normal, 3:1 large)

### ALWAYS DO
- Tint all neutral colors toward the brand hue for cohesion
- Use OKLCH color space for perceptual uniformity across the palette
- Follow 4px/8px spacing grid strictly — no arbitrary pixel values
- Provide loading, empty, and error states for every data-driven screen
- Include hover, focus, active, and disabled states for interactive elements
- Support prefers-reduced-motion for all animations
- Use semantic color naming (not "blue-500" but "primary", "success", "error")
