# Detetive dos Números - Projeto Acadêmico em Godot

Projeto em **Godot 4.6** desenvolvido como entrega de faculdade, com foco em jogo educativo infantil, progressão matemática e apresentação visual amigável. O jogador assume o papel de um detetive mirim que resolve desafios de matemática para salvar a cidade de Numerópolis.

## Recursos implementados
- nome personalizado do jogador (com sugestões)
- modal de história e tela de jornada encantada
- múltiplas fases temáticas com alternativas (contagem, adição, subtração e operações combinadas)
- timer com urgência nos últimos segundos
- pontuação baseada no tempo de resposta
- badges e presente de recompensa
- chefão final com vidas
- menu de pausa completo (Menu / Premiação / Som) com controle de volume
- celebração final com fogos
- sons gerados/integrados dentro do próprio projeto

## Estrutura
- `project.godot` — configuração do projeto (cena principal: `scenes/main.tscn`)
- `scenes/` — cenas do jogo
  - `main.tscn`, `MainMenu.tscn`, `JourneyMap.tscn`, `GamePhase.tscn`, `BossPhase.tscn`
  - `StoryModal.tscn`, `PauseModal.tscn`, `RewardPopup.tscn`, `GameOver.tscn`
- `scripts/` — lógica do jogo
  - `main.gd` (fluxo principal), `game_content.gd` (carregamento de conteúdo), `theme_factory.gd` (tema visual)
- `assets/`
  - `audio/` — efeitos sonoros (`.wav`)
  - `fonts/` — fontes Comic (corpo e negrito)
- `data/game_content.json` — fases, perguntas, narrativa e badges (conteúdo do jogo)
- `docs/` — `GDD.md` (Game Design Document) e documentos de planejamento

## Como abrir
1. Abra o **Godot 4.6**.
2. Importe `project.godot`.
3. Rode com `F5`.

## Integrantes
- Steffany — tela de início e fim de jogo
- João — mecânica do jogo
- Ricardo — menu
- Guilherme — som

## Observação
Os arquivos de texto do projeto foram mantidos em UTF-8.
