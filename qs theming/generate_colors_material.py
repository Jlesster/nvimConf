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
        'term0':  Hct.from_hct(base_hue, min(primary_hct.chroma * 0.6, 25), 6),   # Very dark black-purple bg to match nvim
        'term1':  Hct.from_hct(base_hue - 15, min(primary_hct.chroma * 1.5, 75), 62), # Red-purple (errors)
        'term2':  Hct.from_hct(base_hue + 30, min(primary_hct.chroma * 1.4, 70), 68), # Blue-purple (success)
        'term3':  Hct.from_hct(base_hue + 5, min(primary_hct.chroma * 2.0, 95), 92), # Light purple (Keys/Values) - WHITE-ISH PURPLE, VERY SATURATED
        'term4':  Hct.from_hct(base_hue + 5, min(primary_hct.chroma * 1.7, 85), 82),  # Medium purple (info) - BRIGHTER
        'term5':  Hct.from_hct(base_hue - 5, min(primary_hct.chroma * 1.8, 88), 80), # Pink-purple - VERY SATURATED
        'term6':  Hct.from_hct(base_hue + 10, min(primary_hct.chroma * 1.7, 85), 82), # Cyan-purple - BRIGHTER
        'term7':  Hct.from_hct(base_hue, min(primary_hct.chroma * 0.25, 20), 88),      # Light gray-purple (normal text) - VERY BRIGHT
        'term8':  Hct.from_hct(base_hue, min(primary_hct.chroma * 1.0, 42), 35),      # Medium dark purple
        'term9':  Hct.from_hct(base_hue - 15, min(primary_hct.chroma * 1.8, 88), 85), # Bright red-purple - VERY BRIGHT
        'term10': Hct.from_hct(base_hue + 30, min(primary_hct.chroma * 1.7, 85), 88), # Bright blue-purple - VERY BRIGHT
        'term11': Hct.from_hct(base_hue + 5, min(primary_hct.chroma * 2.0, 95), 92), # Bright light purple (Keys/Values) - WHITE-ISH PURPLE, VERY SATURATED
        'term12': Hct.from_hct(base_hue + 5, min(primary_hct.chroma * 1.8, 88), 88),  # Bright medium purple - VERY BRIGHT
        'term13': Hct.from_hct(base_hue - 5, min(primary_hct.chroma * 1.8, 88), 87), # Bright pink-purple - VERY BRIGHT
        'term14': Hct.from_hct(base_hue + 10, min(primary_hct.chroma * 1.7, 85), 86), # Bright cyan-purple - VERY BRIGHT
        'term15': Hct.from_hct(base_hue, min(primary_hct.chroma * 0.12, 10), 96),      # Nearly pure white with tiny purple hint
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

# Neovim colors - Catppuccin Mocha harmonized with Material You
neovim_colors = {}

if args.termscheme is not None:
    # Load real Catppuccin Mocha palette
    cat = load_catppuccin_palette(os.path.expanduser("~/.config/quickshell/ii/scripts/colors/Colors.json"))

    accent_argb = hex_to_argb(material_colors["primary_paletteKeyColor"])

    # VERY gentle harmonization
    BG_HARMONY = 0.08
    UI_HARMONY = 0.15
    SYNTAX_HARMONY = 0.55 #lower is more harmony
    TEXT_HARMONY = 0.06

    BG_THRESH = 10.0
    UI_THRESH = 18.0
    SYNTAX_THRESH = 32.0 #less is more contr
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
        "rosewater": (SYNTAX_HARMONY, SYNTAX_THRESH, 65),  # Medium-high chroma
        "flamingo": (SYNTAX_HARMONY, SYNTAX_THRESH, 68),
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
        "blue": (SYNTAX_HARMONY, SYNTAX_THRESH, 72),
        "lavender": (SYNTAX_HARMONY, SYNTAX_THRESH, 68),
    }

    for k, (harmony, thresh, max_chroma) in syntax_colors.items():
        raw = harmonize_hex(cat[k], accent_argb, harmony, thresh)
        neovim_colors[k] = argb_to_hex(
            clamp_chroma(hex_to_argb(raw), max_chroma=max_chroma)
        )

    # Force specific tones for better contrast and vibrancy
    TONE_MAP = {
        "mauve": 72,      # Brighter
        "blue": 76,       # Brighter
        "green": 78,      # Brighter
        "teal": 80,       # Very bright
        "yellow": 85,     # Very bright
        "pink": 78,       # Brighter
        "sapphire": 74,   # Medium-bright
    }

    for k, tone in TONE_MAP.items():
        neovim_colors[k] = argb_to_hex(
            force_tone(hex_to_argb(neovim_colors[k]), tone)
        )

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
hi("Normal", {{ fg = colors.text, bg = colors.base }})
hi("NormalFloat", {{ fg = colors.text, bg = colors.mantle }})
hi("FloatBorder", {{ fg = colors.base, bg = colors.mantle }})
hi("FloatTitle", {{ fg = colors.mauve, bg = colors.base, style = "bold,italic" }})

