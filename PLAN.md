# Emberwake — Dev Plan

## วิธีรันเดโม่
```
godot --path "d:\เกม"        # หรือเปิดโฟลเดอร์ใน Godot แล้วกด F5
```
ควบคุม: WASD เดิน | Space/J โจมตี | Shift/K กลิ้งหลบ | R เริ่มใหม่

## Milestones
| # | งาน | สถานะ |
|---|---|---|
| M1 | เดโม่ Boss fight (รูปทรงแทน sprite): ผู้เล่น, ลูกสมุน, บอส 2 เฟส | เสร็จ (ยังไม่ได้ playtest) |
| M2 | เจน sprite ด้วย PixelLab (ตาม emberwake-prompts.md) แล้วแทนที่รูปทรง | รอ |
| M3 | Tilemap เมือง + Y-sort + PointLight2D + Tilt-shift shader | รอ |
| M4 | ย้ายลอจิกไปใช้ `boss.gd` / `companion.gd` (FSM + NavigationAgent2D) พร้อม AnimationPlayer | รอ |
| M5 | Waystation (ฮับ/เซฟ), UI (หัวใจ, มานา, สล็อตไอเทม), บทสนทนา | รอ |
| M6 | Export Web → อัปขึ้น itch.io เป็นเดโม่สาธารณะ | รอ |
