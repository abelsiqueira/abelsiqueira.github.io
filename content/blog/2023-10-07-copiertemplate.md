---
title: "COPIERTemplate.jl: A new template for Julia using copier"
date: '2023-10-07'
featured_image: '/images/banners/copiertemplate.jpg'
tags:
  - 'julia'
  - 'template'
  - 'copier'
  - 'best-practices'
---

I help manage over 50 packages in the [Julia Smooth Optimizers](https://jso.dev) organization, and sometimes we have to make a small update to all of these packages.
For instance, one of the workflows was updated, or something new is introduced, or the LTS version of Julia changes.

In these situations, our usual approach is to create some script that downloads all of these packages, then apply the change, then creates a pull request with the modifications.

My new idea is the package/template [COPIERTemplate.jl](https://github.com/abelsiqueira/COPIERTemplate.jl).
The repo provides a template for the [copier](https://copier.readthedocs.io/en/stable/) app with many of the things that I want to use in my packages.
I can apply the template to existing packages and then if there updates to the template, I can just run the update command and get a patch with the new changes.
I can select things to be ignored, and since it uses git, it will sometimes notice that it shouldn't try to fix some changes.

![COPIERTemplate visualization](/images/banners/copiertemplate.jpg)

One of the things in this template is a workflow that automatically runs the copier update command to check if there are updates and then creates a pull request with the changes.

To test the template, the repo itself is a Julia package created with the template.
This package just adds the `copier` app using `PythonCall.jl` and calls it for the user - not my preferred usage, actually, but people can use it to avoid installing Python packages.

## Comparison to PkgTemplates.jl

One big package related to templates is `PkgTemplates.jl`, which I have previously suggested in my videos.
There are a few similarities and differences, which you might find useful to decide which package to use:

### Both packages provide a quick interface to generate a new Julia package

When you use either package, the end result will be a folder with the necessary structure for a Julia package that can be quickly registered.

### PkgTemplates has more options (as of October/2023)

PkgTemplates has many options, while COPIERTemplate provides the bare minimum for me to use with JSO packages.
This might change in the future, depending on the pull requests of future collaborators.

### The logic is handled in different places

The logic, in this context, imply options (i.e., conditionals).

COPIERTemplate is a `copier` template, i.e., it follows the specification of another software called `copier` that uses Jinja for the the "logic".
In other words, COPIERTemplate does _nothing_ but call `copier` and provide a folder in Jinja format.

PkgTemplates is written in Julia, and the logic is implemented in Julia.

> **WARNING**
>
> To be honest, I don't really know how PkgTemplates.jl work, because I only saw a part of the code.
> Feel free to send me any corrections of what was portrayed here.

The underlying substitution in PkgTemplates.jl seems to handled by another package called Mustache.jl that implements a logicless templating system called mustache.
In other words, PkgTemplates handles most of the hard part.

The advantages - for me - are that I don't have to maintain a templating package, just a template.

### COPIERTemplate can be applied to existing packages

One of the reasons for me to get into this template was that I need to apply it to existing packages.
To be honest, I wasn't really expecting that this would be a problem, but apparently it is.

The reason that COPIERTemplate can be applied to existing packages is because `copier` handles it, not COPIERTemplate itself, as I mentioned above.

### If COPIERTemplate gets an update, the packages using it can get the update

Again, this is handled by `copier`.
When I make a change to one of the `pre-commit` hooks and release a new version, it should be possible to update the package using COPIERTemplate with a single command (`copier update`).

### There is a workflow to automatically check for updates

This is the only complex thing that I made in this whole endeavor.
I have included a GitHub workflow in the template that runs the update command above once a week, and if there are updates, it will create a pull request with these updates.

## Closing remarks

It is still early to see how useful the template will be.
Hopefully, other people will want to use it for their package as well, since there is nothing specific to JSO.
Get in touch if you want to be involved, and [leave a star](https://github.com/abelsiqueira/COPIERTemplate.jl) if you found the project interesting.
