#!/usr/bin/env -S /bin/sh -c "source $(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate&&exec python -E \"$0\" \"$@\""
import argparse
import math
import json
import os
from PIL import Image
from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.score.score import Score
from materialyoucolor.hct import Hct
from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.utils.color_utils import (rgba_from_argb, argb_from_rgb, argb_from_rgba)
from materialyoucolor.utils.math_utils import (sanitize_degrees_double, difference_degrees, rotation_direction)

scss_out = os.path.expanduser("~/.local/state/quickshell/user/generated/material_colors.scss")
os.makedirs(os.path.dirname(scss_out), exist_ok=True)

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

import os
from pathlib import Path

def load_catppuccin_palette(path: str) -> dict:
    with open(path, "r") as f:
        return json.load(f)

def harmonize_hex(
    hex_color: str,
    accent_argb: int,
    harmony_amt: float,
    threshold: float
) -> str:
    """
    Preserve Catppuccin tone & chroma.
    ONLY nudge hue toward accent.
    """
    base_argb = hex_to_argb(hex_color)
    out_argb = harmonize(
        base_argb,
        accent_argb,
        threshold=threshold,
        harmony=harmony_amt,
    )
    return argb_to_hex(out_argb)

def clamp_chroma(argb: int, max_chroma: float) -> int:
    hct = Hct.from_int(argb)
    return Hct.from_hct(
        hct.hue,
        min(hct.chroma, max_chroma),
        hct.tone
    ).to_int()

def force_tone(argb: int, tone: float) -> int:
    hct = Hct.from_int(argb)
    return Hct.from_hct(hct.hue, hct.chroma, tone).to_int()

def boost_saturation(argb: int, multiplier: float = 1.5) -> int:
    """Boost chroma for more vibrant colors"""
    hct = Hct.from_int(argb)
    return Hct.from_hct(hct.hue, min(hct.chroma * multiplier, 100), hct.tone).to_int()

def lift_tone(argb: int, delta: float) -> int:
    """
    Increase brightness ONLY.
    Preserves hue and chroma.
    """
    hct = Hct.from_int(argb)
    return Hct.from_hct(
        hct.hue,
        hct.chroma,
        min(hct.tone + delta, 100)
    ).to_int()


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
# Terminal Colors - Harmonized with wallpaper accent
if args.termscheme is not None:
    with open(args.termscheme, 'r') as f:
        json_termscheme = f.read()
    term_source_colors = json.loads(json_termscheme)['dark' if darkmode else 'light']

    # Use the SAME accent as Neovim harmonization
    accent_hct = hct  # <- This is from your wallpaper image!
    base_hue = accent_hct.hue
    base_chroma = accent_hct.chroma

    # Define color palette harmonized with wallpaper
    term_palette = {
        'term0':  Hct.from_hct(base_hue, min(base_chroma * 0.6, 25), 6),

        # RED (term1) - Shift toward red from accent
        'term1':  Hct.from_hct(base_hue - 12, min(base_chroma * 0.8, 45), 58),

        # GREEN (term2) - Shift toward cyan from accent
        'term2':  Hct.from_hct(base_hue + 25, min(base_chroma * 0.9, 48), 62),

        'term3':  Hct.from_hct(base_hue + 5, min(base_chroma * 2.0, 95), 92),
        'term4':  Hct.from_hct(base_hue + 5, min(base_chroma * 1.7, 85), 82),
        'term5':  Hct.from_hct(base_hue - 5, min(base_chroma * 1.8, 88), 80),
        'term6':  Hct.from_hct(base_hue + 10, min(base_chroma * 1.7, 85), 82),
        'term7':  Hct.from_hct(base_hue, min(base_chroma * 0.25, 20), 88),
        'term8':  Hct.from_hct(base_hue, min(base_chroma * 1.0, 42), 35),

        'term9':  Hct.from_hct(base_hue - 12, min(base_chroma * 1.0, 55), 68),
        'term10': Hct.from_hct(base_hue + 25, min(base_chroma * 1.1, 58), 70),
        'term11': Hct.from_hct(base_hue + 5, min(base_chroma * 2.0, 95), 92),
        'term12': Hct.from_hct(base_hue + 5, min(base_chroma * 1.8, 88), 88),
        'term13': Hct.from_hct(base_hue - 5, min(base_chroma * 1.8, 88), 87),
        'term14': Hct.from_hct(base_hue + 10, min(base_chroma * 1.7, 85), 86),
        'term15': Hct.from_hct(base_hue, min(base_chroma * 0.12, 10), 96),
    }

    for color in term_source_colors.keys():
        if color in term_palette:
            term_colors[color] = argb_to_hex(term_palette[color].to_int())
        else:
            # Fallback
            term_colors[color] = argb_to_hex(Hct.from_hct(base_hue, 40, 70).to_int())


# LazyGit-specific colors - ALL PURPLE SHADES
lazygit_colors = {}
if args.termscheme is not None:
    # Get primary hue for consistency
    primary_hct = Hct.from_int(hex_to_argb(material_colors['primary_paletteKeyColor']))
    base_hue = primary_hct.hue

    # Selection background - darker, more saturated purple
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

    # DIFF COLORS - Subtle purple-tinted versions
    # Deletions (red) - desaturated red-purple, subtle
    lazygit_colors['unstagedChanges'] = argb_to_hex(
        Hct.from_hct(
            base_hue - 12,  # Slight shift towards red
            min(primary_hct.chroma * 0.8, 45),  # Low saturation
            58 if darkmode else 52
        ).to_int()
    )

    # Additions (green) - desaturated blue-purple/teal, subtle
    lazygit_colors['stagedChanges'] = argb_to_hex(
        Hct.from_hct(
            base_hue + 25,  # Slight shift towards cyan
            min(primary_hct.chroma * 0.9, 48),  # Low saturation
            62 if darkmode else 48
        ).to_int()
    )

    # Modified/changed sections - use term3 (light purple)
    lazygit_colors['diffModified'] = term_colors['term3']

    # Context lines - use term7 (normal text)
    lazygit_colors['diffContext'] = term_colors['term7']

    # Search / diff emphasis - soft purple
    lazygit_colors['searchMatching'] = argb_to_hex(
        Hct.from_hct(
            base_hue + 8,
            min(primary_hct.chroma * 1.2, 65),
            72 if darkmode else 55
        ).to_int()
    )

    # Default text color - use term7
    lazygit_colors['defaultText'] = term_colors['term7']

    # Conflict colors - all subtle purples
    lazygit_colors['conflictOurs'] = argb_to_hex(
        Hct.from_hct(base_hue + 20, min(primary_hct.chroma * 0.85, 50), 60 if darkmode else 50).to_int()
    )
    lazygit_colors['conflictTheirs'] = argb_to_hex(
        Hct.from_hct(base_hue - 15, min(primary_hct.chroma * 0.85, 50), 56 if darkmode else 48).to_int()
    )
    lazygit_colors['conflictBase'] = term_colors['term3']

# Generate Git diff colors configuration
if args.termscheme is not None and lazygit_colors:
    import subprocess

    # Use the same colors we generated for LazyGit diffs
    git_diff_colors = {
        'old': lazygit_colors['unstagedChanges'],
        'new': lazygit_colors['stagedChanges'],
        'meta': term_colors['term4'],  # Purple info color
        'frag': term_colors['term4'],  # Purple info color
        'commit': term_colors['term5'], # Pink-purple
    }

    # Set git config colors
    try:
        for key, color in git_diff_colors.items():
            subprocess.run(
                ['git', 'config', '--global', f'color.diff.{key}', color],
                check=True
            )

        # Also set diff-highlight colors (for better diffs)
        subprocess.run(['git', 'config', '--global', 'color.diff-highlight.oldNormal', git_diff_colors['old']], check=True)
        subprocess.run(['git', 'config', '--global', 'color.diff-highlight.newNormal', git_diff_colors['new']], check=True)

        # Status colors
        subprocess.run(['git', 'config', '--global', 'color.status.added', git_diff_colors['new']], check=True)
        subprocess.run(['git', 'config', '--global', 'color.status.deleted', git_diff_colors['old']], check=True)
        subprocess.run(['git', 'config', '--global', 'color.status.changed', git_diff_colors['meta']], check=True)

        if args.debug:
            print("\nGit diff colors configured:")
            print(f"  Deletions (red): {git_diff_colors['old']}")
            print(f"  Additions (green): {git_diff_colors['new']}")
            print(f"  Metadata: {git_diff_colors['meta']}")
    except subprocess.CalledProcessError as e:
        if args.debug:
            print(f"Warning: Could not set git config colors: {e}")
    except FileNotFoundError:
        if args.debug:
            print("Warning: git command not found, skipping git color configuration")

