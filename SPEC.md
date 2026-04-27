# Guide Démarches France - Spouse Visa Vietnamese Citizen

## Concept & Vision

A warm, comprehensive, and meticulously detailed guide for Vietnamese citizens arriving in France via a spouse visa (visa époux). The site feels like a trusted friend who has already gone through all these steps — organized, reassuring, and leaving no question unanswered. The design evokes a blend of French elegance with subtle Vietnamese warmth.

## Design Language

### Aesthetic Direction
French administrative clarity meets Vietnamese warmth — clean, structured, but inviting. Think of a well-organized French administration folder with a touch of lotus flower subtlety.

### Color Palette
- Primary: `#1a3a5c` (Deep French Blue)
- Secondary: `#c41e3a` (Vietnamese Red / Accent)
- Accent: `#d4a574` (Warm gold, like a Vietnamese lacquerware highlight)
- Background: `#faf8f5` (Warm off-white, like rice paper)
- Text: `#2d2d2d` (Soft black)
- Light accent: `#e8f4f8` (Very light blue for cards)

### Typography
- Headings: "Playfair Display" (elegant, French feel)
- Body: "Source Sans 3" (clear, readable)
- Fallback: Georgia, system-ui

### Spatial System
- Max content width: 900px centered
- Section padding: 80px vertical
- Card padding: 32px
- Generous line-height (1.7) for readability

### Motion Philosophy
- Smooth scroll between sections
- Subtle fade-in on scroll for sections
- Hover states on cards with gentle lift
- No distracting animations

### Visual Assets
- Emoji icons for quick visual scanning (🇻🇳 🇫🇷 📋 🏠 💳 🔐)
- Clean section dividers with subtle gradient
- Progress indicator showing steps timeline

## Layout & Structure

### Single Page Architecture
1. **Hero** - Welcoming header with Vietnamese/French flags, title, introduction
2. **Chronologie** - Visual timeline of steps (before arrival → first weeks → first months)
3. **Section Cards** - Each major procedure as an expandable/collapsible detailed card:
   - Visa & OFII
   - Préfecture & Titre de Séjour
   - Sécurité Sociale (CPAM)
   - Impôts & Numéro Fiscal
   - Banque & Comptes
   - Logement
   - Téléphone & Opérateurs
   - CAF (Allocations)
   - Permis de Conduire
   - Emploi & Travail
   - Santé & Mutuelle
   - Assurance Voiture
   - Numéro INE (éducation)
4. **Checklist Interactive** - Printable/generatable checklist of all steps
5. **Ressources** - Links to official government sites
6. **Footer** - Disclaimer, last updated, contribution info

### Responsive Strategy
- Mobile-first, single column on mobile
- Cards stack vertically on mobile
- Navigation sidebar on desktop (sticky)

## Features & Interactions

### Core Features
- **Section Navigation**: Click to smooth-scroll to any section
- **Expandable Details**: Click cards to reveal detailed steps
- **Progress Checklist**: Track completed steps with localStorage persistence
- **Print Mode**: Clean print stylesheet for physical checklist

### States
- Default: All sections visible but collapsed content
- Expanded: Card reveals full details with nested sub-steps
- Checked: Progress saved to localStorage
- Hover: Cards lift slightly with shadow

## Component Inventory

### Hero Section
- Large title with emoji flags
- Introductory paragraph explaining the guide purpose
- "Commencez ici" CTA button

### Navigation
- Sticky top nav with section links
- Active section highlighted on scroll

### Procedure Card
- Header: Icon + Title + Chevron indicator
- Body: Ordered list of steps with timestamps
- Documents list (what to bring)
- Pro tips in highlighted boxes
- Warning boxes for common pitfalls

### Timeline
- Horizontal on desktop, vertical on mobile
- Color-coded phases: Avant l'arrivée, Semaines 1-4, Mois 2-6, Au-delà

### Checklist
- Checkbox items with section grouping
- Progress bar at top
- "Réinitialiser" button

## Technical Approach

- Pure HTML5 + CSS3 + Vanilla JavaScript
- No build step required
- GitHub Pages compatible
- Single `index.html` with embedded styles and scripts
- Print stylesheet included
