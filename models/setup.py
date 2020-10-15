import setuptools

# how to launch:
# pex -r requirements.txt -o compile.pex . -e wad_reader:pack_archive --validate-entry-point

# how to pack
# python setup.py sdist

# how to install
# python -m venv sandbox
# sandbox/script/activate
# pip install wad_reader-0.0.1.tar.gz
# python
# >>from wad_reader import pack_archive
# >>
setuptools.setup(
    name="wad_reader",
    version="1.7",
    author="https://twitter.com/FSouchu",
    description="POOM archive compiler for PICO8",
    url="https://github.com/freds72/qk8",
    py_modules=[
      'abstract_stream',
      'bsp_compiler',
      'colormap_reader',
      'DECORATELexer',
      'DECORATEListener',
      'DECORATEParser',
      'DECORATEVisitor',
      'decorate_reader',
      'dotdict',
      'export_vspr',
      'file_stream',
      'image_reader',
      'python2pico',
      'TEXTURESLexer',
      'TEXTURESListener',
      'TEXTURESParser',
      'TEXTURESVisitor',
      'textures_reader',
      'MAPINFOLexer',
      'MAPINFOListener',
      'MAPINFOParser',
      'MAPINFOVisitor',
      'mapinfo_reader',
      'udmfLexer',
      'udmfListener',
      'udmfParser',
      'udmfVisitor',
      'udmf_reader',
      'wad_reader',
      'wad_stream',
      'lzs'],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: Apache 2.0 License",
        "Operating System :: OS Independent",
    ],
    install_requires=[
        'antlr4-python3-runtime>=4.8',
        'Pillow>=7.2.0',
        'tqdm>=4.49.0'
    ],
    python_requires='>=3.6',
    entry_points = {
        'console_scripts': [
            'compule = wad_reader:main'
        ]
    }
)
