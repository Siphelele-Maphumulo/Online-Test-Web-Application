
import os
import re

path = r"c:\xampp\htdocs\Online-Test-Web-Application-master\Online-Test-Web-Application\web\controller.jsp"

with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
current_line = ""

for line in lines:
    stripped = line.strip()
    if not stripped:
        if current_line:
            new_lines.append(current_line)
            current_line = ""
        new_lines.append("")
        continue
    
    # Heuristic: if it's a very short line or doesn't end with a terminator, join it
    # Terminators: ; { } %>
    # Also handle comments
    if stripped.startswith("//"):
        if current_line:
            new_lines.append(current_line)
            current_line = ""
        new_lines.append(line.rstrip())
        continue
    
    if current_line:
        current_line += " " + stripped
    else:
        current_line = stripped
        
    if stripped.endswith(";") or stripped.endswith("{") or stripped.endswith("}") or stripped.endswith("%>") or stripped.endswith("*/"):
        new_lines.append(current_line)
        current_line = ""

if current_line:
    new_lines.append(current_line)

with open(path, 'w', encoding='utf-8') as f:
    f.write("\n".join(new_lines))
