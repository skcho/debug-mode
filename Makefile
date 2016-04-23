.PHONY: all clean

all:
	ocamlbuild -use-ocamlfind src/main.native

clean:
	ocamlbuild -clean