# Neovim colors - Catppuccin Mocha harmonized with Material You
neovim_colors = {}
if args.termscheme is not None:
    # Load real Catppuccin Mocha palette
    cat = load_catppuccin_palette(os.path.expanduser("~/.config/quickshell/ii/scripts/colors/Colors.json"))

    accent_argb = hex_to_argb(material_colors["primary_paletteKeyColor"])

    # VERY gentle harmonization
    BG_HARMONY = 0.88
    UI_HARMONY = 0.15
    SYNTAX_HARMONY = 0.75 #lower is more harmony
    TEXT_HARMONY = 0.46

    BG_THRESH = 05.0
    UI_THRESH = 10.0
    SYNTAX_THRESH = 40.55 #less is more contr
    TEXT_THRESH = 8.0

    # Background / surfaces (keep Mocha depth)
    neovim_colors["base"] = (
        "NONE" if transparent else harmonize_hex(cat["base"], accent_argb, BG_HARMONY, BG_THRESH)
    )
    for k in ["mantle", "crust", "surface0", "surface1", "surface2",
              "overlay0", "overlay1", "overlay2"]:
        neovim_colors[k] = harmonize_hex(cat[k], accent_argb, UI_HARMONY, UI_THRESH)

    # Text
    for k in ["text", "subtext0", "subtext1"]:
        neovim_colors[k] = harmonize_hex(cat[k], accent_argb, TEXT_HARMONY, TEXT_THRESH)

    # Syntax accents (PASTEL, controlled)
    syntax_colors = {
        "rosewater": (SYNTAX_HARMONY, SYNTAX_THRESH, 75),  # Medium-high chroma
        "flamingo": (SYNTAX_HARMONY, SYNTAX_THRESH, 76),
        "pink": (SYNTAX_HARMONY, SYNTAX_THRESH, 75),       # High chroma
        "mauve": (SYNTAX_HARMONY, SYNTAX_THRESH, 72),
        "red": (SYNTAX_HARMONY, SYNTAX_THRESH, 65),
        "maroon": (SYNTAX_HARMONY, SYNTAX_THRESH, 60),
        "peach": (SYNTAX_HARMONY, SYNTAX_THRESH, 70),
        "yellow": (SYNTAX_HARMONY, SYNTAX_THRESH, 75),     # High chroma
        "green": (SYNTAX_HARMONY, SYNTAX_THRESH, 70),
        "teal": (SYNTAX_HARMONY, SYNTAX_THRESH, 72),       # High chroma
        "sky": (SYNTAX_HARMONY, SYNTAX_THRESH, 68),
        "sapphire": (SYNTAX_HARMONY, SYNTAX_THRESH, 80),
        "blue": (SYNTAX_HARMONY, SYNTAX_THRESH, 78),
        "lavender": (SYNTAX_HARMONY, SYNTAX_THRESH, 75),
    }

    for k, (harmony, thresh, max_chroma) in syntax_colors.items():
        raw = harmonize_hex(cat[k], accent_argb, harmony, thresh)
        neovim_colors[k] = argb_to_hex(
            clamp_chroma(hex_to_argb(raw), max_chroma=max_chroma)
        )

    # ------------------------------------------------
    # FINAL SYNTAX BRIGHTNESS LIFT (NO SATURATION CHANGE)
    # ------------------------------------------------
    SYNTAX_TONE_LIFT = 0.5  # try 4–8 range

    for k in syntax_colors.keys():
        neovim_colors[k] = argb_to_hex(
            lift_tone(hex_to_argb(neovim_colors[k]), SYNTAX_TONE_LIFT)
        )

    # Force specific tones for better contrast and vibrancy
    TONE_MAP = {
        "mauve": 65,      # Brighter
        "blue": 71,       # Brighter
        "green": 78,      # Brighter
        "teal": 80,       # Very bright
        "yellow": 85,     # Very bright
        "pink": 78,       # Brighter
        "sapphire": 73,   # Medium-bright
    }

    for k, tone in TONE_MAP.items():
        neovim_colors[k] = argb_to_hex(
            force_tone(hex_to_argb(neovim_colors[k]), tone)
        )

def boost_for_rainbow(argb: int, chroma_boost=1.4, min_tone=70) -> str:
    hct = Hct.from_int(argb)
    return argb_to_hex(
        Hct.from_hct(
            hct.hue,
            min(hct.chroma * chroma_boost, 90),
            max(hct.tone, min_tone)
        ).to_int()
    )

def force_vivid_dark(argb: int, chroma: float, tone: float) -> str:
    hct = Hct.from_int(argb)
    return argb_to_hex(
        Hct.from_hct(
            hct.hue,
            min(chroma, 95),
            tone
        ).to_int()
    )


rainbow_colors = {
    "red":    boost_for_rainbow(hex_to_argb(neovim_colors["red"]),     1.3, 68),
    "orange": boost_for_rainbow(hex_to_argb(neovim_colors["peach"]),   1.4, 72),
    "yellow": boost_for_rainbow(hex_to_argb(neovim_colors["yellow"]),  1.6, 82),
    "green":  boost_for_rainbow(hex_to_argb(neovim_colors["green"]),   1.3, 74),
    "cyan":   boost_for_rainbow(hex_to_argb(neovim_colors["teal"]),    1.4, 76),

    # 🔥 FIXED PROBLEM CHILDREN
    "blue": force_vivid_dark(
        hex_to_argb(neovim_colors["sky"]),
        chroma=70,
        tone=74
    ),

    "violet": force_vivid_dark(
        hex_to_argb(neovim_colors["mauve"]),
        chroma=95,
        tone=66
    ),
}


