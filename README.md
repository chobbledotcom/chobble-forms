# Chobble Forms

Semantic Rails forms with strict i18n enforcement.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chobble-forms'
```

And then execute:

```bash
bundle install
```

## CSS Styles

ChobbleForms includes CSS for styling the form components. To use the included styles, add this to your application.css:

```css
/*
 *= require chobble_forms
 */
```

The CSS includes:

- **Form Grids**: Responsive grid layouts for various form field combinations
- **Form Fields**: Styling for inputs, textareas, and labels
- **Radio Buttons**: Custom radio button appearance with pass/fail color coding
- **Flash Messages**: Styled success, error, notice, and alert messages

### CSS Variables

The CSS uses the following CSS variables that you can override in your application:

- `--color-primary`: Primary color for hover states (default: #118bee)
- `--color-pass`: Pass/success color (default: #00a94f)
- `--color-fail`: Fail/error color (default: #d32f2f)
- `--color-disabled`: Disabled state color (default: #959495)