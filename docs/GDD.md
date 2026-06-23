# Detetive dos Números: O Mistério de Numerópolis

## Visão Geral
Projeto acadêmico de jogo educativo infantil desenvolvido em Godot 4. O jogador assume o papel do Detetive Mirim e precisa restaurar a ordem de Numerópolis usando contagem, soma, subtração, divisão e operações combinadas.

## Proposta
- Gênero: aventura educativa point-and-click com múltipla escolha.
- Público-alvo: crianças em fase de alfabetização matemática.
- Plataforma: desktop com suporte para mouse e interface responsiva.

## Identidade do Jogador
- Campo para nome personalizado.
- Sugestões rápidas de nome:
  - Explorador
  - Pequeno Gênio
  - Aventureiro

## Jornada / História
- A narrativa segue a Jornada do Herói.
- Professor Ponto atua como mentor.
- Calculina funciona como apoio visual e emocional.
- A progressão mostra o avanço por bairros até o chefão final.

## Estrutura das Fases
### Fases normais
- Bairro dos Brinquedos
- Bairro dos Doces
- Escola da Lógica
- Floresta das Folhas
- Laboratório Numérico

### Fase final
- Torre Congelante do Pinguim
- Chefão com vidas
- Rodadas com pressão de tempo

## Mecânicas
- Alternativas grandes e infantis.
- Botão de confirmar resposta.
- Botão de próxima fase.
- Limite de tempo por fase.
- Som de urgência nos últimos 10 segundos.
- Resposta errada ou tempo esgotado gera feedback claro.

## Pontuação
- 0 a 10 segundos: +3 pontos
- 11 a 30 segundos: +2 pontos
- 31 a 60 segundos: +1 ponto
- Sem resposta: 0 ponto

## Recompensas
- Presente abrindo na tela
- Selos:
  - Rápido como um raio
  - Super cérebro
  - Acerto perfeito
- Fogos na tela final

## Progressão
- Mais fases que a versão inicial
- Mais alternativas por pergunta
- Distrações adicionais quando o jogador acerta rápido várias fases
- Chefão final com vidas e várias rodadas

## Interface
- Barra superior com:
  - nome do jogador
  - pontuação
  - tempo
  - progresso
- Tela de jornada em modal com fechar e voltar
- Modal de pausa com:
  - continuar
  - reiniciar fase
  - reiniciar jogo
  - voltar ao início

## Direção Visual
- Paleta vibrante
- Alto contraste
- Cores alegres
- Tema visual por fase:
  - água e brinquedos
  - doces
  - escola
  - floresta
  - laboratório
  - neve do pinguim

## Direção de Áudio
- Som de pato ao clicar nos patinhos
- Som de acerto
- Som de erro
- Som de urgência do cronômetro
- Som de recompensa

## Arquivos principais
- `project.godot`: configuração do projeto
- `scenes/main.tscn`: cena principal
- `scripts/main.gd`: lógica principal
- `data/game_content.json`: conteúdo das fases
