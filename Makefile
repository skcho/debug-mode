OCB_FLAGS = -use-ocamlfind -I lib -I src
OCB = ocamlbuild $(OCB_FLAGS)

.PHONY: all clean

all:
	$(OCB) src/main.native

doc:
	$(OCB) api.docdir/index.html

clean:
	ocamlbuild -clean
