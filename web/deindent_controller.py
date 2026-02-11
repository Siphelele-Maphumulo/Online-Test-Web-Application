
import os
import re

path = r"c:\xampp\htdocs\Online-Test-Web-Application-master\Online-Test-Web-Application\web\controller.jsp"

with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    stripped = line.lstrip()
    indent_len = len(line) - len(stripped)
    # If indentation is excessive (e.g. > 100), reduce it proportionally or just reset
    if indent_len > 80:
        # Heuristic: keep some of the relative indentation but remove the massive offset
        new_indent = " " * (indent_len % 4)
        new_lines.append(new_indent + stripped)
    else:
        new_lines.append(line)

with open(path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
