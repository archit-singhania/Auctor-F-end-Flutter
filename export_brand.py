"""Export the original vector-style Auctor mark to platform icon sizes."""
from pathlib import Path
from PIL import Image,ImageDraw
root=Path(__file__).resolve().parent

def mark(size):
    scale=8; n=size*scale; im=Image.new('RGBA',(n,n),(0,0,0,0)); d=ImageDraw.Draw(im)
    unit=n/128
    def points(coords): return [(int(x*unit),int(y*unit)) for x,y in coords]
    d.rounded_rectangle((0,0,n-1,n-1),radius=34*unit,fill='#173E38')
    d.polygon(points([(32,91),(60,30),(73,30),(97,91),(81,91),(75,74),(52,74),(45,91)]),fill='#F3D5A0')
    d.polygon(points([(57,61),(71,61),(64,42)]),fill='#173E38')
    d.line(points([(82,43),(92,53),(107,35)]),fill='#F4F5F0',width=max(1,int(7*unit)),joint='curve')
    return im.resize((size,size),Image.Resampling.LANCZOS)

for folder in [root/'android/app/src/main/res', root/'ios/Runner/Assets.xcassets/AppIcon.appiconset',root/'macos/Runner/Assets.xcassets/AppIcon.appiconset']:
    for image in folder.rglob('*.png'):
        if 'ic_launcher' in image.name or 'app_icon' in image.name or 'Icon-App' in image.name:
            size=Image.open(image).size[0]; mark(size).save(image)
mark(1024).save(root/'assets/images/logo.png')
mark(64).save(root/'web/favicon.png')
mark(192).save(root/'web/icons/icon-192.png')
mark(512).save(root/'web/icons/icon-512.png')
mark(512).save(root/'web/icons/icon.png')
mark(256).save(root/'windows/runner/resources/app_icon.ico',sizes=[(16,16),(32,32),(48,48),(64,64),(128,128),(256,256)])
# A social preview with the same visual identity.
im=Image.new('RGB',(1200,630),'#F5F4EC');im.paste(mark(200),(80,185),mark(200));d=ImageDraw.Draw(im)
from PIL import ImageFont
font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',62); small=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',30)
d.text((330,210),'auctor',font=font,fill='#173E38');d.text((333,302),'Proof of your craft.',font=small,fill='#173E38');im.save(root/'web/social-preview.png')
