# Impeccable Design Quality Rules

Distilled from Impeccable (pbakaus/impeccable). These rules are mandatory constraints for the
`gang-ux-researcher` agent when generating design tokens, wireframes, and Stitch instructions.
Violating these rules produces generic "AI slop" UI.

---

## 1. Typography

### Font Selection
**BLOCKED FONTS (never use as defaults):**
- Inter
- Poppins
- Montserrat
- Roboto (unless Android Material requirement)
- Open Sans (unless existing brand mandate)

**Selection criteria:**
- Choose fonts with personality that match the brand's voice
- Heading and body fonts must form a deliberate pairing (contrast in style, not just weight)
- Maximum 2 font families per project (heading + body)
- Monospace font only if the product displays code or data

### Typography Scale
- Use a modular scale ratio (1.2 minor third, 1.25 major third, or 1.333 perfect fourth)
- Define sizes relative to the base (typically 16px body)
- Line heights: 1.1-1.2 for headings, 1.4-1.6 for body text
- Letter spacing: tighten headings (-0.01 to -0.02em), normal for body, widen for uppercase labels (+0.05em)

### Type Hierarchy
- Establish clear visual hierarchy through size AND weight (not size alone)
- Use no more than 4 distinct text sizes per screen
- Heading weights: Semibold (600) or Bold (700)
- Body weight: Regular (400), Medium (500) for emphasis
- NEVER use Light (300) or Thin (100) for body text at small sizes

---

## 2. Color & Contrast

### Color Space
- Define all colors in **OKLCH** for perceptual uniformity
- Provide hex fallbacks for tools that don't support OKLCH
- Generate palette by varying lightness and chroma in OKLCH while holding hue constant

