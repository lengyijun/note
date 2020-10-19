.PHONY: all serve
all: 
	mdbook build -d docs

serve:
	mdbook serve -d docs

src/%.png: src/%.gv
	dot -Tpng $< -o $@
