#!/usr/bin/env -S /bin/sh -c "source $(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate&&exec python -E \"$0\" \"$@\""
import argparse
import math
import json
from PIL import Image
from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.score.score import Score
from materialyoucolor.hct import Hct
from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.utils.color_utils import (rgba_from_argb, argb_from_rgb, argb_from_rgba)
from materialyoucolor.utils.math_utils import (sanitize_degrees_double, difference_degrees, rotation_direction)

parser = argparse.ArgumentParser(description='Color generation script')
parser.add_argument('--path', type=str, default=None, help='generate colorscheme from image')
parser.add_argument('--size', type=int , default=128 , help='bitmap image size')
parser.add_argument('--color', type=str, default=None, help='generate colorscheme from color')
parser.add_argument('--mode', type=str, choices=['dark', 'light'], default='dark', help='dark or light mode')
parser.add_argument('--scheme', type=str, default='vibrant', help='material scheme to use')
parser.add_argument('--smart', action='store_true', default=False, help='decide scheme type based on image color')
parser.add_argument('--transparency', type=str, choices=['opaque', 'transparent'], default='opaque', help='enable transparency')
parser.add_argument('--termscheme', type=str, default=None, help='JSON file containg the terminal scheme for generating term colors')
parser.add_argument('--harmony', type=float , default=0.8, help='(0-1) Color hue shift towards accent')
parser.add_argument('--harmonize_threshold', type=float , default=100, help='(0-180) Max threshold angle to limit color hue shift')
parser.add_argument('--term_fg_boost', type=float , default=0.35, help='Make terminal foreground more different from the background')
parser.add_argument('--blend_bg_fg', action='store_true', default=False, help='Shift terminal background or foreground towards accent')
parser.add_argument('--cache', type=str, default=None, help='file path to store the generated color')
parser.add_argument('--debug', action='store_true', default=False, help='debug mode')
args = parser.parse_args()

rgba_to_hex = lambda rgba: "#{:02X}{:02X}{:02X}".format(rgba[0], rgba[1], rgba[2])
argb_to_hex = lambda argb: "#{:02X}{:02X}{:02X}".format(*map(round, rgba_from_argb(argb)))
hex_to_argb = lambda hex_code: argb_from_rgb(int(hex_code[1:3], 16), int(hex_code[3:5], 16), int(hex_code[5:], 16))
display_color = lambda rgba : "\x1B[38;2;{};{};{}m{}\x1B[0m".format(rgba[0], rgba[1], rgba[2], "\x1b[7m   \x1b[7m")

def calculate_optimal_size (width: int, height: int, bitmap_size: int) -> (int, int):
    image_area = width * height;
    bitmap_area = bitmap_size ** 2
    scale = math.sqrt(bitmap_area/image_area) if image_area > bitmap_area else 1
    new_width = round(width * scale)
    new_height = round(height * scale)
    if new_width == 0:
        new_width = 1
    if new_height == 0:
        new_height = 1
    return new_width, new_height

def harmonize (design_color: int, source_color: int, threshold: float = 35, harmony: float = 0.5) -> int:
    from_hct = Hct.from_int(design_color)
    to_hct = Hct.from_int(source_color)
    difference_degrees_ = difference_degrees(from_hct.hue, to_hct.hue)
    rotation_degrees = min(difference_degrees_ * harmony, threshold)
    output_hue = sanitize_degrees_double(
        from_hct.hue + rotation_degrees * rotation_direction(from_hct.hue, to_hct.hue)
    )
    return Hct.from_hct(output_hue, from_hct.chroma, from_hct.tone).to_int()

def boost_chroma_tone (argb: int, chroma: float = 1, tone: float = 1) -> int:
    hct = Hct.from_int(argb)
    return Hct.from_hct(hct.hue, hct.chroma * chroma, hct.tone * tone).to_int()

darkmode = (args.mode == 'dark')
transparent = (args.transparency == 'transparent')

if args.path is not None:
    image = Image.open(args.path)

    if image.format == "GIF":
        image.seek(1)

    if image.mode in ["L", "P"]:
        image = image.convert('RGB')
    wsize, hsize = image.size
    wsize_new, hsize_new = calculate_optimal_size(wsize, hsize, args.size)
    if wsize_new < wsize or hsize_new < hsize:
        image = image.resize((wsize_new, hsize_new), Image.Resampling.BICUBIC)
    colors = QuantizeCelebi(list(image.getdata()), 128)
    argb = Score.score(colors)[0]

    if args.cache is not None:
        with open(args.cache, 'w') as file:
            file.write(argb_to_hex(argb))
    hct = Hct.from_int(argb)
    if(args.smart):
        if(hct.chroma < 20):
            args.scheme = 'neutral'
elif args.color is not None:
    argb = hex_to_argb(args.color)
    hct = Hct.from_int(argb)

if args.scheme == 'scheme-fruit-salad':
    from materialyoucolor.scheme.scheme_fruit_salad import SchemeFruitSalad as Scheme
elif args.scheme == 'scheme-expressive':
    from materialyoucolor.scheme.scheme_expressive import SchemeExpressive as Scheme
