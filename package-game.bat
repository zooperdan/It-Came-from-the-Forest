cd "src"
7z a -tzip ../love2d/It-Came-from-the-Forest.love @../package-game.txt
cd "../love2d/"
copy /b "love.exe"+"It-Came-from-the-Forest.love" "../dist/It-Came-from-the-Forest/It-Came-from-the-Forest.exe"
rem del "It-Came-from-the-Forest.love"
cd ..
if not exist "dist/It-Came-from-the-Forest/files/areas" mkdir "dist/It-Came-from-the-Forest/files/areas"
if not exist "dist/It-Came-from-the-Forest/files/atlases" mkdir "dist/It-Came-from-the-Forest/files/atlases"
cd "src/files/areas/"
copy "*.lua" "../../../dist/It-Came-from-the-Forest/files/areas/"
cd "../atlases"
copy "*.json" "../../../dist/It-Came-from-the-Forest/files/atlases/"
cd "../../"
copy "attribution.txt" "../dist/It-Came-from-the-Forest/"
cd "../dist/"
7z a -tzip It-Came-from-the-Forest.zip ./It-Came-from-the-Forest/
cd ..