# Generate Neovim colorscheme file
if args.termscheme is not None and neovim_colors:
    nvim_colors_dir = Path.home() / '.config' / 'nvim' / 'colors'
    nvim_colors_dir.mkdir(parents=True, exist_ok=True)
    nvim_output = str(nvim_colors_dir / 'material_purple_mocha.lua')

    nvim_theme_content = f'''-- Auto-generated Neovim colorscheme
-- Vibrant LSP-semantic based theme with Material You + Catppuccin Mocha

vim.cmd("hi clear")
vim.cmd("syntax reset")

vim.o.termguicolors = true
vim.g.colors_name = "material_purple_mocha"

local colors = {{
  -- Base colors
  base = "{neovim_colors['base']}",
  mantle = "{neovim_colors['mantle']}",
  crust = "{neovim_colors['crust']}",

  -- Surface colors
  surface0 = "{neovim_colors['surface0']}",
  surface1 = "{neovim_colors['surface1']}",
  surface2 = "{neovim_colors['surface2']}",

  -- Overlay colors
  overlay0 = "{neovim_colors['overlay0']}",
  overlay1 = "{neovim_colors['overlay1']}",
  overlay2 = "{neovim_colors['overlay2']}",

  -- Text colors
  text = "{neovim_colors['text']}",
  subtext1 = "{neovim_colors['subtext1']}",
  subtext0 = "{neovim_colors['subtext0']}",

  -- Accent colors (VIBRANT)
  rosewater = "{neovim_colors['rosewater']}",
  flamingo = "{neovim_colors['flamingo']}",
  pink = "{neovim_colors['pink']}",
  mauve = "{neovim_colors['mauve']}",
  red = "{neovim_colors['red']}",
  maroon = "{neovim_colors['maroon']}",
  peach = "{neovim_colors['peach']}",
  yellow = "{neovim_colors['yellow']}",
  green = "{neovim_colors['green']}",
  teal = "{neovim_colors['teal']}",
  sky = "{neovim_colors['sky']}",
  sapphire = "{neovim_colors['sapphire']}",
  blue = "{neovim_colors['blue']}",
  lavender = "{neovim_colors['lavender']}",
}}

local function hi(group, opts)
  local cmd = {{"highlight", group}}
  if opts.fg then table.insert(cmd, "guifg=" .. opts.fg) end
  if opts.bg then table.insert(cmd, "guibg=" .. opts.bg) end
  if opts.sp then table.insert(cmd, "guisp=" .. opts.sp) end
  if opts.style then table.insert(cmd, "gui=" .. opts.style) end
  if opts.link then
    vim.cmd(string.format("highlight! link %s %s", group, opts.link))
  else
    vim.cmd(table.concat(vim.tbl_flatten(cmd), " "))
  end
end

-- ============================================================================
-- BASE UI ELEMENTS
-- ============================================================================
local function setup_highlights()
    hi("Normal", {{ fg = colors.text, bg = "NONE" }})
    hi("NormalFloat", {{ fg = colors.text, bg = colors.mantle }})
    hi("FloatBorder", {{ fg = colors.lavender, bg = "NONE"}})
    hi("FloatTitle", {{ fg = colors.mauve, bg = "NONE", style = "bold,italic" }})
    hi("Folded", {{ fg = "NONE", bg = "NONE" }})
    hi("FoldColumn", {{ fg = colors.red }})
    hi("UfoFoldedBg", {{ fg = colors.lavender }})
    hi("UfoFoldedFg", {{ fg = colors.lavender }})

    hi("Cursor", {{ fg = "NONE", bg = colors.text }})
    hi("CursorLine", {{ bg = "NONE" }})
    hi("CursorColumn", {{ bg = "NONE" }})
    hi("ColorColumn", {{ bg = "NONE" }})
    hi("CursorLineNr", {{ fg = colors.lavender, style = "bold" }})
    hi("LineNr", {{ fg = colors.overlay0 }})
    hi("LineNrAbove", {{ fg = colors.mauve }})
    hi("LineNrBelow", {{ fg = colors.mauve }})
    hi("SignColumn", {{ bg = "NONE" }})
    hi("EndOfBuffer", {{ fg = colors.lavender }})
    hi("NonText", {{ fg = colors.lavender }})

    hi("StatusLine", {{ fg = colors.text, bg = "NONE" }})
    hi("StatusLineNC", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("VertSplit", {{ fg = colors.surface0, bg = "NONE" }})
    hi("WinSeparator", {{ fg = colors.surface0, bg = "NONE" }})

    hi("Search", {{ fg = colors.red, bg = colors.mantle }})
    hi("IncSearch", {{ fg = "NONE", bg = colors.mantle }})
    hi("CurSearch", {{ fg = "NONE", bg = colors.mantle }})
    hi("Visual", {{ bg = colors.surface1 }})
    hi("VisualNOS", {{ bg = colors.surface1 }})

    hi("Pmenu", {{ fg = colors.text, bg = "NONE" }})
    hi("PmenuSel", {{ fg = "NONE", bg = colors.surface1, style = "bold" }})
    hi("PmenuSbar", {{ bg = "NONE"}})
    hi("PmenuThumb", {{ bg = "NONE" }})
    hi("PmenuBorder", {{ fg = colors.lavender, bg = "NONE" }})

    -- Completion menu kind highlights (nvim-cmp)
    hi("CmpItemKindVariable", {{ fg = colors.text, bg = "NONE" }})
    hi("CmpItemKindFunction", {{ fg = colors.blue, bg = "NONE" }})
    hi("CmpItemKindMethod", {{ fg = colors.blue, bg = "NONE" }})
    hi("CmpItemKindConstructor", {{ fg = colors.sapphire, bg = "NONE" }})
    hi("CmpItemKindClass", {{ fg = colors.yellow, bg = "NONE" }})
    hi("CmpItemKindInterface", {{ fg = colors.yellow, bg = "NONE" }})
    hi("CmpItemKindStruct", {{ fg = colors.yellow, bg = "NONE" }})
    hi("CmpItemKindEnum", {{ fg = colors.peach, bg = "NONE" }})
    hi("CmpItemKindEnumMember", {{ fg = colors.teal, bg = "NONE" }})
    hi("CmpItemKindModule", {{ fg = colors.sapphire, bg = "NONE" }})
    hi("CmpItemKindProperty", {{ fg = colors.teal, bg = "NONE" }})
    hi("CmpItemKindField", {{ fg = colors.teal, bg = "NONE" }})
    hi("CmpItemKindTypeParameter", {{ fg = colors.flamingo, bg = "NONE" }})
    hi("CmpItemKindConstant", {{ fg = colors.teal, bg = "NONE" }})
    hi("CmpItemKindKeyword", {{ fg = colors.mauve, bg = "NONE" }})
    hi("CmpItemKindSnippet", {{ fg = colors.pink, bg = "NONE" }})
    hi("CmpItemKindText", {{ fg = colors.green, bg = "NONE" }})
    hi("CmpItemKindFile", {{ fg = colors.blue, bg = "NONE" }})
    hi("CmpItemKindFolder", {{ fg = colors.blue, bg = "NONE" }})
    hi("CmpItemKindColor", {{ fg = colors.peach, bg = "NONE" }})
    hi("CmpItemKindReference", {{ fg = colors.peach, bg = "NONE" }})
    hi("CmpItemKindOperator", {{ fg = colors.sky, bg = "NONE" }})
    hi("CmpItemKindUnit", {{ fg = colors.peach, bg = "NONE" }})
    hi("CmpItemKindValue", {{ fg = colors.peach, bg = "NONE" }})

    -- Completion item highlights
    hi("CmpItemAbbr", {{ fg = colors.text, bg = "NONE" }})
    hi("CmpItemAbbrDeprecated", {{ fg = colors.overlay0, bg = "NONE", style = "strikethrough" }})
    hi("CmpItemAbbrMatch", {{ fg = colors.blue, bg = "NONE", style = "bold" }})
    hi("CmpItemAbbrMatchFuzzy", {{ fg = colors.blue, bg = "NONE" }})
    hi("CmpItemMenu", {{ fg = colors.subtext0, bg = "NONE", style = "italic" }})

    hi("TabLine", {{ fg = colors.subtext0, bg = colors.mantle }})
    hi("TabLineFill", {{ bg = "NONE" }})
    hi("TabLineSel", {{ fg = colors.mauve, bg = "NONE" }})

    -- ============================================================================
    -- TREESITTER BASE SYNTAX (Fallbacks when LSP not available)
    -- ============================================================================
    hi("@variable", {{ fg = colors.text }})
    hi("@variable.builtin", {{ fg = colors.red, style = "italic" }})
    hi("@variable.parameter", {{ fg = colors.maroon, style = "italic" }})
    hi("@variable.member", {{ fg = colors.teal }})

    hi("@constant", {{ fg = colors.teal }})
    hi("@constant.builtin", {{ fg = colors.red, style = "italic" }})
    hi("@constant.macro", {{ fg = colors.sapphire }})

    hi("@module", {{ fg = colors.sapphire, style = "italic" }})
    hi("@label", {{ fg = colors.sapphire }})

    hi("@string", {{ fg = colors.green }})
    hi("@string.escape", {{ fg = colors.pink }})
    hi("@string.regexp", {{ fg = colors.pink }})
    hi("@character", {{ fg = colors.teal }})
    hi("@character.special", {{ fg = colors.pink }})

    hi("@number", {{ fg = colors.peach }})
    hi("@number.float", {{ fg = colors.peach }})
    hi("@boolean", {{ fg = colors.peach }})

    hi("@function", {{ fg = colors.blue, style = "bold" }})
    hi("@function.builtin", {{ fg = colors.blue, style = "italic" }})
    hi("@function.macro", {{ fg = colors.mauve }})
    hi("@function.method", {{ fg = colors.blue, style = "bold" }})
    hi("@function.method.call", {{ fg = colors.blue }})

    hi("@constructor", {{ fg = colors.sapphire }})
    hi("@operator", {{ fg = "#00ffff" }})
    hi("@operator.java", {{ fg = "#00ffff" }})

    hi("@keyword", {{ fg = colors.mauve, style = "bold" }})
    hi("@keyword.repeat.java", {{ fg = colors.mauve, style = "italic,bold"}})
    hi("@keyword.conditional", {{ fg = colors.mauve, style = "bold,italic" }})
    hi("@keyword.function", {{ fg = colors.mauve, style = "bold" }})
    hi("@keyword.operator", {{ fg = colors.mauve }})
    hi("@keyword.return", {{ fg = colors.mauve, style = "bold" }})

    hi("@type", {{ fg = colors.yellow }})
    hi("@type.builtin", {{ fg = colors.yellow, style = "italic" }})
    hi("@type.qualifier", {{ fg = colors.mauve, style = "italic" }})

    hi("@property", {{ fg = colors.teal }})
    hi("@attribute", {{ fg = colors.yellow, style = "italic" }})
    hi("@namespace", {{ fg = colors.sapphire, style = "italic" }})

    hi("@punctuation.delimiter", {{ fg = colors.overlay2 }})
    hi("@punctuation.bracket", {{ fg = colors.overlay2 }})
    hi("@punctuation.special", {{ fg = colors.sky }})

    hi("@comment", {{ fg = colors.pink, style = "italic" }})
    hi("@comment.todo", {{ fg = colors.yellow, bg = colors.surface0, style = "bold" }})
    hi("@comment.note", {{ fg = colors.blue, bg = colors.surface0, style = "bold" }})
    hi("@comment.warning", {{ fg = colors.peach, bg = colors.surface0, style = "bold" }})
    hi("@comment.error", {{ fg = colors.red, bg = colors.surface0, style = "bold" }})

    hi("@tag", {{ fg = colors.mauve }})
    hi("@tag.attribute", {{ fg = colors.teal, style = "italic" }})
    hi("@tag.delimiter", {{ fg = colors.overlay2 }})

    -- ============================================================================
    -- LSP SEMANTIC TOKENS (Primary highlighting - overrides Treesitter)
    -- ============================================================================

    -- Variables and Parameters
    hi("@lsp.type.variable", {{ fg = colors.text }})
    hi("@lsp.type.parameter", {{ fg = colors.red, style = "italic" }})
    hi("@lsp.typemod.variable.readonly", {{ fg = colors.teal }})
    hi("@lsp.typemod.variable.declaration", {{ fg = colors.maroon, style = "italic" }})
    hi("@lsp.typemod.variable.static", {{ fg = colors.flamingo }})
    hi("@lsp.typemod.variable.global", {{ fg = colors.flamingo }})

    -- Properties and Fields
    hi("@lsp.type.property", {{ fg = colors.text }})
    hi("@lsp.typemod.property.static", {{ fg = colors.teal, style = "italic" }})
    hi("@lsp.typemod.property.static.java", {{ fg = colors.teal, style = "italic,bold" }})

    -- Functions and Methods
    hi("@lsp.type.function", {{ fg = colors.blue, style = "bold" }})
    hi("@lsp.type.method.java", {{ fg = colors.sapphire, style = "italic" }})
    hi("@lsp.type.method", {{ fg = colors.sapphire, style = "bold" }})
    hi("@lsp.typemod.function.static", {{ fg = colors.sky, style = "bold" }})
    hi("@lsp.typemod.method.static", {{ fg = colors.sapphire, style = "italic" }})

    -- Types and Classes
    hi("@lsp.type.class", {{ fg = colors.yellow, style = "bold" }})
    hi("@lsp.type.interface", {{ fg = colors.yellow, style = "italic" }})
    hi("@lsp.type.struct", {{ fg = colors.yellow }})
    hi("@lsp.type.enum", {{ fg = colors.peach }})
    hi("@lsp.type.enumMember", {{ fg = colors.teal }})
    hi("@lsp.type.type", {{ fg = colors.yellow }})
    hi("@lsp.type.typeParameter", {{ fg = colors.flamingo, style = "italic" }})

    -- Namespaces and Modules
    hi("@lsp.type.namespace", {{ fg = colors.sapphire, style = "italic" }})
    hi("@lsp.type.namespace.java", {{ fg = colors.sapphire, style = "italic" }})
    hi("@lsp.mod.importDeclaration", {{ fg = colors.yellow, style = "italic" }})
    hi("@lsp.mod.importDeclaration.java", {{ fg = colors.yellow, style = "italic" }})
    hi("@lsp.typemod.namespace.importDeclaration.java", {{ fg = colors.yellow, style = "italic" }})

    -- Macros and Preprocessor
    hi("@lsp.type.macro", {{ fg = colors.sapphire }})
    hi("@lsp.typemod.macro.globalScope", {{ fg = colors.sapphire }})
    hi("@lsp.typemod.macro.globalScope.cpp", {{ fg = colors.sapphire }})

    -- Decorators and Annotations
    hi("@lsp.type.decorator", {{ fg = colors.yellow, style = "italic" }})
    hi("@lsp.type.annotation", {{ fg = colors.yellow, style = "italic" }})

    -- Keywords (when LSP provides them)
    hi("@lsp.type.keyword", {{ fg = colors.mauve, style = "bold" }})
    hi("@lsp.typemod.keyword.controlFlow", {{ fg = colors.pink, style = "bold" }})

    -- ============================================================================
    -- DIAGNOSTIC
    -- ============================================================================
    hi("DiagnosticError", {{ fg = colors.red }})
    hi("DiagnosticWarn", {{ fg = colors.yellow }})
    hi("DiagnosticInfo", {{ fg = colors.blue }})
    hi("DiagnosticHint", {{ fg = colors.teal }})
    hi("DiagnosticOk", {{ fg = colors.green }})

    hi("DiagnosticVirtualTextError", {{ fg = colors.red, bg = "NONE" }})
    hi("DiagnosticVirtualTextWarn", {{ fg = colors.yellow, bg = "NONE" }})
    hi("DiagnosticVirtualTextInfo", {{ fg = colors.blue, bg = "NONE" }})
    hi("DiagnosticVirtualTextHint", {{ fg = colors.teal, bg = "NONE" }})

    hi("DiagnosticUnderlineError", {{ sp = colors.red, style = "undercurl" }})
    hi("DiagnosticUnderlineWarn", {{ sp = colors.yellow, style = "undercurl" }})
    hi("DiagnosticUnderlineInfo", {{ sp = colors.blue, style = "undercurl" }})
    hi("DiagnosticUnderlineHint", {{ sp = colors.teal, style = "undercurl" }})

    -- ============================================================================
    -- LSP REFERENCES
    -- ============================================================================
    hi("LspReferenceText", {{ bg = colors.mantle }})
    hi("LspReferenceRead", {{ bg = colors.mantle }})
    hi("LspReferenceWrite", {{ bg = colors.surface0, style = "bold" }})

    hi("MatchParen", {{ bg = colors.mantle }})
    hi("MatchParenCur", {{ bg = colors.mantle }})

    -- ============================================================================
    -- PLUGIN: TELESCOPE
    -- ============================================================================
    hi("TelescopeBorder", {{ fg = colors.lavender, bg = "NONE" }})
    hi("TelescopePromptBorder", {{ fg = colors.mauve, bg = "NONE"}})
    hi("TelescopeResultsBorder", {{ fg = colors.lavender, bg = "NONE" }})
    hi("TelescopePreviewBorder", {{ fg = colors.lavender, bg = "NONE" }})
    hi("TelescopeSelection", {{ fg = colors.surface0, bg = colors.mauve, style = "bold" }})
    hi("TelescopeSelectionCaret", {{ fg = colors.mauve, bg = colors.surface0 }})
    hi("TelescopeMatching", {{ fg = colors.blue }})

    -- ============================================================================
    -- PLUGIN: NVIM-TREE / NEO-TREE
    -- ============================================================================
    hi("NvimTreeNormal", {{ fg = colors.text, bg = "NONE" }})
    hi("NvimTreeFolderIcon", {{ fg = colors.mauve }})
    hi("NvimTreeFolderName", {{ fg = colors.sapphire }})
    hi("NvimTreeOpenedFolderName", {{ fg = colors.blue, bold = true }})
    hi("NvimTreeIndentMarker", {{ fg = colors.overlay0 }})
    hi("NvimTreeGitDirty", {{ fg = colors.yellow }})
    hi("NvimTreeGitNew", {{ fg = colors.green }})
    hi("NvimTreeGitDeleted", {{ fg = colors.red }})

    hi("NeoTreeTabActive", {{ fg = colors.mauve, bg = "NONE" }})
    hi("NeoTreeGitUntracked", {{ fg = colors.red }})
    hi("NeoTreeTabInactive", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("NeoTreeTabSeparatorActive", {{ fg = colors.surface0, bg = "NONE" }})
    hi("NeoTreeTabSeparatorInactive", {{ fg = colors.surface0, bg = "NONE" }})
    hi("NeoTreeDirectoryIcon", {{ fg = colors.mauve }})
    hi("NeoTreeDirectoryName", {{ fg = colors.sky }})
    hi("NeoTreeCursorLine", {{ fg = colors.red }})

    hi("DressingInput", {{ fg = colors.text, bg = colors.mantle }})
    hi("DressingInputBorder", {{ fg = colors.lavender, bg = "NONE" }})
    hi("DressingInputTitle", {{ fg = colors.mauve, bg = "NONE", style = "bold" }})
    hi("DressingInputPrompt", {{ fg = colors.text, bg = "NONE" }})  -- This is the key one!
    hi("DressingInputText", {{ fg = colors.text, bg = "NONE" }})
    hi("Prompt", {{ fg = colors.text, bg = "NONE" }})
    hi("Question", {{ fg = colors.text, bg = "NONE" }})

    -- ============================================================================
    -- PLUGIN: INDENT-BLANKLINE
    -- ============================================================================
    hi("IblIndent", {{ fg = colors.red }})
    hi("IblScope", {{ fg = colors.mauve }})
    hi("MiniIndentscopeSymbol", {{ fg = colors.lavender }} )
    hi("MiniIndentscopeSymbolOff", {{ fg = colors.overlay0 }} )

    -- ============================================================================
    -- PLUGIN: WHICH-KEY
    -- ============================================================================
    hi("WhichKey", {{ fg = colors.mauve, bg = "NONE" }})
    hi("WhichKeyGroup", {{ fg = colors.blue }})
    hi("WhichKeyBorder", {{ fg = colors.red, bg = "NONE" }})
    hi("WhichKeyDesc", {{ fg = colors.text }})
    hi("WhichKeySeparator", {{ fg = colors.mauve }})
    hi("WhichKeyFloat", {{ bg = "NONE" }})
    hi("WhichKeyTitle", {{ bg = "NONE" }})

    -- ============================================================================
    -- PLUGIN: NOTIFY
    -- ============================================================================
    hi("NotifyBackground", {{ bg = colors.base }})
    hi("NotifyERRORBorder", {{ fg = colors.red }})
    hi("NotifyWARNBorder", {{ fg = colors.yellow }})
    hi("NotifyINFOBorder", {{ fg = colors.blue }})
    hi("NotifyDEBUGBorder", {{ fg = colors.overlay0 }})
    hi("NotifyTRACEBorder", {{ fg = colors.teal }})
    hi("NotifyERRORIcon", {{ fg = colors.red }})
    hi("NotifyWARNIcon", {{ fg = colors.yellow }})
    hi("NotifyINFOIcon", {{ fg = colors.blue }})
    hi("NotifyDEBUGIcon", {{ fg = colors.overlay0 }})
    hi("NotifyTRACEIcon", {{ fg = colors.teal }})
    hi("NotifyERRORTitle", {{ fg = colors.red }})
    hi("NotifyWARNTitle", {{ fg = colors.yellow }})
    hi("NotifyINFOTitle", {{ fg = colors.blue }})
    hi("NotifyDEBUGTitle", {{ fg = colors.overlay0 }})
    hi("NotifyTRACETitle", {{ fg = colors.teal }})

    -- ============================================================================
    -- PLUGIN: RAINBOW DELIMITERS
    -- ============================================================================
    hi("RainbowDelimiterRed",    {{ fg = "{rainbow_colors['red']}" }})
    hi("RainbowDelimiterOrange", {{ fg = "{rainbow_colors['orange']}" }})
    hi("RainbowDelimiterYellow", {{ fg = "{rainbow_colors['yellow']}" }})
    hi("RainbowDelimiterGreen",  {{ fg = "{rainbow_colors['green']}" }})
    hi("RainbowDelimiterCyan",   {{ fg = "{rainbow_colors['cyan']}" }})
    hi("RainbowDelimiterBlue",   {{ fg = "{rainbow_colors['blue']}" }})
    hi("RainbowDelimiterViolet", {{ fg = "{rainbow_colors['violet']}" }})

    -- ============================================================================
    -- PLUGIN: RENDER-MARKDOWN
    -- ============================================================================
    hi("RenderMarkdownCode", {{ bg = "NONE" }})

    -- ============================================================================
    -- PLUGIN: BUFFERLINE / BARBAR
    -- ============================================================================
    hi("BufferLineFill", {{ bg = "NONE" }})
    hi("BufferLineBackground", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferLineBuffer", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferLineBufferVisible", {{ fg = colors.text, bg = "NONE" }})
    hi("BufferLineBufferSelected", {{ fg = colors.mauve, bg = "NONE", style = "bold" }})
    hi("BufferLineTab", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferLineTabSelected", {{ fg = colors.mauve, bg = "NONE", style = "bold" }})
    hi("BufferLineSeparator", {{ fg = colors.surface0, bg = "NONE" }})
    hi("BufferLineSeparatorVisible", {{ fg = colors.surface0, bg = "NONE" }})
    hi("BufferLineSeparatorSelected", {{ fg = colors.surface0, bg = "NONE" }})

    -- Barbar plugin
    hi("BufferCurrent", {{ fg = colors.text, bg = "NONE", style = "bold" }})
    hi("BufferCurrentIndex", {{ fg = colors.mauve, bg = "NONE" }})
    hi("BufferCurrentMod", {{ fg = colors.yellow, bg = "NONE" }})
    hi("BufferCurrentSign", {{ fg = colors.mauve, bg = "NONE" }})
    hi("BufferCurrentTarget", {{ fg = colors.red, bg = "NONE" }})
    hi("BufferVisible", {{ fg = colors.text, bg = "NONE" }})
    hi("BufferVisibleIndex", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferVisibleMod", {{ fg = colors.yellow, bg = "NONE" }})
    hi("BufferVisibleSign", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferVisibleTarget", {{ fg = colors.red, bg = "NONE" }})
    hi("BufferInactive", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferInactiveIndex", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferInactiveMod", {{ fg = colors.lavender, bg = "NONE" }})
    hi("BufferInactiveSign", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("BufferInactiveTarget", {{ fg = colors.red, bg = "NONE" }})
    hi("BufferTabpages", {{ fg = colors.mauve, bg = "NONE", style = "bold" }})
    hi("BufferTabpageFill", {{ bg = "NONE" }})

    -- Overseer (task runner) - often appears in bufferline
    hi("OverseerTask", {{ fg = colors.blue, bg = "NONE" }})
    hi("OverseerTaskBorder", {{ fg = colors.blue, bg = "NONE" }})
    hi("OverseerRunning", {{ fg = colors.yellow, bg = "NONE" }})
    hi("OverseerSuccess", {{ fg = colors.green, bg = "NONE" }})
    hi("OverseerCanceled", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("OverseerFailure", {{ fg = colors.red, bg = "NONE" }})
    hi("OverseerBorder", {{ fg = colors.lavender, bg = "NONE" }})
    hi("OverseerNormal", {{ fg = colors.text, bg = colors.surface0 }})

    -- Additional top bar highlights (in case it's something else)
    hi("WinBar", {{ fg = "NONE", bg = "NONE" }})
    hi("SatelliteBar", {{ fg = "NONE", bg = "NONE" }})
    hi("SatelliteCursor", {{ fg = "NONE", bg = "NONE" }})
    hi("NeoTreeTitleBar", {{ fg = colors.mantle, bg = colors.teal }})
    hi("NeoTreeDimmedText", {{ fg = colors.red }})
    hi("NeoTreeMessage", {{ fg = colors.subtext0 }})
    hi("NeoTreeFloatNormal", {{ fg = colors.red }})
    hi("NeoTreeFloatBorder", {{ fg = colors.teal }})
    hi("NeoTreeFloatTitle", {{ fg = colors.red }})
    hi("NvimScrollbarHandle", {{ fg = "NONE", bg = "NONE" }})
    hi("NvimScrollbarCursor", {{ fg = "NONE", bg = "NONE" }})
    hi("NvimScrollbarError", {{ fg = "NONE", bg = "NONE" }})
    hi("NvimScrollbarWarn", {{ fg = "NONE", bg = "NONE" }})
    hi("NvimScrollbarInfo", {{ fg = "NONE", bg = "NONE" }})
    hi("NvimScrollbarHint", {{fg = "NONE", bg = "NONE" }})
    hi("NeoTreeScrollbar", {{ fg = "NONE", bg = "NONE" }})
    hi("NeoTreeScrollbarThumb", {{ fg = "NONE", bg = "NONE" }})
    hi("WinScrollbar", {{ fg = "NONE", bg = "NONE" }})
    hi("WinScrollbarThumb", {{ fg = "NONE", bg = "NONE" }})
    hi("WinBarNC", {{ fg = "NONE", bg = "NONE" }})
    hi("Title", {{ fg = colors.blue, bg = "NONE" }})
    hi("BufferLineDevIconLua", {{ bg = "NONE" }})
    hi("BufferLineDevIconDefault", {{ bg = "NONE" }})


    -- ============================================================================
    -- TEXT
    -- ============================================================================
    hi("Comment", {{ fg = colors.pink }})
    hi("Constant", {{ fg = colors.teal }})
    -- ============================================================================
    -- PLUGIN: ALPHA (Dashboard)
    -- ============================================================================
    hi("DashboardHeader", {{ fg = colors.sapphire }})
    hi("DashboardFooter", {{ fg = colors.mauve }})
    hi("AlphaShortcut", {{ fg = colors.red }})
    hi("AlphaIconNew", {{ fg = colors.blue }})
    hi("AlphaIconRecent", {{ fg = colors.pink }})
    hi("AlphaIconYazi", {{ fg = colors.peach }})
    hi("AlphaIconSessions", {{ fg = colors.green }})
    hi("AlphaIconProjects", {{ fg = colors.mauve }})
    hi("AlphaIconQuit", {{ fg = colors.red }})


    hi("DiffAdd", {{ fg = colors.green, bg = "NONE" }})
    hi("DiffChange", {{ fg = colors.blue, bg = "NONE" }})
    hi("DiffDelete", {{ fg = colors.red, bg = "NONE" }})
    hi("DiffText", {{ fg = colors.yellow, bg = "NONE", style = "bold" }})

    -- Git signs in the gutter
    hi("GitSignsAdd", {{ fg = colors.green, bg = "NONE" }})
    hi("GitSignsChange", {{ fg = colors.blue, bg = "NONE" }})
    hi("GitSignsDelete", {{ fg = colors.red, bg = "NONE" }})

    -- For syntax highlighting of color hex codes in your editor
    -- This will make the bright red/green hex codes themselves appear in purple tones
    hi("@string.special", {{ fg = colors.green }})  -- For color strings like "#FF0000"
    hi("@number.css", {{ fg = colors.peach }})

-- ============================================================================
-- PLUGIN: LUALINE
-- ============================================================================
    -- Normal mode
    hi("lualine_a_normal", {{ fg = colors.base, bg = colors.blue, style = "bold" }})
    hi("lualine_b_normal", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_c_normal", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_x_normal", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_y_normal", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_z_normal", {{ fg = colors.base, bg = colors.blue }})

    -- Insert mode
    hi("lualine_a_insert", {{ fg = colors.base, bg = colors.teal, style = "bold" }})
    hi("lualine_b_insert", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_c_insert", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_x_insert", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_y_insert", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_z_insert", {{ fg = colors.base, bg = colors.teal }})

    -- Visual mode
    hi("lualine_a_visual", {{ fg = colors.base, bg = colors.mauve, style = "bold" }})
    hi("lualine_b_visual", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_c_visual", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_x_visual", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_y_visual", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_z_visual", {{ fg = colors.base, bg = colors.mauve }})

    -- Replace mode
    hi("lualine_a_replace", {{ fg = colors.base, bg = colors.red, style = "bold" }})
    hi("lualine_b_replace", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_c_replace", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_x_replace", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_y_replace", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_z_replace", {{ fg = colors.base, bg = colors.red }})

    -- Command mode
    hi("lualine_a_command", {{ fg = colors.base, bg = colors.peach, style = "bold" }})
    hi("lualine_b_command", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_c_command", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_x_command", {{ fg = colors.subtext0, bg = "NONE" }})
    hi("lualine_y_command", {{ fg = colors.text, bg = colors.surface0 }})
    hi("lualine_z_command", {{ fg = colors.base, bg = colors.peach }})

    -- Inactive
    hi("lualine_a_inactive", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("lualine_b_inactive", {{ fg = colors.overlay0, bg = "NONE" }})
    hi("lualine_c_inactive", {{ fg = colors.overlay0, bg = "NONE" }})

    -- Additional lualine components
    --hi("lualine_transitional_lualine_a_normal_to_lualine_b_normal", {{ fg = colors.blue, bg = colors.surface0 }})
    --hi("lualine_transitional_lualine_a_insert_to_lualine_b_insert", {{ fg = colors.teal, bg = colors.surface0 }})
    --hi("lualine_transitional_lualine_a_visual_to_lualine_b_visual", {{ fg = colors.mauve, bg = colors.surface0 }})
    --hi("lualine_transitional_lualine_a_replace_to_lualine_b_replace", {{ fg = colors.red, bg = colors.surface0 }})
    --hi("lualine_transitional_lualine_a_command_to_lualine_b_command", {{ fg = colors.peach, bg = colors.surface0 }})

-- ============================================================================
-- TRANSPARENCY REASSERTION (CRITICAL)
-- ============================================================================
    local transparent_groups = {{
      -- Core editor / windows
      "Normal",
      "NormalFloat",
      "FloatBorder",
      "SignColumn",
      "EndOfBuffer",
      "VertSplit",
      "WinSeparator",
      "WinBar",
      "WinBarNC",
      "Title",

      -- Cursor / columns (IMPORTANT)
      "CursorLine",
      "CursorColumn",
      "ColorColumn",

      -- Status / tabline
      "StatusLine",
      "StatusLineNC",
      "TabLine",
      "TabLineFill",
      "TabLineSel",

      -- Popup / completion
      "Pmenu",
      "PmenuSbar",
      "PmenuThumb",
      "PmenuBorder",
      "TelescopePromptBorder",
      "TelescopeResultsBorder",
      "TelescopePreviewBorder",


      -- Completion item kinds (nvim-cmp)
      "CmpItemKindVariable",
      "CmpItemKindFunction",
      "CmpItemKindMethod",
      "CmpItemKindConstructor",
      "CmpItemKindClass",
      "CmpItemKindInterface",
      "CmpItemKindStruct",
      "CmpItemKindEnum",
      "CmpItemKindEnumMember",
      "CmpItemKindModule",
      "CmpItemKindProperty",
      "CmpItemKindField",
      "CmpItemKindTypeParameter",
      "CmpItemKindConstant",
      "CmpItemKindKeyword",
      "CmpItemKindSnippet",
      "CmpItemKindText",
      "CmpItemKindFile",
      "CmpItemKindFolder",
      "CmpItemKindColor",
      "CmpItemKindReference",
      "CmpItemKindOperator",
      "CmpItemKindUnit",
      "CmpItemKindValue",

      -- Completion text
      "CmpItemAbbr",
      "CmpItemAbbrDeprecated",
      "CmpItemAbbrMatch",
      "CmpItemAbbrMatchFuzzy",
      "CmpItemMenu",

      -- Which-key
      "WhichKey",
      "WhichKeyFloat",
      "WhichKeyTile",

      -- Neo-tree
      "NeoTreeTabActive",
      "NeoTreeTabInactive",
      "NeoTreeTabSeparatorActive",
      "NeoTreeTabSeparatorInactive",

      -- Render / markdown
      "RenderMarkdownCode",

      -- Bufferline / Barbar
      "BufferLineFill",
      "BufferLineBackground",
      "BufferLineBuffer",
      "BufferLineBufferVisible",
      "BufferLineBufferSelected",
      "BufferLineTab",
      "BufferLineTabSelected",
      "BufferLineSeparator",
      "BufferLineSeparatorVisible",
      "BufferLineSeparatorSelected",

      "BufferCurrent",
      "BufferCurrentIndex",
      "BufferCurrentMod",
      "BufferCurrentSign",
      "BufferCurrentTarget",

      "BufferVisible",
      "BufferVisibleIndex",
      "BufferVisibleMod",
      "BufferVisibleSign",
      "BufferVisibleTarget",

      "BufferInactive",
      "BufferInactiveIndex",
      "BufferInactiveMod",
      "BufferInactiveSign",
      "BufferInactiveTarget",

      "BufferTabpages",
      "BufferTabpageFill",

      -- Devicons
      "BufferLineDevIconLua",
      "BufferLineDevIconDefault",

      -- Overseer
      "OverseerTask",
      "OverseerTaskBorder",
      "OverseerRunning",
      "OverseerSuccess",
      "OverseerCanceled",
      "OverseerFailure",
      "OverseerBorder",
        }}

    for _, group in ipairs(transparent_groups) do
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, {{ name = group }})
        if ok then
            hl.bg = "NONE"
            hl.ctermbg = nil
            vim.api.nvim_set_hl(0, group, hl)
        end
    end
end

setup_highlights()
'''

    with open(nvim_output, 'w') as f:
        f.write(nvim_theme_content)

    if args.debug:
        print(f"\nNeovim colorscheme written to: {nvim_output}")




