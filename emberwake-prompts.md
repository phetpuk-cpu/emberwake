# Emberwake — HD-2D Art Prompt Pack

ชื่อเกมใหม่: **Emberwake** (เดิม "Ash of Light") — อัศวินผมขาวกับเด็กชายผ้าพันคอส้ม เดินทางผ่านเมืองที่ถูกเถ้าถ่านกลืน

**สไตล์อ้างอิง:** HD-2D pixel art, มุมกล้อง 3/4 top-down เอียงลง ~45°, tilt-shift (เบลอหน้า/หลัง), แสงอบอุ่นหม่น, depth of field, bloom, God rays ผ่านต้นไม้, UI มุมซ้ายบน (หัวใจ + แถบมานา) และสล็อตไอเทมมุมซ้ายล่าง

## 1. ฉากบอสไฟต์ / บรรยากาศเมือง (Act 2)

```
HD-2D pixel art game screenshot, 3/4 top-down view tilted about 45 degrees, tilt-shift depth of field with blurred foreground foliage, warm golden-hour light rays through trees, bloom, volumetric dust. Ruined stone town outskirts with a collapsed house, cobblestone path, wooden fences, torches and a campfire. A white-haired female knight in a red cloak casting a blue glowing magic circle around a standing stone checkpoint, a young boy companion with an orange scarf and small sword beside her, facing a giant dark armored boss knight with a huge greatsword wrapped in red glowing embers and floating damage number. HUD: hearts and blue mana bar top-left, area title "Ashen Outskirts - Act 2" top-right, boss health bar above boss, item slots bottom-left. Melancholic but warm dark fantasy, 32-bit pixel art, crisp pixels, high detail.
```

## 2. ตัวละคร & ลูกสมุน (Sprites)

```
2D pixel art character sheet, isolated on solid magenta background for transparency cropping. 1) female knight, long white hair, red cloak, sword. 2) young boy companion, orange scarf, small sword. 3) giant boss knight in dark armor with glowing red embers. Poses: idle, walk, attack, hit reaction. 3/4 top-down view matching HD-2D game camera, 48x48 to 128x128 px, 32-bit pixel art, strong outlines, high contrast, consistent top-right lighting.
```

## 3. Environment Tileset

```
2D pixel art environment tileset for a ruined gothic town, 3/4 top-down orthographic view, 16x16 and 32x32 seamless tiles, transparent background. Cobblestone paths, dirt roads, stone walls, broken rooftops, wooden fences, campfires, torches, broken street lamps, small tents, barrels, crates, rubble, grass and dry shrubs. Light layer of gray ash, melancholic dark fantasy, soft warm highlights, consistent top-right light source.
```

## 4. Waystation (จุดเซฟ/พักค่าย) — อ้างอิงภาพที่ 1

```
HD-2D pixel art camp hub seen from 3/4 top-down, tilt-shift blur, lush grass, canvas tents, dirt crossroad path, wooden fence border, NPCs idling, campfire, merchant wagon, glowing rune circle with stone checkpoint at center, soft sunlight, bloom, area name label "Waystation" at top.
```

## เคล็ดลับ Godot (ตั้งค่าไว้ใน `scenes/main.tscn` แล้ว)

- `World` เปิด `y_sort_enabled` → ตัวละครเดินอ้อมหน้า/หลังสิ่งก่อสร้าง (ลูกของ World ต้องเปิด Y Sort ด้วย)
- `CanvasModulate` ให้โทนสีอบอุ่น + ใส่ `PointLight2D` ที่คบเพลิง/กองไฟ
- Texture filter = Nearest เพื่อพิกเซลคมชัด
- ทำ tilt-shift: `CanvasLayer` + ColorRect ใช้ shader เบลอตามแกน Y (ขอบบน/ล่าง) และเปิด Glow ใน `WorldEnvironment`
- PixelLab: ล็อกขนาด sprite และจานสีเดียวกันทั้งเกม
