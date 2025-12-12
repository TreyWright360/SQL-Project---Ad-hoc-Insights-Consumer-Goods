@echo off
echo Starting Local Dashboard Server...
echo.
echo Your dashboard is now live at: http://localhost:8000/index.html
echo.
echo Keep this window OPEN while presenting in PowerPoint.
echo Close this window to stop the server.
echo.
python -m http.server 8000
pause
