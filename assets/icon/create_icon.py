#!/usr/bin/env python3
"""
Simple script to generate app icons with S-RD text
Requires: pip install pillow
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    import os

    # Icon specifications
    icon_size = 1024  # Standard size for app icons
    bg_color = (72, 106, 255)  # #486AFF
    text_color = (255, 255, 255)  # White
    text = "S-RD"

    # Create main icon
    img = Image.new('RGB', (icon_size, icon_size), color=bg_color)
    draw = ImageDraw.Draw(img)

    # Try to use a nice font, fallback to default
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 400)
    except:
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 400)
        except:
            font = ImageFont.load_default()

    # Get text bounding box and center it
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    x = (icon_size - text_width) // 2
    y = (icon_size - text_height) // 2 - 50  # Slight adjustment

    # Draw text
    draw.text((x, y), text, fill=text_color, font=font)

    # Save main icon
    img.save('app_icon.png', 'PNG')
    print("✅ Created app_icon.png (1024x1024)")

    # Create foreground for adaptive icon (Android)
    # Slightly smaller with transparent background
    fg_img = Image.new('RGBA', (icon_size, icon_size), color=(0, 0, 0, 0))
    fg_draw = ImageDraw.Draw(fg_img)

    # Use slightly smaller font for foreground
    try:
        fg_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 350)
    except:
        try:
            fg_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 350)
        except:
            fg_font = font

    # Center the text
    bbox = fg_draw.textbbox((0, 0), text, font=fg_font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    x = (icon_size - text_width) // 2
    y = (icon_size - text_height) // 2 - 50

    # Draw text on transparent background
    fg_draw.text((x, y), text, fill=text_color, font=fg_font)

    # Save foreground icon
    fg_img.save('app_icon_foreground.png', 'PNG')
    print("✅ Created app_icon_foreground.png (1024x1024)")

    print("\n🎉 Icon files created successfully!")
    print("\nNext steps:")
    print("1. Run: flutter pub get")
    print("2. Run: dart run flutter_launcher_icons")
    print("3. Rebuild your app: flutter run")

except ImportError:
    print("❌ Pillow not installed!")
    print("\nPlease install Pillow first:")
    print("  pip install pillow")
    print("\nOr install using:")
    print("  pip3 install pillow")
    print("\nThen run this script again:")
    print("  python3 create_icon.py")
