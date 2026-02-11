
import os

path = r"c:\xampp\htdocs\Online-Test-Web-Application-master\Online-Test-Web-Application\web\controller.jsp"

with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
i = 0
while i < len(lines):
    line = lines[i]
    # Check for the specific broken block around line 340
    if 'res.put("message",' in line and i + 5 < len(lines):
        # res.put("message",
        # "Please
        # fill
        # in
        # all
        # fields.");
        if '"Please' in lines[i+1] and 'fields.");' in lines[i+5]:
            indent = line[:line.find('res.put')]
            new_lines.append(f'{indent}res.put("message", "Please fill in all fields.");\n')
            i += 6
            continue
    
    # Check for another one: staffNumber matches
    if '(!staffNumber.matches("' in line and i + 1 < len(lines):
        if '\\d{6}"))' in lines[i+1]:
             indent = line[:line.find('(!staffNumber.matches')]
             new_lines.append(f'{indent}(!staffNumber.matches("\\\\d{{6}}"))\n')
             i += 2
             continue

    # Check for staffNumber error message
    if 'res.put("message",' in line and i + 6 < len(lines):
         # "Staff
         # Number
         # must
         # be
         # exactly
         # 6
         # digits.");
         if '"Staff' in lines[i+1] and 'digits.");' in lines[i+7]:
              indent = line[:line.find('res.put')]
              new_lines.append(f'{indent}res.put("message", "Staff Number must be exactly 6 digits.");\n')
              i += 8
              continue

    new_lines.append(line)
    i += 1

with open(path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
