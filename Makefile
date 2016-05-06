.PHONY: all build doc install uninstall clean example

all: build

configure:
	ocaml setup.ml -configure

build:
	ocaml setup.ml -build

doc:
	ocaml setup.ml -doc

install:
	ocaml setup.ml -install

uninstall:
	ocaml setup.ml -uninstall

clean:
	ocaml setup.ml -clean

example: example/example.ml
	ocamlbuild -use-ocamlfind -pkg=str,debugmode example/example.native
