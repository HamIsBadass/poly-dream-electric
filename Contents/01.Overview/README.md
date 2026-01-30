# 01.Overview - Mars Make Production

**Purpose**: Mars Make GUI editing and final .mars file output

## Structure

```
01.Overview/
├── tree.toml          # Scene hierarchy (optional reference)
├── resource/          # Image assets (7 PNG files)
│   ├── gnb_00.png (664×884)
│   ├── guide_00.png (700×400)
│   ├── guide_btn_00.png (652×120)
│   ├── poi_arrow_00.png (352×568)
│   ├── portal_01.png (1024×1024)
│   ├── portal_02.png (1024×1024)
│   └── toast_00.png (664×184)
└── 01.Overview.mars   # Production file (created via Mars Make GUI)
```

## Mars Make Workflow

### Step 1: Create New Project
1. Open Mars Make application
2. File → New or load `tree.toml` as starting point
3. Create scene group: `overview_scene_group`
4. Create scene: `overview_scene` (Manual type)

### Step 2: Add Image Objects
Add 7 image objects to `overview_scene`:

| Object | Position (X, Y, Z) | Resource |
|--------|-------------------|----------|
| gnb_00 | (0.0, 0.0, 0.0) | gnb_00.png |
| guide_00 | (0.5, 0.0, 0.0) | guide_00.png |
| guide_btn_00 | (1.0, 0.0, 0.0) | guide_btn_00.png |
| poi_arrow_00 | (1.5, 0.0, 0.0) | poi_arrow_00.png |
| portal_01 | (2.0, 0.0, 0.0) | portal_01.png |
| portal_02 | (2.5, 0.0, 0.0) | portal_02.png |
| toast_00 | (3.0, 0.0, 0.0) | toast_00.png |

### Step 3: Connect Resources
1. Select each image object in hierarchy
2. In Inspector panel, click "Resource" field
3. Navigate to `resource/` folder and select corresponding PNG
4. Mars Make automatically applies original aspect ratio (1x scale)

### Step 4: Save & Publish
1. **Save**: Ctrl+S or File → Save
2. **Publish**: File → Publish (creates final .mars file)
3. File saved as `01.Overview.mars` (Mars Make format, ~6-7 MB)

## Important Notes

✅ **Mars Make Format**:
- Only files created/edited in Mars Make GUI can be saved
- Automatic aspect ratio preservation (no manual scale adjustment needed)
- Internal format compatible with save/publish functionality

⚠️ **Do NOT Use**:
- MCP-built Mars files (incompatible with Mars Make save)
- object.toml files (Mars Make ignores these)
- Manual .mars file editing

📋 **Reference Documentation**:
- See `01.Overview.dev/objects/` for object.toml specifications
- Use as manual reference when creating objects in Mars Make GUI

## Comparison with 00_Intro.mars

This folder follows the same workflow as `00_Intro/`:
- Empty objects/ folder (Mars Make doesn't use object.toml)
- Basic tree.toml for hierarchy reference
- Final .mars file created entirely through Mars Make GUI
- Save/publish functionality works correctly
