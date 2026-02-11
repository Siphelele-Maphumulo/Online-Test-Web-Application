
try:
    with open(r"c:\xampp\htdocs\Online-Test-Web-Application-master\Online-Test-Web-Application\web\controller.jsp", "r", encoding="utf-8") as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            if 1140 <= i <= 1180:
                print(f"{i+1}: {line.rstrip()}")
except Exception as e:
    print(e)
