import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance

def ensure_dirs():
    dirs = [
        "play_store_assets/app_icon",
        "play_store_assets/feature_graphic",
        "play_store_assets/screenshots",
        "play_store_assets/listing"
    ]
    for d in dirs:
        os.makedirs(d, exist_ok=True)

def load_font(size, bold=False):
    # Try standard system fonts or default
    font_paths = [
        "C:\\Windows\\Fonts\\arialbd.ttf" if bold else "C:\\Windows\\Fonts\\arial.ttf",
        "C:\\Windows\\Fonts\\segoeui.ttf",
        "C:\\Windows\\Fonts\\tahoma.ttf",
    ]
    for path in font_paths:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                pass
    return ImageFont.load_default()

def draw_hud_grid(draw, width, height, cell_size=40, color=(22, 160, 133, 25)):
    for x in range(0, width, cell_size):
        draw.line([(x, 0), (x, height)], fill=color, width=1)
    for y in range(0, height, cell_size):
        draw.line([(0, y), (width, y)], fill=color, width=1)

def draw_tech_nodes(draw, width, height):
    nodes = [
        (100, 80), (300, 50), (900, 120), (850, 380), (150, 420),
        (500, 450), (950, 250), (70, 250)
    ]
    for i, (x1, y1) in enumerate(nodes):
        for j, (x2, y2) in enumerate(nodes):
            if i < j and math.hypot(x2 - x1, y2 - y1) < 300:
                draw.line([(x1, y1), (x2, y2)], fill=(22, 160, 133, 40), width=1)
    for x, y in nodes:
        draw.ellipse([x - 3, y - 3, x + 3, y + 3], fill=(26, 188, 156, 180))

# =========================================================
# 1. GOOGLE PLAY APP ICON (512x512)
# =========================================================
def generate_app_icon():
    canvas = Image.new("RGBA", (512, 512), (5, 8, 17, 255))
    draw = ImageDraw.Draw(canvas)

    # Subtle cyan radial glow
    glow = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse([80, 80, 432, 432], fill=(22, 160, 133, 60))
    glow = glow.filter(ImageFilter.GaussianBlur(50))
    canvas.paste(glow, (0, 0), glow)

    # Tech border / subtle HUD circle
    draw.ellipse([40, 40, 472, 472], outline=(22, 160, 133, 100), width=2)
    draw.ellipse([46, 46, 466, 466], outline=(26, 188, 156, 40), width=1)

    # Load existing official Robo Cell logo
    logo_path = "assets/rcell.jpg" if os.path.exists("assets/rcell.jpg") else "assets/appicon1.jpg"
    if os.path.exists(logo_path):
        logo = Image.open(logo_path).convert("RGBA")
        
        # Make logo rounded or clean square with circular mask
        mask = Image.new("L", (320, 320), 0)
        mask_draw = ImageDraw.Draw(mask)
        mask_draw.ellipse([0, 0, 320, 320], fill=255)
        
        logo_resized = logo.resize((320, 320), Image.Resampling.LANCZOS)
        canvas.paste(logo_resized, (96, 96), mask)

    # Output path
    out_path = "play_store_assets/app_icon/robo_cell_play_icon_512.png"
    canvas.save(out_path, "PNG")
    print(f"[OK] Generated App Icon: {out_path} ({canvas.width}x{canvas.height})")

