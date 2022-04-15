cd "src"
7z a -tzip ../love2d/It-Came-from-the-Forest.love @../ziplist.txt
cd "../love2d/"
copy /b "love.exe"+"It-Came-from-the-Forest.love" "../dist/It-Came-from-the-Forest.exe"
cd ..
rem RCEDIT.exe /I dist/It-Came-from-the-Forest.exe game.ico
if not exist "dist/files/areas" mkdir "dist/files/areas"
if not exist "dist/files/atlases" mkdir "dist/files/atlases"
cd "src/files/areas/"
copy "*.lua" "../../../dist/files/areas/"
cd "../atlases"
copy "*.json" "../../../dist/files/atlases/"
cd "../../"
copy "attribution.txt" "../dist/"
cd ..
