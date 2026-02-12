@echo off
cd "C:\xampp\mysql\bin"
mysql -u root -p online_test < "c:\xampp\htdocs\Online-Test-Web-Application-master\Online-Test-Web-Application\create_drag_drop_table.sql"
pause
