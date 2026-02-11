
import os
import re

path = r"c:\xampp\htdocs\Online-Test-Web-Application-master\Online-Test-Web-Application\web\controller.jsp"

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Pattern to find string literals split by newlines and excessive indentation
# Simplified: Find a quote, then words on newlines, then closing quote.
# This might be tricky if it spans too many lines.
# Another approach: Find lines that have an odd number of quotes and join with next line.

lines = content.splitlines()
fixed_lines = []
i = 0
while i < len(lines):
    line = lines[i]
    stripped = line.strip()
    
    # If line has an unclosed string literal
    if stripped.count('"') % 2 != 0:
        # Try to join with subsequent lines until closed
        j = i + 1
        combined = line
        while j < len(lines):
            combined += " " + lines[j].strip()
            if combined.count('"') % 2 == 0:
                break
            j += 1
        if j < len(lines):
            # Successfully closed
            # Clean up the spaces we added
            combined = re.sub(r'\s+', ' ', combined).strip()
            # Restore some indentation
            indent = line[:line.find(stripped)]
            fixed_lines.append(indent + combined)
            i = j + 1
            continue
    
    fixed_lines.append(line)
    i += 1

with open(path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(fixed_lines))
