
from typing import Callable, Any

from os.path import exists, join, dirname, realpath
import os.path

from htask import define_task, Context
from htask import load_env, save_env, is_file_busy
from htask.progs import msvc, nasm

F = Callable

default_build_type = "Debug"

project_folder = dirname(realpath(__file__))
output_folder  = os.path.sep.join([project_folder, "build"])

source_file: F[[str], str] = lambda f: os.path.sep.join([project_folder, f])
configuration_folder: F[[str], str] = lambda build_type: os.path.sep.join([output_folder, build_type]) # noqa


@define_task(name="clean")
def clean_(c: Context, build_type=default_build_type):

    if c.exists(output_folder):
        c.run(f"rmdir /S /Q {output_folder}")

@define_task()
def build(c: Context, build_type=default_build_type, clean=False, reconfigure=False):

    if clean:
        _clean(c, build_type)

    if not c.exists(configuration_folder(build_type)):
        c.run(f"mkdir {configuration_folder(build_type)}")

    cached_env = c.join(configuration_folder(build_type), "vc_build.env")

    if not reconfigure and exists(cached_env):
        build_env = load_env(cached_env)
    else:
        build_env = msvc.extract_env_from_vcvars(c)
        save_env(cached_env, build_env)

    pong_obj = c.join(configuration_folder(build_type), "pong.obj")

    nasm.assemble(
        c, (source_file("pong.asm"),),
        output=pong_obj,
        output_format="win64",
        debug_format="cv8"
    )

    msvc.compile(
        c, [],
        output=join(configuration_folder(build_type), "pong.exe"),
        libs=[pong_obj, "raylib.lib", "kernel32.lib", "user32.lib", "gdi32.lib", "shell32.lib", "Winmm.lib", "ucrt.lib"],
        link_flags=["/DEBUG:FULL", "/LARGEADDRESSAWARE:NO"],
        compile_flags=[
            "/MTd",
            "/Zi",
            "/std:c++20",
            "/W4",
            "/Od",   # Disables optimizations
            "/GR-",  # Disables RTTI
            "/nologo"
        ],
        env=build_env
    )