# Generate LazyGit config
if args.termscheme is not None and lazygit_colors:
    lazygit_config_dir = Path.home() / '.config' / 'lazygit'
    lazygit_config_dir.mkdir(parents=True, exist_ok=True)
    lazygit_config_file = str(lazygit_config_dir / 'config.yml')

    # Read existing config if it exists
    existing_config = ""
    if os.path.exists(lazygit_config_file):
        with open(lazygit_config_file, 'r') as f:
            existing_config = f.read()

    lazygit_config = f'''# Auto-generated LazyGit theme colors
gui:
  theme:
    activeBorderColor:
      - "{lazygit_colors['activeBorder']}"
      - bold
    inactiveBorderColor:
      - "{lazygit_colors['inactiveBorder']}"
    optionsTextColor:
      - "{lazygit_colors['optionsText']}"
    selectedLineBgColor:
      - "{lazygit_colors['selectedLineBg']}"
    selectedRangeBgColor:
      - "{lazygit_colors['selectedRangeBg']}"
    cherryPickedCommitBgColor:
      - "{lazygit_colors['cherryPickedBg']}"
    cherryPickedCommitFgColor:
      - "{lazygit_colors['cherryPickedFg']}"
    unstagedChangesColor:
      - "{lazygit_colors['unstagedChanges']}"
    defaultFgColor:
      - "{lazygit_colors['defaultFg']}"
    searchingActiveBorderColor:
      - "{lazygit_colors['searchMatching']}"

  nerdFontsVersion: "3"
  showFileTree: true
  showRandomTip: false

# Git diff settings with custom colors
git:
  paging:
    colorArg: always
    useConfig: false
    # Using delta for better diff rendering
    pager: delta --dark --paging=never --line-numbers --minus-style='syntax "{lazygit_colors['unstagedChanges']}"' --minus-emph-style='syntax "{lazygit_colors['unstagedChanges']}"' --plus-style='syntax "{lazygit_colors['stagedChanges']}"' --plus-emph-style='syntax "{lazygit_colors['stagedChanges']}"' --hunk-header-style='file line-number syntax'
'''

    with open(lazygit_config_file, 'w') as f:
        f.write(lazygit_config)

    if args.debug:
        print(f"\nLazyGit config written to: {lazygit_config_file}")
        print("Note: You may need to install 'delta' for best diff rendering:")
        print("  cargo install git-delta")
        print("  or: brew install git-delta")

