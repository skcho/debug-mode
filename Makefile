.PHONY: all install uninstall clean doc

all:
	ocaml setup.ml -build

install:
	ocaml setup.ml -install

uninstall:
	ocaml setup.ml -uninstall

clean:
	ocaml setup.ml -clean

doc:
	ocaml setup.ml -doc

example.native:
	ocamlbuild -use-ocamlfind -pkgs=debugmode,str example/example.native
