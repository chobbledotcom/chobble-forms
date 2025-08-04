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

## Type Safety with Sorbet

ChobbleForms includes full Sorbet type signatures for improved type safety and better IDE support. The gem uses `typed: strict` for all library files and gracefully degrades when Sorbet is not available.

### Using Sorbet in Your Application

To enable type checking when using ChobbleForms in your Rails application:

1. Add Sorbet to your Gemfile:
   ```ruby
   gem 'sorbet-runtime'
   group :development do
     gem 'sorbet'
     gem 'tapioca'
   end
   ```

2. Run type checking:
   ```bash
   bundle exec srb tc
   ```

### Development Setup

For contributors working on this gem:

1. Install dependencies: `bundle install`
2. Add Sorbet gems manually: `bundle add sorbet-runtime sorbet tapioca`
3. Generate RBI files: `bundle exec rake sorbet_rbi`
4. Run type checking: `bundle exec rake typecheck`

Note: The gem works perfectly without Sorbet installed. Type signatures are only active when `sorbet-runtime` is available.

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