hi("Cursor", {{ fg = colors.base, bg = colors.text }})
hi("CursorLine", {{ bg = colors.base }})
hi("CursorColumn", {{ bg = colors.base }})
hi("ColorColumn", {{ bg = "NONE" }})
hi("CursorLineNr", {{ fg = colors.lavender, style = "bold" }})
hi("LineNr", {{ fg = colors.overlay0 }})
hi("LineNrAbove", {{ fg = colors.mauve }})
hi("LineNrBelow", {{ fg = colors.mauve }})
hi("SignColumn", {{ bg = colors.base }})
hi("EndOfBuffer", {{ fg = colors.lavender }})
hi("NonText", {{ fg = colors.lavender }})

hi("StatusLine", {{ fg = colors.text, bg = colors.base }})
hi("StatusLineNC", {{ fg = colors.overlay0, bg = colors.base }})
hi("VertSplit", {{ fg = colors.surface0, bg = "NONE" }})
hi("WinSeparator", {{ fg = colors.surface0, bg = "NONE" }})

hi("Search", {{ fg = colors.base, bg = colors.mauve}})
hi("IncSearch", {{ fg = colors.base, bg = colors.peach }})
hi("CurSearch", {{ fg = colors.base, bg = colors.peach }})
hi("Visual", {{ bg = colors.surface1 }})
hi("VisualNOS", {{ bg = colors.surface1 }})

hi("Pmenu", {{ fg = colors.text, bg = colors.base }})
hi("PmenuSel", {{ fg = colors.base, bg = colors.surface1, style = "bold" }})
hi("PmenuSbar", {{ bg = colors.base}})
hi("PmenuThumb", {{ bg = colors.base }})
hi("PmenuBorder", {{ fg = colors.lavender, bg = colors.base }})

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
hi("TabLineFill", {{ bg = colors.base }})
hi("TabLineSel", {{ fg = colors.mauve, bg = colors.base }})

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

hi("@constructor", {{ fg = colors.sapphire }})
hi("@operator", {{ fg = colors.teal }})

hi("@keyword", {{ fg = colors.mauve, style = "bold" }})
hi("@keyword.function", {{ fg = colors.mauve, style = "bold" }})
hi("@keyword.operator", {{ fg = colors.mauve }})
hi("@keyword.return", {{ fg = colors.pink, style = "bold" }})

hi("@type", {{ fg = colors.yellow }})
hi("@type.builtin", {{ fg = colors.yellow, style = "italic" }})
hi("@type.qualifier", {{ fg = colors.mauve, style = "italic" }})

hi("@property", {{ fg = colors.teal }})
hi("@attribute", {{ fg = colors.yellow, style = "italic" }})
hi("@namespace", {{ fg = colors.sapphire, style = "italic" }})

hi("@punctuation.delimiter", {{ fg = colors.overlay2 }})
hi("@punctuation.bracket", {{ fg = colors.overlay2 }})
hi("@punctuation.special", {{ fg = colors.sky }})

hi("@comment", {{ fg = colors.pink, italic = true }})
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
hi("@lsp.type.parameter", {{ fg = colors.maroon, style = "italic" }})
hi("@lsp.typemod.variable.readonly", {{ fg = colors.teal }})
hi("@lsp.typemod.variable.declaration", {{ fg = colors.flamingo, style = "italic" }})
hi("@lsp.typemod.variable.static", {{ fg = colors.flamingo }})
hi("@lsp.typemod.variable.global", {{ fg = colors.flamingo }})

-- Properties and Fields
hi("@lsp.type.property", {{ fg = colors.text }})
hi("@lsp.typemod.property.static", {{ fg = colors.teal, style = "italic" }})
hi("@lsp.typemod.property.static.java", {{ fg = colors.red, style = "italic,bold" }})

-- Functions and Methods
hi("@lsp.type.function", {{ fg = colors.blue, style = "bold" }})
hi("@lsp.type.method", {{ fg = colors.sapphire, style = "bold" }})
hi("@lsp.typemod.function.static", {{ fg = colors.sky, style = "bold" }})
hi("@lsp.typemod.method.static", {{ fg = colors.sapphire, style = "bold" }})

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

hi("DiagnosticVirtualTextError", {{ fg = colors.red, bg = colors.base }})
hi("DiagnosticVirtualTextWarn", {{ fg = colors.yellow, bg = colors.base }})
hi("DiagnosticVirtualTextInfo", {{ fg = colors.blue, bg = colors.base }})
hi("DiagnosticVirtualTextHint", {{ fg = colors.teal, bg = colors.base }})