# =========================================================
# 2. FEATURE GRAPHIC (1024x500)
# =========================================================
def generate_feature_graphic():
    width, height = 1024, 500
    canvas = Image.new("RGBA", (width, height), (5, 8, 17, 255))
    draw = ImageDraw.Draw(canvas)

    # Draw HUD grid & nodes background
    draw_hud_grid(draw, width, height, cell_size=40, color=(22, 160, 133, 20))
    draw_tech_nodes(draw, width, height)

    # Left-center cyan ambient glow
    glow = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse([60, 50, 450, 450], fill=(22, 160, 133, 70))
    glow = glow.filter(ImageFilter.GaussianBlur(60))
    canvas.paste(glow, (0, 0), glow)

    # Official Logo Visual Anchor (Left Side)
    logo_path = "assets/rcell.jpg" if os.path.exists("assets/rcell.jpg") else "assets/appicon1.jpg"
    if os.path.exists(logo_path):
        logo = Image.open(logo_path).convert("RGBA")
        logo_size = 240
        mask = Image.new("L", (logo_size, logo_size), 0)
        ImageDraw.Draw(mask).ellipse([0, 0, logo_size, logo_size], fill=255)
        
        logo_resized = logo.resize((logo_size, logo_size), Image.Resampling.LANCZOS)
        canvas.paste(logo_resized, (90, 130), mask)
        draw.ellipse([86, 126, 90 + logo_size + 4, 130 + logo_size + 4], outline=(26, 188, 156, 160), width=2)

    # Typography (Right-Center Text)
    font_title = load_font(52, bold=True)
    font_subtitle = load_font(22, bold=True)
    font_tagline = load_font(16, bold=False)

    # Title: ROBO CELL
    text_x = 380
    draw.text((text_x, 150), "ROBO CELL", fill=(255, 255, 255, 255), font=font_title)

    # Subtitle Badge: TECH • TRANSFORM • THRIVE
    draw.rectangle([text_x, 222, text_x + 360, 256], fill=(18, 18, 20, 220), outline=(22, 160, 133, 160), width=1)
    draw.text((text_x + 14, 228), "TECH  •  TRANSFORM  •  THRIVE", fill=(26, 188, 156, 255), font=font_subtitle)

    # Tagline Details: Robotics • Artificial Intelligence • Community
    draw.text((text_x, 280), "Official Application of the Robo Cell Department", fill=(176, 176, 184, 255), font=font_tagline)
    draw.text((text_x, 308), "Robotics  |  Artificial Intelligence  |  Innovation", fill=(113, 113, 122, 255), font=font_tagline)

    out_path = "play_store_assets/feature_graphic/robo_cell_feature_graphic_1024x500.png"
    canvas.save(out_path, "PNG")
    print(f"[OK] Generated Feature Graphic: {out_path} ({canvas.width}x{canvas.height})")

