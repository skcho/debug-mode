OCB_FLAGS = -use-ocamlfind -I lib
EX_FLAGS = -I example
OCB = ocamlbuild $(OCB_FLAGS)

.PHONY: all example doc clean

all:
	$(OCB) debugmode.cma
	$(OCB) debugmode.cmxa

example:
	$(OCB) $(EX_FLAGS) example.native

doc:
	$(OCB) api.docdir/index.html

clean:
	ocamlbuild -clean
