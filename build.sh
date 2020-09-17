rm -rf ./build
mkdir -p ./build
crystal run generate-site.cr -- --output-html > ./build/index.html
cp -r ./images ./build/images