elif args.scheme == 'scheme-monochrome':
    from materialyoucolor.scheme.scheme_monochrome import SchemeMonochrome as Scheme
elif args.scheme == 'scheme-rainbow':
    from materialyoucolor.scheme.scheme_rainbow import SchemeRainbow as Scheme
elif args.scheme == 'scheme-tonal-spot':
    from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot as Scheme
elif args.scheme == 'scheme-neutral':
    from materialyoucolor.scheme.scheme_neutral import SchemeNeutral as Scheme
elif args.scheme == 'scheme-fidelity':
    from materialyoucolor.scheme.scheme_fidelity import SchemeFidelity as Scheme
elif args.scheme == 'scheme-content':
    from materialyoucolor.scheme.scheme_content import SchemeContent as Scheme
elif args.scheme == 'scheme-vibrant':
    from materialyoucolor.scheme.scheme_vibrant import SchemeVibrant as Scheme
else:
    from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot as Scheme
# Generate
scheme = Scheme(hct, darkmode, 0.0)

material_colors = {}
term_colors = {}

for color in vars(MaterialDynamicColors).keys():
    color_name = getattr(MaterialDynamicColors, color)
    if hasattr(color_name, "get_hct"):
        rgba = color_name.get_hct(scheme).to_rgba()
        material_colors[color] = rgba_to_hex(rgba)

# Extended material
if darkmode == True:
    material_colors['success'] = '#B5CCBA'
    material_colors['onSuccess'] = '#213528'
    material_colors['successContainer'] = '#374B3E'
    material_colors['onSuccessContainer'] = '#D1E9D6'
else:
    material_colors['success'] = '#4F6354'
    material_colors['onSuccess'] = '#FFFFFF'
    material_colors['successContainer'] = '#D1E8D5'
    material_colors['onSuccessContainer'] = '#0C1F13'

# Terminal Colors - PURPLE MONOCHROMATIC SCHEME
if args.termscheme is not None:
    with open(args.termscheme, 'r') as f:
        json_termscheme = f.read()
    term_source_colors = json.loads(json_termscheme)['dark' if darkmode else 'light']

    # Get primary purple hue - this will be the base for EVERYTHING
    primary_color_argb = hex_to_argb(material_colors['primary_paletteKeyColor'])
    primary_hct = Hct.from_int(primary_color_argb)
    base_hue = primary_hct.hue

    # Define purple color palette with variations in tone and slight chroma
    purple_palette = {
        'term0':  Hct.from_hct(base_hue, min(primary_hct.chroma * 0.5, 20), 4),   # Nearly black purple bg for maximum contrast
        'term1':  Hct.from_hct(base_hue - 20, min(primary_hct.chroma * 1.8, 85), 70), # Red-purple (errors/keywords) - VIBRANT
        'term2':  Hct.from_hct(base_hue + 25, min(primary_hct.chroma * 1.6, 78), 75), # Blue-purple (types/classes) - BRIGHT
        'term3':  Hct.from_hct(base_hue + 5, min(primary_hct.chroma * 2.0, 95), 92), # Light purple (strings) - WHITE-ISH PURPLE
        'term4':  Hct.from_hct(base_hue + 15, min(primary_hct.chroma * 1.8, 88), 78),  # Cyan-purple (functions) - BRIGHT
        'term5':  Hct.from_hct(base_hue - 10, min(primary_hct.chroma * 1.9, 90), 82), # Pink-purple (constants) - VERY SATURATED PINK
        'term6':  Hct.from_hct(base_hue + 20, min(primary_hct.chroma * 1.7, 82), 80), # Aqua-purple (variables) - BRIGHT
        'term7':  Hct.from_hct(base_hue, min(primary_hct.chroma * 0.25, 20), 88),      # Light gray-purple (normal text) - VERY BRIGHT
        'term8':  Hct.from_hct(base_hue, min(primary_hct.chroma * 1.2, 50), 40),      # Medium dark purple (comments darker)
        'term9':  Hct.from_hct(base_hue - 20, min(primary_hct.chroma * 2.0, 95), 88), # Bright red-purple (errors bright) - VERY SATURATED
        'term10': Hct.from_hct(base_hue + 25, min(primary_hct.chroma * 1.9, 90), 90), # Bright blue-purple (types bright) - VERY BRIGHT
        'term11': Hct.from_hct(base_hue + 5, min(primary_hct.chroma * 2.1, 98), 94), # Bright light purple (strings bright) - NEARLY WHITE
        'term12': Hct.from_hct(base_hue + 15, min(primary_hct.chroma * 2.0, 95), 90),  # Bright cyan-purple (functions bright) - VERY BRIGHT
        'term13': Hct.from_hct(base_hue - 10, min(primary_hct.chroma * 2.0, 95), 88), # Bright pink-purple (constants bright) - VIBRANT PINK
        'term14': Hct.from_hct(base_hue + 20, min(primary_hct.chroma * 1.9, 90), 86), # Bright aqua-purple (variables bright) - VERY BRIGHT
        'term15': Hct.from_hct(base_hue - 5, min(primary_hct.chroma * 0.15, 12), 96),      # Nearly pure white with subtle pink tint
    }

    for color in term_source_colors.keys():
        if color in purple_palette:
            term_colors[color] = argb_to_hex(purple_palette[color].to_int())
        else:
            # Fallback - force everything to purple hue
            term_colors[color] = argb_to_hex(Hct.from_hct(base_hue, 40, 70).to_int())

