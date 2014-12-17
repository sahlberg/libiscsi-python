#!/usr/bin/env python
from os import environ

try:
    from setuptools import setup, Extension
    from setuptools.command.build_ext import build_ext
except ImportError:
    from distutils.core import setup, Extension
    from distutils.command.build_ext import build_ext


name = 'libiscsi'
version = '1.0'
release = '1'
versrel = version + '-' + release
readme = 'README'
download_url = "https://github.com/sahlberg/libiscsi-python/libiscsi-" + \
                                                          versrel + ".tar.gz"
long_description = file(readme).read()

_libiscsi = Extension(name='libiscsi._libiscsi',
                      sources=['libiscsi/libiscsi_wrap.c'],
                      libraries=['iscsi'],
)


setup(name = name,
      version = versrel,
      description = 'A libiscsi wrapper for Python.',
      long_description = long_description,
      license = 'LGPLv2.1',
      platforms = ['any'],
      author = 'Ronnie Sahlberg',
      author_email = 'ronniesahlberg@gmail.com',
      url = 'https://github.com/sahlberg/libiscsi-python/',
      download_url = download_url,
      packages = ['libiscsi'],
      classifiers = [
          'Development Status :: 4 - Beta',
          'Intended Audience :: Developers',
          'Operating System :: OS Independent',
          'Programming Language :: C',
          'Programming Language :: Python',
          'Topic :: Software Development :: Libraries :: Python Modules',
      ],
      ext_modules = [_libiscsi],
      )
