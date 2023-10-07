---
title: Jill
description: 'Julia language command line installer'
featured_image: '/images/banners/jill.jpg'
order: 2
---

[Jill](https://github.com/abelsiqueira/jill) is a command line installer for Julia.
It works with Linux and OSX via `bash`, and you can quickly start using it with

```bash
curl -fsSL https://raw.githubusercontent.com/abelsiqueira/jill/main/jill.sh > jill.sh
sudo bash jill.sh
```

## More in-depth

The objectives of Jill are

- One line installation of any Julia version;
- Easy to maintain/update when a new Julia version is released;
- Be lightweight with low dependencies.

Whenever a version of Julia is installed, links are made to `julia-x`, `julia-x.y` and `julia-x.y.z`.

The main ways to use Jill are:

- `sudo bash jill.sh`: Installs the latest stable version;
- `sudo bash jill.sh --lts`: Installs the latest Long-Term-Support version;
- `sudo bash jill.sh --rc`: Installs the latest release candidate;
- `sudo bash jill.sh --version x.y.z`: Installs the specific version `x.y.z`;
- `sudo bash jill.sh -u x.y`: Installs the latest stable version and copies the environment from `x.y`.