if args.debug == False:
    print(f"$darkmode: {darkmode};")
    print(f"$transparent: {transparent};")
    for color, code in material_colors.items():
        print(f"${color}: {code};")
    for color, code in term_colors.items():
         print(f"${color}: {code};")
    for color, code in lazygit_colors.items():
        print(f"$lazygit_{color}: {code};")
    if neovim_colors:
        print('\n--------------Neovim colors (Catppuccin)---------')
        for color, code in neovim_colors.items():
            if code == 'NONE':
                print(f"{color.ljust(20)} : TRANSPARENT")
            else:
                rgba = rgba_from_argb(hex_to_argb(code))
                print(f"{color.ljust(20)} : {display_color(rgba)}  {code}")
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

    with open(scss_out, "w") as f:
    # Material colors
        for k, v in material_colors.items():
            f.write(f"${k}: {v};\n")

        # Terminal colors
        for i in range(16):
            key = f"term{i}"
            if key in term_colors:
                f.write(f"${key}: {term_colors[key]};\n")

        # LazyGit colors
        for k, v in lazygit_colors.items():
            f.write(f"$lazygit_{k}: {v};\n")

        # Neovim colors (NEW)
        for k, v in neovim_colors.items():
            f.write(f"$nvim_{k}: {v};\n")

