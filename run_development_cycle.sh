#!/bin/bash

set -o errexit

eval `opam config env`
opam install --yes utop bisect_ppx bisect-summary ocamlfind ocamlbuild js_of_ocaml-compiler cppo_ocamlbuild
clear

function build {
    ocamlbuild \
        -use-ocamlfind -no-links \
        -X _build \
        -plugin-tag "package(cppo_ocamlbuild)" \
        $@
}

# @todo Should we use module aliases instead of packs? (https://caml.inria.fr/pub/docs/manual-ocaml-4.02/extn.html#sec235)
for directory in $(find src -mindepth 1 -type d)
do
    # echo "Rebuilding ${directory}.mlpack from $directory's contents"
    ls $directory/*.ml* | sed "s#\..*##" | sort -u >${directory}.mlpack
done

build -build-dir _build/native \
    src/Foundations/ResetPervasives.inferred.mli \
    General.cmxa unit_tests.native

python3 <<END
def complete_definitions():
    with open("_build/native/src/Foundations/ResetPervasives.inferred.mli") as f:
        current_line = None
        for line in f:
            line = line.strip()
            if any(line.startswith(prefix + " ") for prefix in ["exception", "external", "type", "val", "module"]):
                if current_line is not None:
                    yield current_line
                current_line = line
            else:
                current_line += " " + line
        yield current_line

ok = True
for line in complete_definitions():
    assert line.count(" : ") <= 1, line
    if (
        "\`Please_use_General_" not in line and
        line not in ["exception Exit", "module LargeFile : sig"] and
        all(not line.startswith("external __{}__ : ".format(x)) for x in ["LOC", "FILE", "LINE", "MODULE", "POS", "LOC_OF", "LINE_OF", "POS_OF"])
    ):
        ok = False
        print("Not reset in Pervasives:", line)

if not ok:
    exit(1)
END

python3 <<END
def all_please_uses():
    with open("_build/native/src/Foundations/ResetPervasives.inferred.mli") as f:
        for line in f:
            for word in line.split():
                if word.startswith("\`Please_use_") and not word.endswith("__todo"):
                    yield word[12:].replace("__", ".")
with open("demo/demo_pervasives.ml", "w") as f:
    for symbol in sorted(set(all_please_uses())):
        if symbol.endswith("Reference.t") or symbol.endswith("Format.t"):
            f.write("let (_: _ {} option) = None\n".format(symbol))
        elif symbol.endswith(".t"):
            f.write("let (_: {} option) = None\n".format(symbol))
        else:
            f.write("let _ = {}\n".format(symbol))
END

cd demo
# This simulates the 'opam install' process, but is quicker
rm -rf _build/with_lib
mkdir -p _build/with_lib
cp ../_build/native/src/General.cmi ../_build/native/src/General.a ../_build/native/src/General.cmxa _build/with_lib
cp ../_build/native/src/*.cmx _build/with_lib
build -build-dir _build/with_lib  -package num -lib General demo.native demo_pervasives.native demo_syntactic_sugar.native
cd ..

build -build-dir _build/coverage \
    -package bisect_ppx -tag debug \
    -tag-line 'true:+open(DependenciesForBisectPpx)' \
    -tag-line '<DependenciesForBisectPpx.*>:-open(DependenciesForBisectPpx)' \
    unit_tests.byte

# @todo Could we build with *one* module using bisect_ppx and measure coverage of this module by its own tests?
# Currently, a few functions are measured as covered because they are used in the test framework.

echo
echo "Running unit tests in byte code"
_build/coverage/src/unit_tests.byte
rm -f bisect????.out
_build/coverage/src/unit_tests.byte --verbose > _build/coverage/unit_tests_output.txt
echo
bisect-summary bisect????.out | grep -v -e "^100.0% \[.*\] src/" -e "^100.0% .*ForBisectPpx.ml$" -e "^  0.0% \[.*0/0.*\] src/"
echo
bisect-ppx-report -I _build/coverage -html _build/coverage/bisect bisect????.out
echo "See coverage report (for General's unit tests) in $(pwd)/_build/coverage/bisect/index.html"
rm -f bisect????.out

js_of_ocaml +nat.js _build/coverage/src/unit_tests.byte

echo
echo "Running unit tests in node.js"
node _build/coverage/src/unit_tests.js
rm -f bisect????.out

echo
echo "Running demo"
demo/_build/with_lib/demo.native

echo
echo "Exporting interface as seen in utop"
rm -rf doc/utop
mkdir doc/utop

python3 <<END
import contextlib
import os
import re
import subprocess

class Module:
    def __init__(self, name, arguments, signature):
        self.name = name
        self.arguments = arguments
        self.signature = signature

    def text(self, indent=""):
        arguments = ""
        if indent == "" and self.arguments:
            arguments = "".join(argument.text(indent) for argument in self.arguments)
        signature = ""
        if indent == "" or not self.signature.is_empty():
            signature = ": {}".format(self.signature.text(indent))
        return "{}module {}{}{}\n".format(indent, self.name, arguments, signature)

class FunctorArgument:
    def __init__(self, name, signature):
        self.name = name
        self.signature = signature

    def text(self, indent):
        return "({}: {})".format(self.name, self.signature.text(indent))

class Alias:
    def __init__(self, name, base):
        self.name = name
        self.base = base

    def text(self, indent):
        return "{}module {} = {}\n".format(indent, self.name, self.base)

class Name:
    def __init__(self, name):
        self.name = name

    def is_empty(self):
        return False

    def text(self, indent):
        return "{}".format(self.name)

class Signature:
    def __init__(self, elements):
        self.elements = elements

    def is_empty(self):
        return not self.elements

    def text(self, indent):
        return "sig\n{}{}end".format("".join(element.text("  " + indent) for element in self.elements), indent)

class ModuleType:
    def __init__(self, name, signature):
        self.name = name
        self.signature = signature

    def text(self, indent):
        return "{}module type {} = {}\n".format(indent, self.name, self.signature.text(indent))

class Atom:
    def __init__(self, definition):
        self.definition = definition

    def text(self, indent):
        return "{}{}\n".format(indent, " ".join(self.definition))

class UTop:
    def __init__(self, process):
        process.stdout.readline()
        process.stdout.readline()
        self.__process = process
        self.__tokens = []

    def show_module(self, module_name):
        self.__process.stdin.write("#show_module {};;\n".format(module_name))
        self.__process.stdin.flush()
        self.__assert_token("#")
        return self.__parse_module()

    def __refill_tokens(self, n):
        if len(self.__tokens) <= n:
            self.__tokens = re.split(r"\s+", self.__process.stdout.readline().strip().replace("(", "( ").replace(")", " )"))
            # print("Tokens:", self.__tokens)

    def __next_token(self):
        self.__refill_tokens(0)
        tok = self.__tokens[0]
        self.__tokens = self.__tokens[1:]
        return tok

    def __peek_token(self, n=0):
        self.__refill_tokens(n)
        return self.__tokens[n]

    def __assert_token(self, expected):
        tok = self.__next_token()
        if tok != expected:
            print("Expected '{}' but got '{}'".format(expected, tok))
            exit(1)

    kinds = {"module", "val", "type", "exception", "external"}
    ends = {None, "end"}
    atom_ends = kinds | ends

    def __parse_module(self):
        self.__assert_token("module")
        name = self.__next_token()
        if self.__peek_token() == ":":
            self.__assert_token(":")
            arguments = self.__parse_functor_arguments()
            signature = self.__parse_signature()
            return Module(name, arguments, signature)
        else:
            self.__assert_token("=")
            base = self.__next_token()
            return Alias(name, base)

    def __parse_functor_arguments(self):
        arguments = []
        if self.__peek_token() == "functor":
            self.__assert_token("functor")
            while self.__peek_token() == "(":
                self.__assert_token("(")
                name = self.__next_token()
                self.__assert_token(":")
                signature = self.__parse_signature()
                argument = FunctorArgument(name, signature)
                self.__assert_token(")")
                arguments.append(argument)
            self.__assert_token("->")
        return arguments

    def __parse_signature(self):
        if self.__peek_token() == "sig":
            self.__assert_token("sig")
            if self.__peek_token() == "...":
                self.__assert_token("...")
                elements = []
            else:
                elements = self.__parse_elements()
            self.__assert_token("end")
            return Signature(elements)
        else:
            return Name(self.__next_token())

    def __parse_elements(self):
        elements = []
        while self.__peek_token() not in self.ends:
            element = self.__parse_element()
            elements.append(element)
        return elements

    def __parse_element(self):
        assert self.__peek_token() in self.kinds, "Unkwnown kind: {}".format(self.__peek_token())
        if self.__peek_token() == "module":
            if self.__peek_token(1) == "type":
                return self.__parse_module_type()
            else:
                return self.__parse_module()
        else:
            return self.__parse_atom()

    def __parse_module_type(self):
        self.__assert_token("module")
        self.__assert_token("type")
        name = self.__next_token()
        self.__assert_token("=")
        signature = self.__parse_signature()
        return ModuleType(name, signature)

    def __parse_atom(self):
        definition = [self.__next_token()]
        while self.__peek_token() not in self.atom_ends:
            definition.append(self.__next_token())
        return Atom(definition)

@contextlib.contextmanager
def utop(*options):
    process = subprocess.Popen(["utop"] + list(options), stdin=subprocess.PIPE, stdout=subprocess.PIPE, universal_newlines=True)
    yield UTop(process)
    process.communicate()

with utop("-I", "demo/_build/with_lib") as utop:
    def show(module_name):
        # print(module_name)
        module = utop.show_module(module_name)
        with open("doc/utop/{}.txt".format(module_name), "w") as f:
            f.write(module.text().replace("( ", "(").replace(" )", ")").replace(" :", ":"))

        if module_name not in [
            "General.Pervasives.OCamlStandard",
            "General.Abbr",
            "General.Standard",
        ]:
            for element in module.signature.elements:
                if isinstance(element, Module) and element.signature.is_empty():
                    show("{}.{}".format(module_name, element.name))

    show("General")
END

for m in src/*.mlpack
do
    m=${m%.mlpack}
    m=${m#src/}
    grep --color -e "[^\.]$m\." doc/utop/*.txt && exit 1
done

if [ "x$1" == "x--quick" ]
then
    exit
fi

opam pin add --yes --no-action .
opam reinstall --yes General

cd demo
rm -rf _build/with_package
build -build-dir _build/with_package -package General demo.byte demo.native
cd ..

if (which sphinxcontrib-ocaml-autodoc && which sphinx-build) >/dev/null
then
    echo
    echo "Building doc"
    echo

    build -build-dir _build/for_autodoc -tag keep_docs General.cmi

    rm -rf _build/sphinx  # Keep while we're developing the Sphinx extension
    sphinx-build doc _build/sphinx/html -d _build/sphinx/doctrees
    rm -rf docs
    cp -r _build/sphinx/html docs
    touch docs/.nojekyll
    rm -f docs/.buildinfo
    echo
    echo "See documentation in $(pwd)/docs/index.html"
else
    echo
    echo "Not trying to build doc because autoocamldoc or sphinx-build is missing"
fi

echo
echo "Development cycle OK"
