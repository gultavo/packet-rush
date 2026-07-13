# Packet Rush

Jogo de plataforma 2D educativo, feito em Flutter, que ensina o **modelo TCP/IP**. Cada camada do modelo é um "andar" do jogo, e cada fase é um cenário jogável em que o conceito da camada aparece na prática.

## Objetivo do jogo

Você controla um pacote de dados que precisa atravessar a rede, camada por camada, até chegar ao destino. São **5 andares** e **27 fases** no total:

| Andar | Camada TCP/IP | Fases |
|-------|---------------|-------|
| 1 | Física | 5 |
| 2 | Enlace | 5 |
| 3 | Rede | 6 |
| 4 | Transporte | 5 |
| 5 | Aplicação | 6 |

Cada fase tem sempre a mesma estrutura em três etapas:

1. **Leitura** — um texto curto explica o conceito da camada antes da fase começar.
2. **Fase jogável** — a fase de plataforma, onde você corre, pula, desvia de buracos e enfrenta inimigos até alcançar o portal no fim do mapa.
3. **Quiz** — ao entrar no portal, aparecem 5 perguntas de múltipla escolha sobre o texto que você leu.

Você precisa acertar **pelo menos 3 das 5 perguntas** para ser aprovado e desbloquear a próxima fase. Os acertos viram estrelas (de 0 a 5) guardadas no seu progresso — o melhor resultado de cada fase fica salvo, e reprovar não faz você perder o que já conquistou, só não avança.

## Como jogar

Você começa cada fase com **3 vidas**. Encostar em um inimigo ou cair em um buraco custa uma vida; ao perder todas, aparece a tela de Game Over e a fase recomeça.

**No celular** (controles na tela):

- setas ◀ ▶ — andar para a esquerda e para a direita
- seta ▲ — pular
- botão redondo — atirar (derruba os inimigos; os chefes precisam de 4 tiros)

**No computador** (teclado):

- `←` `→` — andar
- `↑` — pular
- `Espaço` — atirar

O progresso é salvo automaticamente, então dá para fechar o jogo e continuar depois pelo botão **CONTINUAR** do menu inicial.

### Configurações

Pelo botão **OPTIONS** do menu inicial:

- **DEV** — libera todas as fases, sem precisar concluí-las na ordem (para desenvolvimento e testes; também dá pulo maior e vida infinita)
- **MÚSICA** — liga/desliga a trilha sonora
- **PAISAGEM** — escolhe se a gameplay roda com o celular deitado (enxerga mais à frente) ou em pé. Menus, leitura e quiz são sempre em retrato.

## Como rodar o projeto

**Pré-requisitos:** [Flutter SDK](https://docs.flutter.dev/get-started/install) com Dart `^3.9.2` (rode `flutter doctor` para conferir a instalação).

```bash
# 1. Instalar as dependências
flutter pub get

# 2. Rodar o jogo
flutter run
```

Se houver mais de um dispositivo disponível, escolha um explicitamente:

```bash
flutter devices              # lista os dispositivos disponíveis
flutter run -d windows       # desktop Windows
flutter run -d chrome        # navegador
flutter run -d <id-do-device> # celular/emulador Android
```

Para gerar o APK de release do Android:

```bash
flutter build apk --release
```

## Estrutura do projeto

```
lib/
  main.dart              # ponto de entrada: inicializa banco, progresso, config e música
  game_board.dart        # motor do jogo: física, colisões, inimigos, HUD, quiz e overlays
  player.dart            # o jogador
  enemy.dart             # inimigos (normais e chefes)
  objects.dart           # plataformas e segmentos de chão
  levels.dart            # dados de cenário (fundo, tamanho do mapa)
  keys_map.dart          # estado das teclas de movimento
  orientacao.dart        # troca de orientação entre menus (retrato) e gameplay
  fases/                 # as 27 fases: geometria, inimigos, texto de leitura e quiz
  data/                  # persistência (SQLite), progresso, configurações e música
  menu/                  # menu inicial e tela de configurações
  docs/                  # conteúdo didático das 27 fases (textos e gabaritos)
  Images/                # arte dos menus e das fases
sprites/                 # sprites do jogador, inimigos e plataformas
```

As dependências principais são `sqflite` / `sqflite_common_ffi` (progresso salvo em banco local), `audioplayers` (trilha sonora) e `vibration` (vibração ao perder todas as vidas).
