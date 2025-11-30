@echo off
echo Adding firewall rule for Python server on port 8000...
netsh advfirewall firewall add rule name="Python AI Server" dir=in action=allow protocol=TCP localport=8000
echo Done! Firewall rule added.
pause