# =========================================================
# 3. PROMOTIONAL PHONE SCREENSHOTS (1080x1920)
# =========================================================
def create_phone_frame(screen_content, title, subtitle):
    width, height = 1080, 1920
    canvas = Image.new("RGBA", (width, height), (5, 8, 17, 255))
    draw = ImageDraw.Draw(canvas)

    # Grid & Ambient Glow
    draw_hud_grid(draw, width, height, cell_size=50, color=(22, 160, 133, 18))
    glow = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse([100, 300, 980, 1200], fill=(22, 160, 133, 45))
    glow = glow.filter(ImageFilter.GaussianBlur(80))
    canvas.paste(glow, (0, 0), glow)

    # Top Header Copy
    font_header = load_font(46, bold=True)
    font_sub = load_font(24, bold=False)

    # Center title & subtitle
    draw.text((width // 2, 110), title, fill=(255, 255, 255, 255), font=font_header, anchor="mm")
    draw.text((width // 2, 170), subtitle, fill=(26, 188, 156, 255), font=font_sub, anchor="mm")

    # Phone Frame Container
    phone_w, phone_h = 760, 1540
    phone_x, phone_y = (width - phone_w) // 2, 230

    # Outer phone shadow & border
    draw.rounded_rectangle([phone_x - 6, phone_y - 6, phone_x + phone_w + 6, phone_y + phone_h + 6], radius=36, fill=(18, 18, 20, 255), outline=(22, 160, 133, 120), width=2)
    
    # Paste actual app UI inside phone mockup area
    screen_resized = screen_content.resize((phone_w, phone_h), Image.Resampling.LANCZOS)
    canvas.paste(screen_resized, (phone_x, phone_y))

    # Glass reflection / phone bezel overlay
    draw.rounded_rectangle([phone_x, phone_y, phone_x + phone_w, phone_y + phone_h], radius=30, outline=(255, 255, 255, 30), width=2)

    return canvas

def generate_screenshots():
    logo = Image.open("assets/rcell.jpg").convert("RGBA") if os.path.exists("assets/rcell.jpg") else Image.new("RGBA", (300, 300), (22, 160, 133))

    screens_data = [
        ("01_robo_cell_welcome.png", "WELCOME TO ROBO CELL", "Technology • Community • Innovation", "splash"),
        ("02_robo_cell_home.png", "EVERYTHING IN ONE PLACE", "Explore community updates & announcements", "home"),
        ("03_robo_cell_committees.png", "MEET THE TEAM", "Discover committees, roles & leadership", "committees"),
        ("04_robo_cell_gallery.png", "RELIVE THE MOMENTS", "Event memories & workshop highlights", "gallery"),
        ("05_robo_cell_about.png", "BUILT AROUND COMMUNITY", "Robo Cell mission, department & vision", "about"),
        ("06_robo_cell_member_access.png", "SECURE MEMBER ACCESS", "Fast member authentication & biometrics", "login")
    ]

    for filename, title, subtitle, mode in screens_data:
        screen_img = render_mock_app_ui(mode, logo)
        framed = create_phone_frame(screen_img, title, subtitle)
        out_path = os.path.join("play_store_assets/screenshots", filename)
        framed.save(out_path, "PNG")
        print(f"[OK] Generated Screenshot: {out_path} ({framed.width}x{framed.height})")

def render_mock_app_ui(mode, logo):
    # Renders pixel-perfect representation of real Robo Cell App UI screens
    width, height = 760, 1540
    ui = Image.new("RGBA", (width, height), (0, 0, 0, 255))
    draw = ImageDraw.Draw(ui)

    font_b = load_font(26, bold=True)
    font_m = load_font(20, bold=True)
    font_s = load_font(16, bold=False)

    # Status Bar
    draw.text((30, 16), "9:41", fill=(255, 255, 255, 255), font=font_s)
    draw.text((680, 16), "100%", fill=(255, 255, 255, 255), font=font_s)

    if mode == "splash":
        # Background Grid & Ambient Glow
        draw_hud_grid(draw, width, height, cell_size=40, color=(22, 160, 133, 25))
        logo_s = logo.resize((220, 220), Image.Resampling.LANCZOS)
        mask = Image.new("L", (220, 220), 0)
        ImageDraw.Draw(mask).ellipse([0, 0, 220, 220], fill=255)
        ui.paste(logo_s, (270, 520), mask)
        draw.ellipse([266, 516, 494, 744], outline=(26, 188, 156, 200), width=3)
        
        # Word reveal: ROBO CELL
        draw.text((380, 780), "ROBO", fill=(255, 255, 255, 255), font=load_font(42, bold=True), anchor="rm")
        draw.text((390, 780), "CELL", fill=(26, 188, 156, 255), font=load_font(42, bold=True), anchor="lm")
        
        # Tagline badge
        draw.rectangle([210, 850, 550, 890], fill=(18, 18, 20, 220), outline=(22, 160, 133, 160), width=1)
        draw.text((380, 870), "TECH • TRANSFORM • THRIVE", fill=(216, 207, 180, 255), font=font_s, anchor="mm")
        draw.text((380, 1420), "INITIALIZING ROBO CELL SYSTEMS...", fill=(113, 113, 122, 255), font=font_s, anchor="mm")

    elif mode == "home":
        # App Bar
        draw.rectangle([0, 50, width, 120], fill=(18, 18, 20, 255))
        draw.text((30, 75), "ROBO CELL", fill=(255, 255, 255, 255), font=font_b)
        draw.rectangle([660, 70, 730, 105], fill=(22, 160, 133, 40), outline=(26, 188, 156, 160), width=1)
        draw.text((695, 87), "GUEST", fill=(26, 188, 156, 255), font=font_s, anchor="mm")

        # Hero Banner Card
        draw.rounded_rectangle([30, 150, 730, 360], radius=16, fill=(26, 188, 156, 30), outline=(22, 160, 133, 120), width=1)
        draw.text((60, 180), "WELCOME TO ROBO CELL", fill=(26, 188, 156, 255), font=font_m)
        draw.text((60, 220), "Official Department Application", fill=(255, 255, 255, 255), font=load_font(24, bold=True))
        draw.text((60, 260), "Explore announcements, committees, events", fill=(176, 176, 184, 255), font=font_s)
        draw.text((60, 285), "and official university activities.", fill=(176, 176, 184, 255), font=font_s)

        # Quick Stats Row
        stats = [("Committees", "6 Active"), ("Events", "12+ Recorded"), ("Members", "150+")]
        for i, (label, val) in enumerate(stats):
            x = 30 + i * 240
            draw.rounded_rectangle([x, 380, x + 220, 470], radius=12, fill=(18, 18, 20, 255), outline=(255, 255, 255, 20), width=1)
            draw.text((x + 110, 405), val, fill=(216, 207, 180, 255), font=font_m, anchor="mm")
            draw.text((x + 110, 440), label, fill=(113, 113, 122, 255), font=font_s, anchor="mm")

        # Recent Announcements / Feed Cards
        draw.text((30, 500), "ANNOUNCEMENTS & UPDATES", fill=(255, 255, 255, 255), font=font_m)
        announcements = [
            ("Robotics Workshop 2026", "Hands-on session on ROS2 and Autonomous Mobile Robots.", "2 hours ago"),
            ("AI & Machine Learning Hackathon", "Registrations open for annual Robo Cell Hackathon.", "Yesterday"),
            ("General Committee Meeting", "Monthly progress review meeting for all department leads.", "3 days ago")
        ]
        for i, (t, d, time_str) in enumerate(announcements):
            y = 540 + i * 240
            draw.rounded_rectangle([30, y, 730, y + 210], radius=14, fill=(18, 18, 20, 255), outline=(22, 160, 133, 60), width=1)
            draw.text((60, y + 25), t, fill=(255, 255, 255, 255), font=font_m)
            draw.text((60, y + 65), d, fill=(176, 176, 184, 255), font=font_s)
            draw.text((60, y + 155), time_str, fill=(26, 188, 156, 255), font=font_s)

        # Bottom Nav Bar
        draw_bottom_nav(draw, width, height, active_idx=0)

    elif mode == "committees":
        # Header
        draw.rectangle([0, 50, width, 120], fill=(18, 18, 20, 255))
        draw.text((30, 75), "COMMITTEES & TEAM", fill=(255, 255, 255, 255), font=font_b)

        # Committee Cards
        committees_list = [
            ("Executive Board", "Core Leadership & Department Operations", "6 Members", (22, 160, 133)),
            ("Technical Committee", "Robotics, Embedded Systems & Software", "18 Members", (26, 188, 156)),
            ("Design & Creative", "UI/UX, Visual Branding & Media", "12 Members", (216, 207, 180)),
            ("Public Relations & Media", "Outreach, Sponsorships & Communications", "14 Members", (22, 160, 133)),
            ("Event Management", "Logistics, Workshops & Hackathons", "15 Members", (26, 188, 156))
        ]
        for i, (name, desc, count, color) in enumerate(committees_list):
            y = 150 + i * 230
            draw.rounded_rectangle([30, y, 730, y + 200], radius=16, fill=(18, 18, 20, 255), outline=(color[0], color[1], color[2], 100), width=1)
            draw.text((60, y + 30), name, fill=(255, 255, 255, 255), font=font_m)
            draw.text((60, y + 70), desc, fill=(176, 176, 184, 255), font=font_s)
            
            # Member badge
            draw.rectangle([60, y + 130, 200, y + 165], fill=(color[0], color[1], color[2], 30), outline=(color[0], color[1], color[2], 120), width=1)
            draw.text((130, y + 147), count, fill=(color[0], color[1], color[2], 255), font=font_s, anchor="mm")

        draw_bottom_nav(draw, width, height, active_idx=1)

    elif mode == "gallery":
        # Header
        draw.rectangle([0, 50, width, 120], fill=(18, 18, 20, 255))
        draw.text((30, 75), "EVENT GALLERY", fill=(255, 255, 255, 255), font=font_b)

        # Gallery Grid Items
        items = [
            ("Robo Exhibition 2026", "Autonomous Robot Demo Day", (22, 160, 133)),
            ("AI Workshop", "Deep Learning Hands-on Session", (26, 188, 156)),
            ("Robo Soccer Tournament", "Inter-college Robotics Competition", (216, 207, 180)),
            ("Orientation 2026", "Welcoming New Members", (22, 160, 133))
        ]
        for i, (title, sub, col) in enumerate(items):
            y = 150 + i * 290
            draw.rounded_rectangle([30, y, 730, y + 260], radius=16, fill=(18, 18, 20, 255), outline=(col[0], col[1], col[2], 100), width=1)
            # Inner preview rectangle
            draw.rounded_rectangle([50, y + 20, 710, y + 170], radius=10, fill=(col[0], col[1], col[2], 25))
            draw.text((380, y + 95), title, fill=(255, 255, 255, 255), font=font_m, anchor="mm")
            draw.text((60, y + 195), sub, fill=(176, 176, 184, 255), font=font_s)
            draw.text((60, y + 225), "Robo Cell Event Memory", fill=(26, 188, 156, 255), font=font_s)

        draw_bottom_nav(draw, width, height, active_idx=2)

    elif mode == "about":
        # Header
        draw.rectangle([0, 50, width, 120], fill=(18, 18, 20, 255))
        draw.text((30, 75), "ABOUT ROBO CELL", fill=(255, 255, 255, 255), font=font_b)

        # About Card
        draw.rounded_rectangle([30, 150, 730, 520], radius=16, fill=(18, 18, 20, 255), outline=(22, 160, 133, 100), width=1)
        logo_s = logo.resize((120, 120), Image.Resampling.LANCZOS)
        mask = Image.new("L", (120, 120), 0)
        ImageDraw.Draw(mask).ellipse([0, 0, 120, 120], fill=255)
        ui.paste(logo_s, (60, 180), mask)

        draw.text((210, 200), "ROBO CELL", fill=(255, 255, 255, 255), font=font_b)
        draw.text((210, 240), "Department Application v1.0.0", fill=(26, 188, 156, 255), font=font_s)
        draw.text((60, 320), "Robo Cell is the premier technical department", fill=(176, 176, 184, 255), font=font_s)
        draw.text((60, 350), "dedicated to Robotics, Artificial Intelligence,", fill=(176, 176, 184, 255), font=font_s)
        draw.text((60, 380), "Embedded Systems, and Student Innovation.", fill=(176, 176, 184, 255), font=font_s)

        # Pillars Cards
        pillars = [
            ("OUR MISSION", "To empower students with hands-on technical skills in robotics, machine learning, and hardware prototyping."),
            ("OUR VISION", "Fostering an ecosystem of innovation, technical excellence, and national competition victories."),
            ("COMMUNITY", "Connected department platform bridging alumni, senior mentors, leads, and active student members.")
        ]
        for i, (p_title, p_desc) in enumerate(pillars):
            y = 550 + i * 260
            draw.rounded_rectangle([30, y, 730, y + 230], radius=14, fill=(18, 18, 20, 255), outline=(255, 255, 255, 20), width=1)
            draw.text((60, y + 30), p_title, fill=(216, 207, 180, 255), font=font_m)
            draw.text((60, y + 80), p_desc[:45], fill=(176, 176, 184, 255), font=font_s)
            draw.text((60, y + 110), p_desc[45:], fill=(176, 176, 184, 255), font=font_s)

        draw_bottom_nav(draw, width, height, active_idx=3)

    elif mode == "login":
        # Header
        draw.text((380, 160), "MEMBER ACCESS", fill=(255, 255, 255, 255), font=font_b, anchor="mm")
        draw.text((380, 200), "Select your committee & member profile", fill=(176, 176, 184, 255), font=font_s, anchor="mm")

        # Form Fields
        draw.text((50, 270), "SELECT COMMITTEE", fill=(26, 188, 156, 255), font=font_s)
        draw.rounded_rectangle([50, 300, 710, 370], radius=12, fill=(18, 18, 20, 255), outline=(22, 160, 133, 120), width=1)
        draw.text((80, 335), "Technical Committee", fill=(255, 255, 255, 255), font=font_m, anchor="lm")

        draw.text((50, 410), "SELECT MEMBER PROFILE", fill=(26, 188, 156, 255), font=font_s)
        draw.rounded_rectangle([50, 440, 710, 510], radius=12, fill=(18, 18, 20, 255), outline=(22, 160, 133, 120), width=1)
        draw.text((80, 475), "Robo Cell Lead Member", fill=(255, 255, 255, 255), font=font_m, anchor="lm")

        draw.text((50, 550), "PASSWORD", fill=(26, 188, 156, 255), font=font_s)
        draw.rounded_rectangle([50, 580, 710, 650], radius=12, fill=(18, 18, 20, 255), outline=(22, 160, 133, 120), width=1)
        draw.text((80, 615), "••••••••••••", fill=(255, 255, 255, 255), font=font_m, anchor="lm")

        # Login Button
        draw.rounded_rectangle([50, 710, 710, 785], radius=14, fill=(22, 160, 133, 255))
        draw.text((380, 747), "SIGN IN TO ROBO CELL", fill=(255, 255, 255, 255), font=font_m, anchor="mm")

        # Biometric Button Card
        draw.rounded_rectangle([50, 830, 710, 930], radius=14, fill=(18, 18, 20, 255), outline=(26, 188, 156, 100), width=1)
        draw.text((380, 865), "USE BIOMETRIC AUTHENTICATION", fill=(26, 188, 156, 255), font=font_m, anchor="mm")
        draw.text((380, 898), "Touch fingerprint sensor to verify identity", fill=(113, 113, 122, 255), font=font_s, anchor="mm")

        # Guest mode button
        draw.rounded_rectangle([50, 1340, 710, 1410], radius=14, fill=(18, 18, 20, 255), outline=(255, 255, 255, 20), width=1)
        draw.text((380, 1375), "CONTINUE AS GUEST", fill=(216, 207, 180, 255), font=font_m, anchor="mm")

    return ui

def draw_bottom_nav(draw, width, height, active_idx=0):
    nav_y = height - 90
    draw.rectangle([0, nav_y, width, height], fill=(18, 18, 20, 255), outline=(255, 255, 255, 15), width=1)
    
    items = ["Home", "Committees", "Gallery", "About"]
    step = width // len(items)
    font_s = load_font(15, bold=True)
    
    for i, item in enumerate(items):
        cx = i * step + step // 2
        col = (26, 188, 156, 255) if i == active_idx else (113, 113, 122, 255)
        draw.ellipse([cx - 10, nav_y + 16, cx + 10, nav_y + 36], fill=col)
        draw.text((cx, nav_y + 60), item, fill=col, font=font_s, anchor="mm")

def main():
    ensure_dirs()
    print("[*] Generating Play Store Assets...")
    generate_app_icon()
    generate_feature_graphic()
    generate_screenshots()
    print("[OK] All Visual Assets Generated Successfully!")

if __name__ == "__main__":
    main()
