
tailwindcss:
	npx tailwindcss build src/main.css -o src/main.output.css 

build: tailwindcss
	elm-app build


run: tailwindcss
	elm-app start
  
