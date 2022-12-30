---
title: 'Migração do site para Franklin.jl'
date: '2021-06-28'
tags: ['julia', 'franklin', 'site']
---

Há algum tempo o Jekyll tem me dado trabalho.
Como não sou usuário de Ruby, volta e meia falta alguma coisa na minha instalação e eu passo horas tentando corrigir o problema pra fazer meu site rodar localmente.
Para o CiDAMO, eu considerei o Hugo, já que tem mais suporte e eu não seria a única pessoa a cuidar do site.
Já para meu site pessoal, e o site do [Julia Smooth Optimizers](https://juliasmoothoptimizers.github.io), resolvi usar Franklin, já que eu quero mais é usar Julia mesmo.

## Vantagens

**Franklin.jl é Julia,** então eu tenho mais facilidade em manter e até mesmo de contribuir.
O site é um repositório Julia, então tudo está dentro do esperado.

**Franklin.jl roda Julia,** isto é, dá pra usar Julia pra gerar conteúdo **E** pra fazer tutoriais.
Por exemplo, a lista de posts na página principal do blog é gerada por um script em Julia que lê os diretórios e imprime o markdown para a página.
Por outro lado, os tutoriais do JSO e minhas notas de Cálculo Numérico rodam o código mostrado e a saída é mostrada, então o código está sempre atualizado (ou visivelmente quebrado).

**_Builda_ no GitHub actions.** Então, eu consigo hostear no próprio github. É como GHA é o padrão do Julia, é fácil de achar suporte.

## Desvantagens

**Pode ficar lento,** já que tem que compilar e rodar o código.
Por exemplo, as notas de cálculo numérico levam 40 minutos para rodar, porque tem dezenas de imagens e algumas animações.
Eu tive que fazer uma gambiarra para separar as notas do site. Falo mais sobre isso [aqui](#gambiarra).

**Não é óbvio como manter layouts diferentes.** Por exemplo, se eu quiser ter um layout de `blog` separado de um layout de `page`, não parece óbvio como.
Eu posso colocar `if`s pra separar conteúdo, mas não é tão natural.

**Ainda não está muito estável.** Naturalmente, já que é bem novo, mas dá pra sentir quando se precisa achar alguma coisa específica.

## Gambiarra

Meu site tem 3 partes:

- a base, que consiste principalmente de material estático que eu pretendo atualizar de vez em quando (novos pacotes, pesquisa, orientações, cargos, etc.);
- as notas de cálculo numérico, que depois de pronto deve ver pouca atualização, mas que leva 40 minutos pra compilar no GitHub Actions.
- o blog, que idealmente vê atualizações frequentes, e por isso vou fingir que terá atualizações frequentes.

Se eu coloco todos juntos, então qualquer mudança na base ou no blog leva 40 minutos pra compilar no GitHub Actions por causa das notas de cálculo numérico.

Por outro lado, se eu separo todas, mudanças no CSS, layout, javascript, etc., não são atualizadas.

A solução, simples, é de só manter os arquivos de CSS, layout, javascript, etc., na base e copiá-los no build do GitHub Actions para os outros repositórios.
Além disso, adiciono essas pastas no `.gitignore`, e localmente é só copiá-las para os repositórios que precisam dela.
Aqui a adição ao GitHub actions:

```yaml
- name: Clone abelsiqueira.github.io
  run: |
    wget https://github.com/abelsiqueira/abelsiqueira.github.io/archive/refs/heads/main.zip
    unzip main.zip
    mv abelsiqueira.github.io-main/_layout .
    mv abelsiqueira.github.io-main/_css .
    mv abelsiqueira.github.io-main/_libs .
    rm -rf abelsiqueira.github.io-main main.zip
```

## Conclusão

No fim das contas, sair do Jekyll para o Franklin vai ser uma experiência interessante.
Devo fazer alguns posts atualizados usando as novas capacidades do Franklin, e aí veremos se valeu a pena ou não.
Também queria ter usado a oportunidade para aprender o Hugo, mas uma coisa de cada vez.
