# 01.Overview.dev - MCP Development & Testing

**Purpose**: MCP BuildContent development and validation environment

## Structure

```
01.Overview.dev/
├── tree.toml          # Scene hierarchy (shared with production)
├── objects/           # Object property definitions (object.toml files)
│   ├── overview_scene_group/
│   ├── overview_scene/
│   ├── gnb_00/
│   ├── guide_00/
│   ├── guide_btn_00/
│   ├── poi_arrow_00/
│   ├── portal_01/
│   ├── portal_02/
│   └── toast_00/
└── build/             # MCP BuildContent output (gitignored)
    └── 01.Overview.mars
```

## Workflow

### 1. Development Phase
- Edit `objects/*/object.toml` files to define object properties
- Reference `resource/` folder in production for image assets
- Use object.toml as specification/reference for Mars Make manual work

### 2. Testing Phase
```powershell
# Build with MCP BuildContent
mcp_mcp-server-ma_BuildContent -contentName "01.Overview"

# Output: build/01.Overview.mars (2.3 MB with embedded resources)
# Validation: Check for errors, verify resource packaging
```

### 3. Production Application
- **Do NOT use MCP-built .mars files in Mars Make** (incompatible)
- Manually apply object.toml specifications in Mars Make GUI
- Save production file in `../01.Overview/` folder

## Key Files

### tree.toml
- Defines scene hierarchy (same as production)
- Format: `format_version = 3`, roots, nodes with parent-child relationships

### objects/*/object.toml
- Object property definitions (Transform, Resource, Image, etc.)
- Scale values: Match PNG dimensions (e.g., gnb_00: [0.664, 0.884, 1.0])
- Resource paths: Filename only (e.g., "gnb_00.png")
- Required components: Core (editing_color), Transform, Resource, Image

## Important Notes

⚠️ **MCP Limitations**:
- MCP-built Mars files are for **testing only**
- Mars Make cannot save/publish MCP-built files
- object.toml serves as **manual reference**, not automated input

✅ **Proper Usage**:
- Use MCP for validation and testing complex configurations
- Apply validated specifications manually in Mars Make
- Keep object.toml as documentation for future reference

## Git Workflow

- **Commit**: objects/ folder (specifications)
- **Ignore**: build/ folder (temporary build outputs)
- See main .gitignore for exclusion rules
