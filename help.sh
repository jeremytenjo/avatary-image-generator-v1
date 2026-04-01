#!/usr/bin/env bash

cat <<'TXT'
Dynamic ComfyUI Commands

- bash start.sh
  Select a project and install/start ComfyUI.

- bash start-new-project.sh
  Switch to a different project and optionally clean previous project resources.

- bash update-nodes-and-models.sh
  Refresh nodes/models from the latest project manifest and restart ComfyUI.

- bash restart-comfyui.sh
  Restart ComfyUI service.

- bash help.sh
Show this help menu.
TXT
