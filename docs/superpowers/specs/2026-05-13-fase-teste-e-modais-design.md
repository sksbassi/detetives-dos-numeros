# Design: Fase de Teste, Fechar Modais e Menu/Pause

## Objetivo

Adicionar uma fase de teste na tela inicial, permitir fechar os modais de premiacao e som com um `X`, e consolidar o acesso de menu e pausa em um unico fluxo com o rotulo `Menu/Pause`.

## Escopo

As mudancas ficam concentradas no fluxo principal ja controlado por `scripts/main.gd` e na cena principal `scenes/main.tscn`. Nao sera criada uma nova cena jogavel separada. A fase de teste deve reutilizar a mesma interface de uma fase comum.

## Requisitos Funcionais

### 1. Botao de fase de teste na tela inicial

- A tela inicial deve exibir um novo botao para iniciar uma fase de teste.
- O botao so deve iniciar a fase de teste se o jogador tiver preenchido um nome.
- A fase de teste deve usar a mesma aparencia visual e a mesma estrutura de interacao de uma fase comum.
- A fase de teste nao deve contar como fase real da progressao principal.
- Sempre que a fase de teste for iniciada, o jogo deve gerar uma conta matematica aleatoria nova para o jogador resolver.

### 2. Conclusao da fase de teste

- Ao acertar a resposta da fase de teste, o fluxo normal de avanço deve ser interrompido.
- Deve aparecer um modal com mensagem de incentivo no estilo `Muito Bem!!! Podemos comecar nossa aventura???!!!`.
- O modal deve ter dois botoes:
- `SIM!`: fecha o modal, encerra o estado de teste e inicia o jogo real na Fase 1.
- `TELA INICIAL`: fecha o modal, encerra o estado de teste e volta para a tela inicial do jogo.

### 3. Modal de premiacao com fechar

- O modal de premiacao precisa de um botao `X` no canto superior direito.
- Ao clicar no `X`, o modal deve apenas fechar.
- Ao fechar, o jogador deve retornar para a fase que estava em andamento, sem reiniciar rodada nem voltar para a tela inicial.

### 4. Modal de som com fechar

- A area de som dentro do overlay atual tambem precisa de um botao `X` no canto superior direito.
- Ao clicar no `X`, o overlay deve ser fechado e o jogador retorna para a fase atual.
- O fechamento nao deve alterar pontuacao, progresso, rodada, cronometro pausado ou selecao atual.

### 5. Menu/Pause unificado

- O botao principal do HUD que hoje representa pausa deve passar a exibir o texto `Menu/Pause`.
- Esse botao continuara abrindo o overlay atual, agora tratado como o modal unificado de menu e pausa.
- O modal unificado deve preservar as funcionalidades ja existentes:
- continuar
- reiniciar fase
- reiniciar jogo
- voltar ao inicio
- abrir premiacao
- abrir som

## Design Tecnico

### Estado da fase de teste

Sera adicionado um estado explicito para diferenciar o jogo real da fase de teste. Esse estado controlara:

- qual conjunto de dados deve ser carregado na fase atual
- se pontuacao e progressao principal devem ser ignoradas
- se o acerto final deve abrir o modal de convite em vez de seguir para a proxima fase

Nesse modo, a pergunta nao vira do array principal de `phases`. Ela sera criada em tempo de execucao a partir de uma conta aleatoria simples, com alternativas geradas no mesmo formato da UI atual.

### Reaproveitamento da UI principal

Como a cena principal ja contem cards, cronometro, opcoes e sistema de feedback, a fase de teste reutilizara a mesma renderizacao da fase comum. A diferenca ficara apenas na origem dos dados, no bloqueio de pontuacao e no desfecho do acerto.

### Modal de convite apos o teste

O modal de feedback dinamico ja criado em `main.gd` sera reaproveitado para o fim da fase de teste. Ele precisa aceitar duas acoes novas:

- iniciar o jogo real na fase 1
- retornar ao overlay inicial

### Botoes `X` de fechamento

Os modais de premiacao e som receberao um botao de fechar no cabecalho. O fechamento deve usar uma funcao simples de esconder overlay/modal, sem efeitos colaterais extras. O objetivo e preservar o contexto da fase.

### Menu/Pause unificado

Nao sera criado um segundo modal. O overlay de pausa atual continuara sendo a unica superficie para menu/pausa, com ajuste de texto e com as mesmas funcionalidades ja existentes.

## Fluxo do Usuario

### Fluxo de fase de teste

1. Jogador informa o nome na tela inicial.
2. Jogador clica em `Fase de Teste`.
3. O jogo gera uma conta aleatoria e abre a interface principal com aparencia de fase normal.
4. Jogador responde corretamente.
5. Surge o modal de convite.
6. Se clicar em `SIM!`, o jogo inicia a Fase 1 real.
7. Se clicar em `TELA INICIAL`, o jogo volta ao overlay inicial.

### Fluxo de fechamento de modais

1. Jogador abre premiacao ou som.
2. Jogador clica no `X`.
3. O modal fecha.
4. O jogador retorna a fase onde estava.

### Fluxo de menu/pause

1. Jogador clica em `Menu/Pause`.
2. Abre o overlay unificado com as opcoes atuais.
3. O jogador continua, reinicia, volta ao inicio, abre premiacao ou abre som a partir dele.

## Regras de Comportamento

- A fase de teste exige nome preenchido, igual ao inicio do jogo real.
- A fase de teste sempre gera uma nova conta aleatoria ao ser aberta.
- A fase de teste nao soma estrelas, nao libera selo e nao altera pontuacao total.
- A fase de teste nao concede avanço na barra de progresso principal.
- A fase de teste nao deve levar diretamente a Fase 2 ou a qualquer outra fase real sem passar pela Fase 1.
- Fechar premiacao ou som com `X` nao pode disparar reinicio de fase.
- O overlay `Menu/Pause` continua pausando a interacao da fase enquanto estiver aberto.

## Riscos e Compatibilidade

- Como `main.gd` centraliza muitos fluxos, a principal atencao e evitar regressao no avanço de fases reais e nos overlays ja existentes.
- O modal dinamico de feedback ja suporta quase todo o comportamento necessario, mas precisa de novas acoes para o fluxo de teste.
- A unificacao de menu e pausa e principalmente semantica e visual, entao deve reaproveitar o overlay atual para minimizar risco.

## Testes Planejados

- Validar que o botao de fase de teste so funciona com nome preenchido.
- Validar que a fase de teste abre com a UI normal de fase.
- Validar que a fase de teste gera uma conta aleatoria nova ao entrar.
- Validar que acertar a fase de teste abre o modal com `SIM!` e `TELA INICIAL`.
- Validar que `SIM!` inicia o jogo real na Fase 1.
- Validar que `TELA INICIAL` volta ao overlay inicial.
- Validar que a fase de teste nao altera pontuacao nem premios.
- Validar que o modal de premiacao fecha com `X` e retorna a fase.
- Validar que o modal de som fecha com `X` e retorna a fase.
- Validar que o botao do HUD exibe `Menu/Pause`.
- Validar que o overlay unificado mantem as funcionalidades anteriores.

## Fora de Escopo

- Alterar o conteudo pedagogico das fases reais.
- Redesenhar completamente os modais existentes.
- Criar persistencia separada para progresso da fase de teste.