if args.termscheme is not None and term_colors:
    kitty_config_dir = Path.home() / '.config' / 'kitty'
    kitty_config_dir.mkdir(parents=True, exist_ok=True)
    kitty_colors_file = str(kitty_config_dir / 'current-theme.conf')

    with open(kitty_colors_file, 'w') as f:
        f.write('# Auto-generated colors\n')
        f.write(f'background {term_colors["term0"]}\n')
        f.write(f'foreground {term_colors["term7"]}\n')
        for i in range(16):
            f.write(f'color{i} {term_colors[f"term{i}"]}\n')

# =============================================================================
# DISCORD THEME GENERATION (add this to the end of generate_colors_material.py)
# =============================================================================

# Add after the kitty config generation (around line 1270)

# Discord theme generation
if args.path is not None:  # Only generate if we have an image source
    betterdiscord_dir = Path.home() / '.config' / 'vesktop' / 'themes'

    # Check if BetterDiscord directory exists
    if betterdiscord_dir.exists():
        discord_theme_file = str(betterdiscord_dir / 'MaterialYou_Translucence.css')
        translucence_base = str(betterdiscord_dir / 'Translucence_theme.css')

        # Get wallpaper path
        wallpaper_url = f"file://{os.path.abspath(args.path)}"

        # Extract colors from the generated scheme
        accent_hex = argb_to_hex(argb)
        accent_hct_obj = Hct.from_int(argb)

        # Generate complementary colors from the accent
        primary_color = material_colors.get('primary', accent_hex)
        secondary_color = material_colors.get('secondary', accent_hex)
        tertiary_color = material_colors.get('tertiary', accent_hex)

        # Background colors based on dark/light mode
        if darkmode:
            bg_base = material_colors.get('surface', '#1e1e2e')
            bg_surface = material_colors.get('surfaceContainerLow', '#181825')
            text_primary = material_colors.get('onSurface', '#cdd6f4')
            text_secondary = material_colors.get('onSurfaceVariant', '#bac2de')
        else:
            bg_base = material_colors.get('surface', '#eff1f5')
            bg_surface = material_colors.get('surfaceContainerLow', '#e6e9ef')
            text_primary = material_colors.get('onSurface', '#4c4f69')
            text_secondary = material_colors.get('onSurfaceVariant', '#5c5f77')

        # Convert hex to RGB for rgba usage
        def hex_to_rgb(hex_color):
            hex_color = hex_color.lstrip('#')
            return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

        accent_rgb = hex_to_rgb(accent_hex)
        bg_rgb = hex_to_rgb(bg_base)
        surface_rgb = hex_to_rgb(bg_surface)

        # Generate Discord theme CSS
        discord_theme = f'''/**
 * @name Material You Translucence
 * @description Auto-generated Material You theme with wallpaper
 * @author Generated by material color script
 * @version 1.0
 * @source {args.path}
 */

/* Import base Translucence theme */
@import url("Translucence_theme.css");

:root {{
  /* WALLPAPER */
  --app-bg: url({wallpaper_url}) !important;
  --app-blur: 8px;
  --app-margin: 24px;
  --app-radius: 12px;

  /* MATERIAL YOU COLORS FROM WALLPAPER */
  --main-rgb: {bg_rgb[0]}, {bg_rgb[1]}, {bg_rgb[2]};
  --surface-rgb: {surface_rgb[0]}, {surface_rgb[1]}, {surface_rgb[2]};
  --accent-rgb: {accent_rgb[0]}, {accent_rgb[1]}, {accent_rgb[2]};

  /* OPACITY SETTINGS */
  --main-content-opacity: 0.25;
  --sidebar-opacity: 0.35;
  --main-content-color: rgba(var(--main-rgb), var(--main-content-opacity));
  --sidebar-color: rgba(var(--main-rgb), var(--sidebar-opacity));

  /* ACCENT COLOR (Material You Primary) */
  --accent-hue: {accent_hct_obj.hue:.0f};
  --accent-saturation: {min(accent_hct_obj.chroma * 1.3, 100):.1f}%;
  --accent-lightness: {accent_hct_obj.tone:.1f}%;
  --accent-hsl: var(--accent-hue), calc(var(--accent-saturation) * var(--saturation-factor, 1)), var(--accent-lightness);
  --accent-opacity: 1;
  --accent-text-color: {material_colors.get('onPrimary', '#000000')};

  /* SECONDARY ACCENT */
  --accent-secondary-color: rgba(var(--accent-rgb), 0.5);
  --accent-secondary-text-color: {text_primary};

  /* MESSAGE COLORS */
  --message-color: rgba(var(--surface-rgb), 0.4);
  --message-color-hover: rgba(var(--surface-rgb), 0.55);
  --message-radius: var(--app-radius);

  /* INPUT/TEXTAREA */
  --textarea-color: var(--accent-rgb);
  --textarea-alpha: 0.12;
  --textarea-alpha-focus: 0.2;
  --textarea-text-color: {text_primary};
  --textarea-placeholder-color: {text_secondary};
  --textarea-radius: 28px;

  /* CARDS */
  --card-color: rgba(var(--surface-rgb), 0.35);
  --card-color-hover: rgba(var(--surface-rgb), 0.45);
  --card-color-select: rgba(var(--surface-rgb), 0.55);
  --card-radius: var(--app-radius);

  /* POPOUTS */
  --popout-color: rgba(var(--main-rgb), 0.75);
  --popout-blur: 15px;
  --popout-radius: var(--app-radius);

  /* BUTTONS */
  --button-color: rgba(var(--accent-rgb), var(--accent-opacity));
  --button-text-color: var(--accent-text-color);
  --button-radius: 16px;

  /* TOOLTIPS */
  --tooltip-color: rgba(var(--accent-rgb), 0.95);
  --tooltip-text-color: var(--accent-text-color);
  --tooltip-radius: var(--app-radius);

  /* SCROLLBAR */
  --scrollbar-color: var(--accent-rgb);
  --scrollbar-opacity: 0.3;
  --scrollbar-opacity-hover: 0.5;
}}

@supports (color: color-mix(in lch, red, blue)) {{
  .visual-refresh.theme-{'dark' if darkmode else 'light'},
  .visual-refresh .theme-{'dark' if darkmode else 'light'} {{
    /* TEXT COLORS */
    --text-primary: {text_primary};
    --text-secondary: {text_secondary};
    --text-muted: {material_colors.get('outline', '#a6adc8')};
    --text-link: {primary_color};
    --text-brand: {accent_hex};

    /* INTERACTIVE COLORS */
    --interactive-normal: {text_secondary};
    --interactive-hover: {text_primary};
    --interactive-active: {accent_hex};
    --interactive-muted: {material_colors.get('surfaceVariant', '#6c7086')};

    /* CHANNEL COLORS */
    --channels-default: {text_secondary};
    --channel-icon: {material_colors.get('onSurfaceVariant', '#a6adc8')};

    /* BACKGROUND MODIFIERS */
    --background-modifier-hover: rgba(var(--accent-rgb), 0.1);
    --background-modifier-active: rgba(var(--accent-rgb), 0.15);
    --background-modifier-selected: rgba(var(--accent-rgb), 0.2);
    --background-modifier-accent: rgba(var(--accent-rgb), 0.25);

    /* BACKGROUNDS */
    --background-primary: transparent;
    --background-secondary: transparent;
    --background-tertiary: transparent;
    --background-accent: rgba(var(--accent-rgb), 0.2);
    --background-floating: rgba(var(--main-rgb), 0.85);

    /* BRAND COLORS */
    --brand-experiment: {accent_hex} !important;
    --brand-experiment-hover: {primary_color} !important;
    --brand-500: {accent_hex};
    --brand-560: {primary_color};

    /* STATUS COLORS */
    --status-positive: {material_colors.get('success', '#a6e3a1')};
    --status-warning: {material_colors.get('tertiary', '#f9e2af')};
    --status-danger: {material_colors.get('error', '#f38ba8')};

    /* HEADER COLORS */
    --header-primary: {text_primary};
    --header-secondary: {text_secondary};
  }}
}}

/* Enhanced text shadows for better readability */
._51fd70792ee2e563-appMount * {{
  text-shadow: 0 1px 3px rgba(0, 0, 0, {'0.8' if darkmode else '0.3'}) !important;
}}

/* Message content readability */
[class*="messageContent"],
[class*="markup"] {{
  text-shadow: 0 0.5px 2px rgba(0, 0, 0, {'0.7' if darkmode else '0.2'}) !important;
}}

/* Code blocks with Material You colors */
code {{
  background-color: rgba(var(--surface-rgb), 0.8) !important;
  color: {material_colors.get('onSurface', text_primary)} !important;
  border-color: rgba(var(--accent-rgb), 0.3) !important;
}}

pre {{
  background-color: rgba(var(--surface-rgb), 0.8) !important;
  border-color: rgba(var(--accent-rgb), 0.3) !important;
}}

/* Mention styling */
[class*="mentioned"] {{
  background-color: rgba(var(--accent-rgb), 0.15) !important;
}}

[class*="mention"] {{
  background-color: rgba(var(--accent-rgb), 0.25) !important;
  color: {accent_hex} !important;
}}

/* Selection */
::selection {{
  background: rgba(var(--accent-rgb), 0.5);
  color: var(--accent-text-color);
}}

/* Scrollbar styling */
::-webkit-scrollbar-thumb {{
  background-color: rgba(var(--accent-rgb), var(--scrollbar-opacity)) !important;
}}

::-webkit-scrollbar-thumb:hover {{
  background-color: rgba(var(--accent-rgb), var(--scrollbar-opacity-hover)) !important;
}}

/* Button hover effects */
[class*="button"]:hover {{
  background-color: rgba(var(--accent-rgb), 0.8) !important;
  transform: translateY(-1px);
  transition: all 0.2s ease;
}}

/* Active/selected states */
[class*="selected"],
[class*="active"] {{
  background-color: rgba(var(--accent-rgb), 0.2) !important;
  border-left: 3px solid {accent_hex} !important;
}}
'''

        # Write the theme file
        with open(discord_theme_file, 'w') as f:
            f.write(discord_theme)

        if args.debug:
            print(f"\n✓ Discord theme generated: {discord_theme_file}")
            print(f"  Wallpaper: {wallpaper_url}")
            print(f"  Accent: {accent_hex}")
            print(f"  Mode: {'Dark' if darkmode else 'Light'}")
            print("\nTo use:")
            print("  1. Make sure Translucence_theme.css is in the same folder")
            print("  2. Enable 'MaterialYou_Translucence' in Discord settings")
            print("  3. Press Ctrl+R in Discord to reload")
    else:
        if args.debug:
            print(f"\n⚠ BetterDiscord directory not found at: {betterdiscord_dir}")
            print("  Skipping Discord theme generation")
