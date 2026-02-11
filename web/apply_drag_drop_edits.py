
import os
import re

path = r"c:\xampp\htdocs\Online-Test-Web-Application-master\Online-Test-Web-Application\web\controller.jsp"

with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Phase 1: Reconstruct
reconstructed = []
current = ""
for line in lines:
    stripped = line.strip()
    if not stripped:
        if current: reconstructed.append(current)
        current = ""
        reconstructed.append("")
        continue
    if stripped.startswith("//"):
        if current: reconstructed.append(current)
        current = ""
        reconstructed.append(line.rstrip())
        continue
    if current: current += " " + stripped
    else: current = stripped
    if stripped.endswith(";") or stripped.endswith("{") or stripped.endswith("}") or stripped.endswith("%>") or stripped.endswith("*/"):
        reconstructed.append(current)
        current = ""
if current: reconstructed.append(current)

content = "\n".join(reconstructed)

# Phase 2: Apply Edits

# 1. Variable declarations in multipart section
content = content.replace(
    'String correctMultiple = ""; String imagePath = null;',
    'String correctMultiple = ""; String imagePath = null; String draggableItemsJson = ""; String dropZonesJson = "";'
)

# 2. Extract fields in multipart loop
content = content.replace(
    'else if ("correctMultiple".equals(fieldName)) { correctMultiple = nz(fieldValue, ""); }',
    'else if ("correctMultiple".equals(fieldName)) { correctMultiple = nz(fieldValue, ""); } else if ("draggableItemsJson".equals(fieldName)) { draggableItemsJson = nz(fieldValue, ""); } else if ("dropZonesJson".equals(fieldName)) { dropZonesJson = nz(fieldValue, ""); }'
)

# 3. addNewQuestion logic in multipart section
# We need to replace the call to pDAO.addNewQuestion
# Note: I'll use a regex-like approach or just careful replacement
pattern = r'pDAO\.addNewQuestion\(questionText,\s*opt1,\s*opt2,\s*opt3,\s*opt4,\s*correctAnswer,\s*courseName,\s*questionType,\s*imagePath\);'
replacement = """
if ("DragAndDrop".equalsIgnoreCase(questionType)) {
    pDAO.addDragDropQuestion(questionText, courseName, imagePath, draggableItemsJson, dropZonesJson);
} else {
    pDAO.addNewQuestion(questionText, opt1, opt2, opt3, opt4, correctAnswer, courseName, questionType, imagePath);
}
""".strip()

content = re.sub(pattern, replacement, content)

# 4. Same for non-multipart section (ignoring images for now as D&D usually has items)
# Wait, let's find the non-multipart section variable declarations
content = content.replace(
    'String questionType = nz(request.getParameter("questionType"), "");',
    'String questionType = nz(request.getParameter("questionType"), ""); String draggableItemsJson = nz(request.getParameter("draggableItemsJson"), ""); String dropZonesJson = nz(request.getParameter("dropZonesJson"), "");'
)

# 5. Non-multipart addNewQuestion call
# The non-multipart call usually doesn't have imagePath or it's null
pattern_non_multi = r'pDAO\.addNewQuestion\(questionText,\s*opt1,\s*opt2,\s*opt3,\s*opt4,\s*correctAnswer,\s*courseName,\s*questionType,\s*null\);'
content = re.sub(pattern_non_multi, replacement.replace("imagePath", "null"), content)


with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
