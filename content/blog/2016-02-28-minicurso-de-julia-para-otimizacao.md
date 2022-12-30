---
title: 'Minicurso de Julia para Otimização'
date: '2016-02-28'
tags:
  - 'julia'
  - 'work'
  - 'optimization'
---

Semana passada, nos dias 22 a 24 de Fevereiro aconteceu o VIII Simpósio de
Análise Numérica e Otimização.
Nesse evento, eu apresentei um minicurso de Julia com foco em Otimização não
Linear.
Entre 10 e 15 pessoas participaram no total, entre alunos de graduação, de
pós-graduação, e professores.
O objetivo principal era apresentar a linguagem e alguns detalhes importante
para otimização não linear, o que foi obtido.
Por outro lado, as aulas foram mais longas do que deveriam, e o conteúdo ficou
muito esparso, pois tive que variar entre o básico e uma aplicação mais
avançada.
Para o próximo workshop, provavelmente focarei na introdução, que foi a primeira
aula.

O conteúdo pode ser obtido
[aqui](https://github.com/abelsiqueira/julia-workshop), e consiste de três
[notebooks em Jupyter](http://jupyter.org/), uma introdução e outros arquivos.

Para rodar os notebooks, você precisa instalar o
[Jupyter](http://jupyter.org/), o [Julia](http://julialang.org/) e o
[IJulia](https://github.com/JuliaLang/IJulia.jl).
Alternativamente, use o [JuliaBox](https://juliabox.org/) para rodá-los online.

Além disso, para a segunda aula em diante você precisa do CUTEst, que pode ser
instalado seguindo
[este post]({{local_prefix}}/installing-cutest-and-cutest.jl/).

Minha recomendação de editor é o [Atom](http://atom.io), com os plugins
`language-julia` e `latex-completions`.

Para uma experiência com testes automatizados, veja também
[este post]({{local_prefix}}/automated-testing/).
