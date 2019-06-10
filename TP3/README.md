# Trabalho Prático de DLS, Gramáticas e Yacc
## MIEI - Processamento de Linguagens - Universidade do Minho (2018/2019)

No ficheiro `estrutura_base.txt` encontram-se todos os tipos de atributos
em cada nodo, bem como o formato base das relações.

Os ficheiros de exemplo bem sucedidos são:
* `artista_obra_relacao.txt` - exemplo mais simples
* `roberto_de_niro.txt` - grafo mais bonito, com vários artistas, obras e eventos

Quanto a ficheiros de exemplo com erros sintáticos, são estes:
* `idRepetido.txt` - exemplo de repetição de ID
* `relacaoComIdInexistente.txt` - exemplo de relação com ID não válido
* `relacaoIncompleta.txt` - exemplo de relação sem um dos lados
* `tagInexistente.txt` - exemplo de tag que não está incluída na gramática
* `tagsRepetidas.txt` - exemplo de tag que aparece mais que uma vez num nodo
* `tipoErrado.txt` - exemplo de tag cujo valor é do tipo errado

Para gerar o svg, utiliza-se:
`dot -Tsvg graph.dot -o graph.svg`
