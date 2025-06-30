#!/bin/bash

# === USER CONFIGURATION ===

EXECUTABLE="/proj/cmip6/data/ocean_reanalysis/emu/emu_userinterface_dir/emu"
ASSET_DIR="/proj/cmip6/data/ocean_reanalysis/emu/emu_assets"  # Contains run_jupyter.sh, requirements.yml, ECCOv4-py, emu-utilities
BLOCKED_DIR="/proj/cmip6/data/ocean_reanalysis/emu"

REQUIRED_FILES=("run_jupyter.sh" "requirements.yml")
REQUIRED_LINKS=("ECCOv4-py" "emu-utilities")

# === SAFETY CHECK: Location ===

CURRENT_DIR=$(realpath "$PWD")
BLOCKED_DIR=$(realpath "$BLOCKED_DIR")

if [[ "$CURRENT_DIR" == "$BLOCKED_DIR" || "$CURRENT_DIR" == "$BLOCKED_DIR/"* ]]; then
  echo "Error: This script cannot be run from '$BLOCKED_DIR' or any of its subdirectories."
  echo "You are currently in: $CURRENT_DIR"
  exit 1
fi

# === SAFETY CHECK: Executable ===

if [[ ! -x "$EXECUTABLE" ]]; then
  echo "Error: Executable '$EXECUTABLE' not found or not executable."
  exit 1
fi

# === SETUP FILES ===

echo "Preparing working directory with EMU support files..."

for FILE in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$FILE" ]]; then
    echo "  → Copying missing file: $FILE"
    cp "$ASSET_DIR/$FILE" . || { echo "Failed to copy $FILE from $ASSET_DIR"; exit 1; }
  else
    echo "  ✓ Found file: $FILE"
  fi
done

for FOLDER in "${REQUIRED_LINKS[@]}"; do
  if [[ ! -e "$FOLDER" ]]; then
    echo "  → Linking missing directory: $FOLDER (read-only)"
    ln -s "$ASSET_DIR/$FOLDER" "$FOLDER" || { echo "Failed to link $FOLDER from $ASSET_DIR"; exit 1; }
    chmod -R a-w "$FOLDER" 2>/dev/null || true
  else
    echo "  ✓ Found directory or link: $FOLDER"
  fi
done

# === PARTITION PROMPT ===

echo "Available node types: compute, scavenger, bigmem"
read -p "Enter node type (press Enter to use default: compute): " PARTITION

if [[ -z "$PARTITION" ]]; then
  PARTITION="compute"
  echo "No input received. Defaulting to partition: compute"
else
  echo "Selected partition: $PARTITION"
fi

if [[ ! "$PARTITION" =~ ^(compute|scavenger|bigmem)$ ]]; then
  echo "Invalid choice: '$PARTITION'. Valid options are: compute, scavenger, bigmem."
  exit 1
fi

# === LAUNCH ===

echo "Requesting interactive SLURM node on partition '$PARTITION'..."
salloc --partition="$PARTITION" --nodes=1 --ntasks=1 --time=01:00:00 --qos=interactive --pty bash -i -c "$EXECUTABLE"
