# coding: utf8

# Copyright 2017 Vincent Jacques <vincent@vincent-jacques.net>

import glob
import json
import os
import sys


master_doc = "index"
project = "General"
author = '<a href="http://vincent-jacques.net/">Vincent Jacques</a>'
copyright = ('2017 {} <script>var jacquev6_ribbon_github="{}"</script>'.format(author, project) +
             '<script src="https://jacquev6.github.io/ribbon.js"></script>')
extensions = []

# Local directory sphinx-ocaml
sys.path.append(os.path.join(os.path.dirname(__file__), "sphinx-ocaml"))
extensions.append("ocaml")
primary_domain = "ocaml"

nitpicky = True
nitpick_ignore = [
]

# https://github.com/bitprophet/alabaster
# html_theme_path
extensions.append("alabaster")
html_theme = "alabaster"
html_sidebars = {
    "**": ["about.html", "navigation.html", "searchbox.html"],
}
html_theme_options = {
    "github_user": "jacquev6",
    "github_repo": project,
    "travis_button": True,
}
# html_logo = "logo.png"

# @todoc Develop an autodoc-like extension to skip the .json file and slim the .rst file
# @todoc Develop an doctests-like extension

with open("reference.json") as f:
    reference = json.load(f)

with open("reference.rst", "w") as f:
    f.write("=========\n")
    f.write("Reference\n")
    f.write("=========\n")
    f.write("\n")
    f.write(".. WARNING This file is generated by conf.py. Manual changes will be lost.\n")
    f.write("\n")
    f.write(".. module:: General\n\n")

    def write_text(indent, text):
        for line in text.strip().splitlines():
            f.write("{}{}\n".format(indent, line.strip()))
        f.write("\n")

    def recurse(indent, module):
        for element in module:
            if element["__class__"] == "signature_item:module":
                f.write("{}.. module:: {}\n\n".format(indent, element["name"]))
                for doc in element["doc"]:
                    write_text("  " + indent, doc)
                if element["type"]["__class__"] == "module_type:signature":
                    recurse("  " + indent, element["type"]["elements"])
            elif element["__class__"] == "signature_item:floating_documentation":
                write_text(indent, element["text"])
            elif element["__class__"] == "signature_item:value":
                f.write("{}.. val:: {}\n".format(indent, element["name"]))
                f.write("{}    type: {}\n\n".format(indent, " ".join(x.strip() for x in element["type"].splitlines())))
                for doc in element["doc"]:
                    write_text("  " + indent, doc)
            elif element["__class__"] == "signature_item:type":
                f.write("{}.. type:: {}\n\n".format(indent, element["name"]))
                for doc in element["doc"]:
                    write_text("  " + indent, doc)

    recurse("  ", reference)
