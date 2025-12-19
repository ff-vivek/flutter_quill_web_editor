# Example App - Custom Configuration

This example demonstrates how to extend the `quill_web_editor` package with custom configurations, following Flutter web best practices.

## Custom Configuration Files

The example app extends the package configuration to add **Mulish font** support. Instead of duplicating all package files, we only override what's needed:

### 1. `web/js/config-override.js`
Extends the package's `config.js`:
- Adds `'mulish'` to `FONT_WHITELIST`
- Extends `FONT_FAMILY_MAP` with Mulish mappings
- Updates `TOOLBAR_OPTIONS` to include Mulish in the font dropdown

### 2. `web/js/utils-override.js`
Extends the package's `utils.js`:
- Overrides `mapFontFamily()` to use our extended `FONT_FAMILY_MAP` (includes Mulish)

### 3. `web/js/quill-setup-override.js`
Extends the package's `quill-setup.js`:
- Uses custom `FONT_WHITELIST` and `TOOLBAR_OPTIONS` from `config-override.js`
- Creates clipboard matchers that use our custom `mapFontFamily()` function

### 4. `web/js/clipboard-override.js`
Extends the package's `clipboard.js`:
- Uses custom `preprocessHtml()` that includes Mulish font mapping

### 5. `web/styles/mulish-font.css`
Custom CSS file with Mulish font `@font-face` definitions:
- Loads after package CSS for proper override precedence
- Contains all Mulish font weights (200-900) and styles

## File Structure

```
example/web/
├── index.html                    # Flutter app entry point
├── quill_editor.html            # References package assets + custom overrides
├── quill_viewer.html            # References package assets + custom CSS
├── js/                          # Custom override files only
│   ├── config-override.js      # Extends package config
│   ├── utils-override.js       # Extends package utils
│   ├── quill-setup-override.js # Extends package setup
│   └── clipboard-override.js   # Extends package clipboard
└── styles/
    └── mulish-font.css         # Custom font CSS
```

## How It Works

1. **Package Assets**: The main package's JS and CSS files are declared as assets in `pubspec.yaml` and available at:
   - `/assets/packages/quill_web_editor/web/js/...`
   - `/assets/packages/quill_web_editor/web/styles/...`

2. **Custom Overrides**: The example app creates minimal override files that:
   - Import from package assets
   - Extend/override only what's needed
   - Re-export unchanged functionality

3. **CSS Cascade**: Custom CSS (`mulish-font.css`) loads after package CSS, allowing overrides while keeping package styles intact.

## Benefits

✅ **Lean Structure**: Only 4 custom JS files + 1 CSS file (vs 20+ duplicate files)  
✅ **Easy Maintenance**: Package updates automatically reflected  
✅ **Clear Customization**: Shows exactly what was customized  
✅ **Follows Best Practices**: Extends, doesn't duplicate  

## Adding More Customizations

To add more customizations:

1. **Fonts**: Add to `FONT_WHITELIST` in `config-override.js`
2. **Toolbar**: Modify `TOOLBAR_OPTIONS` in `config-override.js`
3. **Styles**: Add CSS files that load after package CSS
4. **Functionality**: Create override files that extend package modules

## References

- [Customizing Package CSS Documentation](../docs/CUSTOMIZING_PACKAGE_CSS_FLUTTER_WEB.md)
- [Example Lean Plan](../docs/EXAMPLE_LEAN_PLAN.md)


