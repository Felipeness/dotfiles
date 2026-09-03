# Dota 2

Configs de Game State Integration (GSI) que o Dota le ao iniciar: Dota Plus, Overwolf, Logitech G HUB e o analisador de picks local.

Restaurar: copiar a pasta `gamestate_integration/` inteira para

```
<SteamLibrary>\steamapps\common\dota 2 beta\game\dota\cfg\gamestate_integration\
```

Hoje o Dota fica em `D:\SteamLibrary`. Reiniciar o jogo depois de copiar.

## Teclas e settings

Pasta `keybinds/`, da conta Steam 329255797 (perfil "LOL", restaurado em 03/09/2026):

| Arquivo | O que e | Restaurar em |
|---|---|---|
| `dotakeys_personal.lst` | Atalhos de tecla (geral + por heroi) | `Steam\userdata\<id>\570\remote\cfg\` |
| `user_keys_0_slot0.vcfg` | Binds de console (space follow, b item, c camera lock) | `Steam\userdata\<id>\570\local\cfg\` |
| `user_convars_0_slot0.vcfg` | Settings do jogo (quickcast, camera, chat) | `Steam\userdata\<id>\570\local\cfg\` |

Copiar com o Dota fechado. O Steam Cloud sincroniza depois.

## Historico

03/09/2026: alguem logou na conta 329255797 em outro PC e a nuvem (Steam Cloud pras teclas, cloud do Dota pros settings) sobrescreveu a config local com a dele (perfil "ARROW", 2805 launches). Restaurado com settings de ontem (copia de sombra do Windows) e teclas da conta 1881984300, que tinha o mesmo perfil. Se acontecer de novo: fechar o Dota, copiar os 3 arquivos daqui por cima e NAO tocar nos `_lastclouded` (assim o Dota entende que a versao local e a mais nova e sobe ela).
