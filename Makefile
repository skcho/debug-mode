.PHONY: all example clean

OCB=ocamlbuild -use-ocamlfind -pkg str

all:
	$(OCB) debugmode.cmo debugmode.cmx debugmode.cma debugmode.cmxa debugmode.docdir/index.html

example:
	$(OCB) debugmode_example.native

clean:
	$(OCB) -clean