# LazyGit-specific colors - ALL PURPLE SHADES
lazygit_colors = {}
if args.termscheme is not None:
    # Get primary hue for consistency
    primary_hct = Hct.from_int(hex_to_argb(material_colors['primary_paletteKeyColor']))
    base_hue = primary_hct.hue

    # Selection background - much darker, more saturated purple
    lazygit_colors['selectedLineBg'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.6, 65), 15 if darkmode else 88).to_int()
    )

    # Selected range - darker medium purple
    lazygit_colors['selectedRangeBg'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.5, 60), 22 if darkmode else 82).to_int()
    )

    # Inactive border - desaturated purple
    lazygit_colors['inactiveBorder'] = argb_to_hex(
        Hct.from_hct(base_hue, primary_hct.chroma * 0.6, 40 if darkmode else 55).to_int()
    )

    # Active border - vibrant purple
    lazygit_colors['activeBorder'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 1.5, 85), 70 if darkmode else 45).to_int()
    )

    # Options text - bright purple
    lazygit_colors['optionsText'] = argb_to_hex(
        Hct.from_hct(base_hue + 5, min(primary_hct.chroma * 1.4, 75), 75 if darkmode else 40).to_int()
    )

    # Default foreground - light purple-tinted white
    lazygit_colors['defaultFg'] = argb_to_hex(
        Hct.from_hct(base_hue, min(primary_hct.chroma * 0.2, 18), 88 if darkmode else 25).to_int()
    )

    # Cherry picked - slightly shifted purple
    lazygit_colors['cherryPickedBg'] = argb_to_hex(
        Hct.from_hct(base_hue - 10, min(primary_hct.chroma * 1.4, 60), 32 if darkmode else 78).to_int()
    )
    lazygit_colors['cherryPickedFg'] = argb_to_hex(
        Hct.from_hct(base_hue - 10, 12, 90 if darkmode else 20).to_int()
    )

    # Unstaged changes - red-purple (only slightly shifted)
    lazygit_colors['unstagedChanges'] = argb_to_hex(
        Hct.from_hct(base_hue - 20, min(primary_hct.chroma * 1.3, 70), 60 if darkmode else 45).to_int()
    )

# Kitty-specific colors - ALL PURPLE SHADES
kitty_colors = {}
if args.termscheme is not None:
    for i in range(16):
        term_key = f'term{i}'
        if term_key in term_colors:
            kitty_colors[f'color{i}'] = term_colors[term_key]

    # Set background and foreground
    kitty_colors['background'] = term_colors.get('term0', '#000000')
    kitty_colors['foreground'] = term_colors.get('term7', '#FFFFFF')
    kitty_colors['cursor'] = term_colors.get('term7', '#FFFFFF')
    kitty_colors['cursor_text_color'] = term_colors.get('term0', '#000000')
    kitty_colors['selection_background'] = term_colors.get('term8', '#444444')
    kitty_colors['selection_foreground'] = term_colors.get('term15', '#FFFFFF')

if args.debug == False:
    print(f"$darkmode: {darkmode};")
    print(f"$transparent: {transparent};")
    for color, code in material_colors.items():
        print(f"${color}: {code};")
    for color, code in term_colors.items():
        print(f"${color}: {code};")
    for color, code in lazygit_colors.items():
        print(f"$lazygit_{color}: {code};")
    for color, code in kitty_colors.items():
        print(f"$kitty_{color}: {code};")
else:
    if args.path is not None:
        print('\n--------------Image properties-----------------')
        print(f"Image size: {wsize} x {hsize}")
        print(f"Resized image: {wsize_new} x {hsize_new}")
    print('\n---------------Selected color------------------')
    print(f"Dark mode: {darkmode}")
    print(f"Scheme: {args.scheme}")
    print(f"Accent color: {display_color(rgba_from_argb(argb))} {argb_to_hex(argb)}")
    print(f"HCT: {hct.hue:.2f}  {hct.chroma:.2f}  {hct.tone:.2f}")
    print('\n---------------Material colors-----------------')
    for color, code in material_colors.items():
        rgba = rgba_from_argb(hex_to_argb(code))
        print(f"{color.ljust(32)} : {display_color(rgba)}  {code}")
    print('\n----------Terminal colors (Purple Mono)--------')
    for color, code in term_colors.items():
        rgba = rgba_from_argb(hex_to_argb(code))
        print(f"{color.ljust(6)} : {display_color(rgba)}  {code}")
    print('\n--------------LazyGit colors (Purple)---------')
    for color, code in lazygit_colors.items():
        rgba = rgba_from_argb(hex_to_argb(code))
        print(f"{color.ljust(20)} : {display_color(rgba)}  {code}")
    print('-----------------------------------------------')
