Backend TuxGuitar (Java):

- Criar mÃ³dulo Java com TuxGuitar Core.
- Expor endpoints REST:
  - POST /parse (arquivo gp3 â†’ JSON)
  - POST /export-midi
  - POST /convert (gp3 â†’ musicxml)
- Consumir via HTTP no Flutter (dio/http).
