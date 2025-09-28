---
applyTo: '**/*.dart'
---
# Dart Design Guidelines
This document provides guidelines for designing the Vendly Store App in Flutter.
It includes information about color palette, design principles, typographies, and UI components.

## Language
- Primary Language: Spanish (ES)
- Secondary Language: English (EN)
- Ensure all text is clear, concise, and user-friendly.

## Color Palette

### Dark-mode palette

```css
/* Dark Mode Color Palette */
:root[data-theme="dark"] {
  /* Primary colors - adjusted for dark backgrounds */
  --persian-indigo: #4A2E8Fff; /* Lighter primary for better contrast */
  --mauve: #E4B8FFff; /* Brighter secondary for visibility */
  --alice-blue: #1a1a1a; /* Dark background */
  --russian-violet: #6B4C93ff; /* Lighter accent for readability */
  --indigo: #7B4CB8ff; /* Lighter dark accent */

  /* Additional dark mode specific colors */
  --surface-primary: #242424; /* Cards, panels */
  --surface-secondary: #2d2d2d; /* Elevated surfaces */
  --text-primary: #ffffff; /* Main text */
  --text-secondary: #b0b0b0; /* Secondary text */
  --text-tertiary: #808080; /* Muted text */
  --border-color: #404040; /* Borders and dividers */
  --shadow: rgba(0, 0, 0, 0.5); /* Shadows */

  /* Interactive states */
  --hover-overlay: rgba(207, 154, 247, 0.1); /* Mauve with low opacity */
  --focus-ring: #CF9AF7ff; /* Your original mauve */
  --error: #ff6b6b;
  --success: #51cf66;
  --warning: #ffd43b;
}
```

### Light-mode palette

```css
/* Light Mode Color Palette */
:root, :root[data-theme="light"] {
  /* Primary colors - optimized for light backgrounds */
  --persian-indigo:  #461282ff; /* Your original primary - perfect for light mode */
  --mauve: #9B5FC0ff; /* Darker mauve for better text contrast */
  --alice-blue: #f8f9faff; /* Softer background than pure white */
  --russian-violet: #1D0245ff; /* Your original - excellent contrast */
  --indigo: #2E095Fff; /* Your original dark accent */

  /* Additional light mode specific colors */
  --surface-primary: #ffffff; /* Pure white for cards, panels */
  --surface-secondary: #f1f3f4; /* Slightly darker elevated surfaces */
  --surface-tertiary: #e9ecef; /* Input fields, disabled states */
  --text-primary: #212529; /* Main text - high contrast */
  --text-secondary: #495057; /* Secondary text */
  --text-tertiary: #6c757d; /* Muted text, captions */
  --border-color: #dee2e6; /* Subtle borders */
  --border-strong: #adb5bd; /* More prominent borders */
  --shadow: rgba(46, 9, 95, 0.1); /* Subtle shadows with your primary color */

  /* Interactive states */
  --hover-overlay: rgba(46, 9, 95, 0.05); /* Persian indigo with low opacity */
  --hover-surface: #f8f9fa; /* Surface hover state */
  --focus-ring: #CF9AF7ff; /* Your original mauve for focus */
  --active-state: rgba(46, 9, 95, 0.1); /* Active/pressed states */

  /* Your branded status colors (optional) */
  --brand-error: #8B1538; /* Darker version of your palette */
  --brand-success: #2D5016; /* Complements your purples */
  --brand-warning: #B8860B; /* Warmer tone that works with your scheme */
  --brand-info: #0b4192ff; /* Brighter blue for info messages */
}
```

## Design Principles

### Visual Hierarchy & Modern Aesthetics
- Bold Typography: Use contemporary font families with strong hierarchy (large headings, clear body text)
- Generous White Space: Avoid cluttered layouts - let content breathe
- Vibrant Accent Colors: Your purple palette is perfect - use it strategically for CTAs and highlights
- High-Quality Imagery: Product photos and store imagery should be crisp, well-lit, and lifestyle-focused
- Subtle Gradients & Shadows: Add depth without being overwhelming

### Rounded & Friendly Interface
- Consistent Border Radius: Apply 12-16px radius to cards, buttons, and input fields
- Soft Shadows: Use subtle drop shadows for card elevation
- Pill-Shaped Elements: Categories, tags, and action buttons should have rounded edges
- Organic Shapes: Consider subtle curved dividers or organic background elements

### Micro-Interactions & Delightful UX
- Smooth Transitions: 200-300ms easing for state changes
- Loading Animations: Skeleton screens and progressive loading
- Pull-to-Refresh: Native mobile gestures that feel natural
- Haptic Feedback: Subtle vibrations for button taps and actions
- Success Animations: Brief celebratory micro-animations for completed purchase.

### Mobile-First Navigation
- Bottom Tab Bar: Keep primary navigation easily thumb-accessible
- Swipe Gestures: Enable swiping between product images, categories
- Search-First Approach: Prominent search bar with smart suggestions
- Quick Actions: Floating action buttons for common tasks (add to cart, wishlist)
- Use Flutter's Go Router for efficient and scalable navigation management.

### Accessibility & Inclusivity
- High Contrast Options: Ensure text meets WCAG standards
- Large Touch Targets: Minimum 44px for interactive elements
- Voice Search: Appeal to multitasking younger users
- Multiple Payment Options: Digital wallets, BNPL, traditional cards

### User-Centric Design
- Intuitive Navigation: Simple, clear paths to key features
- Personalization: Tailored recommendations and experiences
- Seamless Onboarding: Quick, engaging introduction to app features
- Consistent Experience: Uniform design across all platforms


## Typography
- Font Family: Use a modern, sans-serif font like "Poppins" or "Roboto" for a clean look.
- Font Sizes:
  - Headings: 
    - H1: 32px, Bold
    - H2: 24px, Semi-Bold
    - H3: 20px, Medium
  - Body Text: 
    - Regular: 16px, Regular
    - Small: 14px, Regular
- Line Height: 1.5 for body text to ensure readability.
- Letter Spacing: 0.5px for headings, 0.25px for body text.
- Text Alignment: Left-aligned for most content, center-aligned for headings and special sections.