hi("DiagnosticUnderlineError", {{ sp = colors.red, style = "undercurl" }})
hi("DiagnosticUnderlineWarn", {{ sp = colors.yellow, style = "undercurl" }})
hi("DiagnosticUnderlineInfo", {{ sp = colors.blue, style = "undercurl" }})
hi("DiagnosticUnderlineHint", {{ sp = colors.teal, style = "undercurl" }})

-- ============================================================================
-- LSP REFERENCES
-- ============================================================================
hi("LspReferenceText", {{ bg = colors.surface1 }})
hi("LspReferenceRead", {{ bg = colors.surface1 }})
hi("LspReferenceWrite", {{ bg = colors.surface1, style = "bold" }})

-- ============================================================================
-- PLUGIN: TELESCOPE
-- ============================================================================
hi("TelescopeBorder", {{ fg = colors.lavender, bg = colors.mantle }})
hi("TelescopePromptBorder", {{ fg = colors.mauve, bg = colors.base}})
hi("TelescopeResultsBorder", {{ fg = colors.lavender, bg = colors.base }})
hi("TelescopePreviewBorder", {{ fg = colors.lavender, bg = colors.base }})
hi("TelescopeSelection", {{ fg = colors.surface0, bg = colors.mauve, style = "bold" }})
hi("TelescopeSelectionCaret", {{ fg = colors.mauve, bg = colors.surface0 }})
hi("TelescopeMatching", {{ fg = colors.blue }})

-- ============================================================================
-- PLUGIN: NVIM-TREE / NEO-TREE
-- ============================================================================
hi("NvimTreeNormal", {{ fg = colors.text, bg = colors.base }})
hi("NvimTreeFolderIcon", {{ fg = colors.mauve }})
hi("NvimTreeFolderName", {{ fg = colors.sapphire }})
hi("NvimTreeOpenedFolderName", {{ fg = colors.blue, bold = true }})
hi("NvimTreeIndentMarker", {{ fg = colors.overlay0 }})
hi("NvimTreeGitDirty", {{ fg = colors.yellow }})
hi("NvimTreeGitNew", {{ fg = colors.green }})
hi("NvimTreeGitDeleted", {{ fg = colors.red }})

hi("NeoTreeTabActive", {{ fg = colors.mauve, bg = colors.base }})
hi("NeoTreeTabInactive", {{ fg = colors.overlay0, bg = colors.base }})
hi("NeoTreeTabSeparatorActive", {{ fg = colors.surface0, bg = "NONE" }})
hi("NeoTreeTabSeparatorInactive", {{ fg = colors.surface0, bg = "NONE" }})

-- ============================================================================
-- PLUGIN: INDENT-BLANKLINE
-- ============================================================================
hi("IblIndent", {{ fg = colors.lavender }})
hi("IblScope", {{ fg = colors.mauve }})

-- ============================================================================
-- PLUGIN: WHICH-KEY
-- ============================================================================
hi("WhichKey", {{ fg = colors.mauve, bg = "NONE" }})
hi("WhichKeyGroup", {{ fg = colors.blue }})
hi("WhichKeyDesc", {{ fg = colors.text }})
hi("WhichKeySeparator", {{ fg = colors.mauve }})
hi("WhichKeyFloat", {{ bg = colors.base }})
hi("WhichKeyTile", {{ bg = colors.base }})

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
hi("RainbowDelimiterRed", {{ fg = colors.red }})
hi("RainbowDelimiterOrange", {{ fg = colors.peach }})
hi("RainbowDelimiterYellow", {{ fg = colors.yellow }})
hi("RainbowDelimiterGreen", {{ fg = colors.green }})
hi("RainbowDelimiterCyan", {{ fg = colors.teal }})
hi("RainbowDelimiterBlue", {{ fg = colors.sky }})
hi("RainbowDelimiterViolet", {{ fg = colors.mauve }})

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
hi("BufferInactiveMod", {{ fg = colors.yellow, bg = "NONE" }})
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

-- Additional top bar highlights (in case it's something else)
hi("WinBar", {{ fg = colors.text, bg = "NONE" }})
hi("WinBarNC", {{ fg = colors.overlay0, bg = "NONE" }})
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
hi("AlphaIconNew", {{ fg = colors.blue }})
hi("AlphaIconRecent", {{ fg = colors.pink }})
hi("AlphaIconYazi", {{ fg = colors.peach }})
hi("AlphaIconSessions", {{ fg = colors.green }})
hi("AlphaIconProjects", {{ fg = colors.mauve }})
hi("AlphaIconQuit", {{ fg = colors.red }})

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
    }}

for _, group in ipairs(transparent_groups) do
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, {{ name = group }})
  if ok then
    hl.bg = "NONE"
    vim.api.nvim_set_hl(0, group, hl)
  end
end

'''

    with open(nvim_output, 'w') as f:
        f.write(nvim_theme_content)

    if args.debug:
        print(f"\nNeovim colorscheme written to: {nvim_output}")

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