### Neutral Colors
- **NEVER use pure gray** (#808080, #999, #666, etc.)
- ALL neutral colors must be tinted toward the primary brand hue
- Warm brand = warm-tinted neutrals; Cool brand = cool-tinted neutrals
- This creates visual cohesion that pure grays destroy

### Text Colors
- **NEVER use pure black (#000000)** for text
- Use near-black tinted warm (e.g., #1a1a2e) or cool (e.g., #1e2a3a) depending on brand
- Secondary text: reduce opacity or use a lighter tinted neutral (not gray)

### Contrast Requirements (WCAG AA minimum)
- Normal text (<18px): 4.5:1 contrast ratio minimum
- Large text (>=18px bold or >=24px): 3:1 minimum
- Interactive elements (icons, borders, focus rings): 3:1 minimum
- Decorative elements: no requirement, but prefer higher contrast

### Semantic Color Usage
- Green = success, positive, gains
- Red = error, negative, losses, destructive actions
- Yellow/Amber = warning, caution, pending
- Blue = information, links, primary actions
- Color is NEVER the sole indicator — always pair with icon, text, or pattern

---

## 3. Spatial Design

### Grid System
- **Base unit: 4px** — all spacing and sizing must be multiples of 4px
- Common scale: 4, 8, 12, 16, 24, 32, 48, 64px
- NO arbitrary pixel values (no 5px, 7px, 13px, etc.)

### Spacing Application
- **Inner padding:** 8-16px (compact elements), 16-24px (cards, sections)
- **Element gaps:** 8px (tight), 12-16px (standard), 24px (loose)
- **Section spacing:** 32-48px between major sections
- **Page margins:** 16px (mobile), 24-32px (tablet), 48-64px (desktop)

### Density Hierarchy
- Dense: data tables, admin dashboards, settings (4-8px gaps)
- Standard: content pages, feeds, lists (12-16px gaps)
- Comfortable: marketing pages, onboarding, empty states (24-48px gaps)
- Match density to information priority, not aesthetic preference

### Alignment
- Optical alignment over mathematical alignment when they conflict
- Left-align text by default (center only for short headings, CTAs, empty states)
- Consistent alignment rails — establish 2-3 vertical alignment points per screen

---

## 4. Motion Design

### Easing
- **Standard:** cubic-bezier(0.4, 0, 0.2, 1) — for most transitions
- **Enter:** cubic-bezier(0, 0, 0.2, 1) — elements appearing
- **Exit:** cubic-bezier(0.4, 0, 1, 1) — elements leaving
- **NEVER use:** bounce, elastic, spring (unless the brand is explicitly playful AND you have user testing data)

### Duration
- **Micro (50-150ms):** button press, toggle, checkbox
- **Standard (200-300ms):** page transitions, card expand, dropdown open
- **Emphasis (400-600ms):** modal appear, onboarding animation
- **NEVER exceed 600ms** for UI transitions (feels sluggish)

### Stagger
- When animating lists, stagger each item by 30-50ms
- Maximum total stagger: 300ms (cap at 6-8 items visible)
- Items beyond viewport don't need stagger animation

### Reduced Motion
- **MANDATORY:** All motion must respect `prefers-reduced-motion: reduce`
- When reduced: replace animations with instant state changes or simple opacity fades
- Never disable transitions entirely — opacity crossfade (150ms) is the minimum

---

## 5. Interaction Design

### Touch Targets
- Minimum size: **44x44px** on mobile (Apple HIG + WCAG 2.5.8)
- Minimum size: **32x32px** on desktop
- Padding counts toward target size (a 24px icon with 10px padding = 44px target)

### Focus States
- **MANDATORY** visible focus ring on all interactive elements
- Focus ring: 2px solid primary color, 2px offset from element
- Focus ring must meet 3:1 contrast against its background
- Tab order must follow visual layout (left-to-right, top-to-bottom)

### Hover States
- Desktop only — do not rely on hover for mobile
- Subtle background change OR underline for links
- Cursor change: pointer for clickable, text for editable, not-allowed for disabled

### Active/Pressed States
- Brief visual feedback: slight scale(0.98), darkened background, or opacity change
- Duration: 50-100ms
- Must be distinct from hover state

### Disabled States
- Reduce opacity to 0.4-0.5
- Remove pointer cursor (use not-allowed)
- NEVER hide disabled elements — show them disabled with explanation tooltip

### Form Fields
- Clear label above or inside (floating label on focus)
- Placeholder text: example value, NOT the label
- Error state: red border + error message below field (appears on blur, not on each keystroke)
- Success state: green checkmark (optional, only for validated fields)
- Required indicator: asterisk (*) next to label

---

## 6. Responsive Design

### Approach
- **Mobile-first**: design the smallest screen first, enhance upward
- Breakpoints: 375px (mobile), 768px (tablet), 1024px (small desktop), 1440px (desktop)

### Fluid Typography
- Use `clamp()` for responsive font sizes: `clamp(min, preferred, max)`
- Example: `clamp(1rem, 0.9rem + 0.5vw, 1.25rem)` for body
- Headings scale more aggressively: `clamp(1.5rem, 1rem + 2vw, 3rem)`

### Layout Adaptation
- Single column on mobile (375px)
- Two columns from tablet (768px) where appropriate
- Max content width: 1200-1440px, centered with auto margins
- Sidebar navigation collapses to bottom tab bar or hamburger on mobile

### Container Queries (preferred over media queries for components)
- Components should adapt to their container size, not viewport size
- Use container queries for cards, widgets, and reusable components
- Reserve media queries for page-level layout changes

---

## 7. UX Writing

### Labels & Actions
- Use verbs for buttons: "Create Project", "Send Invite", "Save Changes"
- Avoid vague labels: "Submit", "OK", "Click Here"
- Destructive actions: "Delete Project" (not "Delete"), with confirmation dialog
- Be specific about what will happen: "Remove from team" not "Remove"

### Error Messages
- **Format:** What happened + Why + What to do
- **Example:** "Payment failed. Your card was declined. Please try a different payment method."
- NEVER: "An error occurred" or "Something went wrong" (useless)
- NEVER blame the user: "Invalid input" → "Please enter a valid email address"

### Empty States
- **Format:** Illustration (optional) + What this area is for + How to populate it
- **Example:** "No projects yet. Projects help you organize your work. Create your first project to get started."
- Always include a CTA to resolve the empty state
- Tone: encouraging, not apologetic

### Confirmations
- Confirm destructive actions: "Delete '{item_name}'? This cannot be undone."
- Name the item being affected (not "Are you sure?")
- Primary button = the destructive action with clear label
- Secondary button = "Cancel" (always available)

### Microcopy
- Loading: "Loading your dashboard..." (specific) not "Loading..." (generic)
- Success: "Project created successfully" (briefly, auto-dismiss)
- Counting: "3 items" not "3 item(s)" — handle pluralization properly
- Time: "2 hours ago" not "2h ago" (unless space-constrained)
