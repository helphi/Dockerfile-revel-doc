revel.github.io
===============

[![Build Status](https://travis-ci.org/revel/revel.github.io.svg?branch=master)](https://travis-ci.org/revel/revel.github.io)

Documentation for the [Revel framework](https://github.com/revel/revel)

This [jekyll](http://jekyllrb.com/) powered site is located at [revel.github.io](http://revel.github.io).

To compile and view the site locally:

```
$ gem install jekyll kramdown jekyll-redirect-from octopress-escape-code
$ git clone git@github.com:revel/revel.github.io.git
$ cd revel.github.io
$ jekyll serve
```

**Important**
Due to a bug in some versions of jekyll, you may get a lot of console output such as
```
Regenerating: 97 files at 2015-01-17 22:46:09 ...done.
Regenerating: 97 files at 2015-01-17 22:46:28 ...done.
... snipped ...
Regenerating: 97 files at 2015-01-17 22:47:44 ...done.
Regenerating: 97 files at 2015-01-17 22:48:03 ...done.
```

In this case start jekyll with the 'destination' directory outside the tree, eg
```
$ jekyll serve -d ../revel_site_build
```