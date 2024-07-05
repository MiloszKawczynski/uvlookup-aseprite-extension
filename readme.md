# UV Lookup Plugin for Aseprite

The UV Lookup plugin for Aseprite allows you to create a lookup table for 2D animations, similar to the technique proposed by [aarthificial in this video](https://youtu.be/HsOKwUwL1bE?si=8FbnN9xGiev-icns). After installing the plugin, you can find the UV Lookup option under the Edit menu or by pressing `Ctrl+L`.

## Setup:

### Create Two Sprites:

1. **Lookup**: This sprite should have two layers named `uv` and `color`, with `uv` underneath.
2. **Source**: This sprite should only have a `uv` layer.

## Options in the UV Lookup Window:

### **Make Lookup Button**

**Before Clicking:**
- Draw an unwrapped shape of the character on the `uv` layer in the `lookup` sprite.
- Select the `uv` layer in the `lookup` sprite.

**Function:**
- This will map the UVs onto your sprite.

### **Make Source Button**

**Before Clicking:**
- Draw the character's animation on the `uv` layer in the `source` sprite.
- Select the `uv` layer in the `source` sprite.
- Choose the lookup direction. This defines the direction in which the colors will be applied.

**Function:**
- This applies colors from the lookup to your animation. Remember, you need to create the lookup first using the Make Lookup button. You may need to manually create the color animation using the UVs; the Make Source button helps with basic shapes.

### **Empty Color**

- You can select a color to be treated as an empty color. Transparent colors cannot be used as empty colors in the lookup; instead, you need to choose a specific color to be treated as empty.

### **Sync Button**

**Before Clicking:**
- Select the `uv` layer in the `source` file.
- Choose the lookup and source files from the dropdown lists.

**Function:**
- The first click on sync will inform you about the creation of the `color` layer. Subsequent clicks will synchronize the colors.

**Note:**
- You can continue to make changes to the animation on the `uv` layer in both the lookup and source files, as well as on the `color` layer in the lookup file. Do not edit the `color` layer in the source file. If it gets corrupted, delete the entire layer and sync again.
- After any changes to colors or animation, press sync to reapply the colors.

## Additional Information

This extension was developed for personal use and may not be perfect. If you encounter any issues or have any questions, feel free to reach out via email at zamylosz@gmail.com.
