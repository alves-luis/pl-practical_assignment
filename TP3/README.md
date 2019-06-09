# Trabalho Prático de DLS, Gramáticas e Yacc
## MIEI - Processamento de Linguagens - Universidade do Minho (2018/2019)

No ficheiro `estrutura_base.txt` encontram-se todos os tipos de atributos
em cada nodo, bem como o formato base das relações.

Os ficheiros de exemplo bem sucedidos são:
* `artista_obra_relacao.txt` - exemplo mais simples
* `roberto_de_niro.txt` - grafo mais bonito, com vários artistas, obras e eventos

Quanto a ficheiros de exemplo com erros sintáticos, são estes:
* Ainda não existem :/

Para popular um ficheiro com nodos do tipo obra, utiliza-se:
`gawk -f povoa_obra.awk < film.csv > obras.txt`

Para gerar o svg, utiliza-se:
`dot -Tsvg graph.dot -o graph.svg`
