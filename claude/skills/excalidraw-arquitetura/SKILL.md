---
name: excalidraw-arquitetura
description: Gera diagramas de arquitetura em Excalidraw (.excalidraw) no padrão AWS — ícone com rótulo curto, prosa em notas numeradas, camadas horizontais, legenda no rodapé. Use quando o usuário pedir desenho/diagrama de arquitetura, topologia, infraestrutura, "desenha como está funcionando", diagrama de solução, ou quiser visualizar um sistema em Excalidraw.
---

# Diagramas de arquitetura em Excalidraw

## As cinco regras

Violar qualquer uma produz um desenho rejeitado.

1. **Ícone é o componente; o rótulo fica fora dele.** No máximo nome (≤22 chars)
   e um detalhe (≤26 chars). Nunca uma frase.
2. **Toda explicação vira nota numerada** ao lado do desenho, com badge ①②③
   ancorado no componente.
3. **Camadas horizontais** na ordem: usuários → borda → aplicação → dados → apoio.
   Agrupamentos reais (VPC → AZ → subnet) como containers tracejados dentro das camadas.
4. **Legenda no rodapé**, como a legenda de um mapa: categorias de cor e o que
   cada tipo de seta significa.
5. **Espaço em branco é parte do desenho.** Densidade de informação, não de tinta.

O erro clássico é encher cada caixa com 3-5 linhas de explicação. Isso é texto
arrumado em grade, não diagrama. Tirando a prosa do desenho, a mesma informação
cabe num canvas ~3× menor e fica legível.

## Antes de desenhar: levante a topologia real

Desenho bonito com estrutura inventada é pior que nenhum. Colete o que existe de
fato antes de abrir o gerador:

```bash
aws ec2 describe-vpcs --query 'Vpcs[].{VPC:VpcId,CIDR:CidrBlock,Default:IsDefault}'
aws ec2 describe-subnets --query 'Subnets[].{Subnet:SubnetId,VPC:VpcId,CIDR:CidrBlock,AZ:AvailabilityZone,AutoIP:MapPublicIpOnLaunch}'
aws ec2 describe-instances --filters Name=instance-state-name,Values=running \
  --query 'Reservations[].Instances[].{ID:InstanceId,Type:InstanceType,Subnet:SubnetId,AZ:Placement.AvailabilityZone}'
aws rds describe-db-instances --query 'DBInstances[].{ID:DBInstanceIdentifier,AZ:AvailabilityZone,VPC:DBSubnetGroup.VpcId,Public:PubliclyAccessible,SG:VpcSecurityGroups[0].VpcSecurityGroupId}'
aws ec2 describe-security-groups --group-ids <sg> --query 'SecurityGroups[0].IpPermissions'
aws ec2 describe-nat-gateways --query 'NatGateways[].NatGatewayId'
aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerName'
```

As duas últimas importam tanto quanto as outras: **o que não existe costuma ser
a história**. Ausência de NAT Gateway e de Load Balancer explica uma conta baixa
melhor que qualquer componente presente. Desenhe as ausências como caixas
vermelhas com o custo que teriam.

## Como gerar

Importe `scripts/excalidraw.py` e escreva uma especificação declarativa. A
biblioteca cuida do JSON, dos ícones e da validação.

```python
import sys; sys.path.insert(0, "<caminho da skill>/scripts")
from excalidraw import Diagram, NET, CPU, DB, SEC, MGM, BAD, OK, MUT

d = Diagram("Arquitetura X · estado atual", "conta 123 · us-east-1 · 2026-08-26")

users = d.layer("USUARIOS",  "quem consome", 150)
edge  = d.layer("BORDA",     "global, fora da regiao", 190)
app   = d.layer("APLICACAO", "us-east-1", 300)
data  = d.layer("DADOS",     "us-east-1", 190)

d.svc(users, 180, "Usuario RH", "navegador", "user", MUT)
cf = d.svc(edge, 380, "CloudFront", "api publica", "globe", NET, note=1)

d.group(app, 20, 1020, "VPC minha-vpc  10.0.0.0/16", "publica + privada", OK)
d.group(app, 50, 460, "AZ us-east-1a · subnet publica", "10.0.1.0/24", NET, dy=48, h=175)
ec = d.svc(app, 280, "EC2 t3.micro", "EIP · 1 GB", "compute", CPU, dy=88)

db = d.svc(data, 280, "RDS Postgres", "db.t3.micro", "db", DB, note=2)

d.flow([d.bot(cf), d.top(ec)])
d.flow([d.bot(ec), d.top(db)], DB, label="5432")

d.note(1, "CloudFront fala direto com a origem",
          "Nao existe Load Balancer. Com uma instancia so, um ALB\\ncustaria US$ 16,20/mes.")
d.note(2, "RDS em subnet privada",
          "PubliclyAccessible false. Acesso apenas de dentro da VPC.")
d.box("POR QUE CUSTA POUCO", [("NAT Gateway x2", "US$ 65,70"),
                              ("Load Balancer x2", "US$ 32,40")], BAD)

d.legend(rodape="Setas cinza = requisicao · azuis = banco · numeros remetem as notas")
d.save("arquitetura.excalidraw")
```

`save()` aborta com `AssertionError` se houver colisão de componente, colisão de
texto, ou badge sem nota correspondente. Não passe `forcar=True` para contornar —
conserte o layout.

### Referência rápida da API

| Chamada | Para quê |
|---|---|
| `Diagram(titulo, subtitulo)` | inicia; painel de notas fica à direita automaticamente |
| `layer(label, sub, altura)` | faixa horizontal; ordem de chamada = ordem visual |
| `svc(layer, x, nome, detalhe, glifo, cor, note=, dy=)` | componente; `x` é relativo à área de conteúdo |
| `group(layer, x, w, titulo, sub, cor, dy=, h=)` | VPC / AZ / subnet / cluster |
| `flow(pts, cor, dash=, label=)` | seta; use `top/bot/lft/rgt(caixa)` como âncoras |
| `note(num, titulo, corpo)` | prosa; `\n` para quebrar linha |
| `box(titulo, [(rotulo, valor)], cor)` | quadro de números no painel |
| `legend(rodape=)` | legenda no rodapé |
| `save(path)` | valida e grava |

**Glifos**: `compute` `db` `globe` `bucket` `box` `shield` `stack` `wave` `key`
`user` `gear`

**Cores por categoria** (paleta AWS): `NET` rede · `CPU` computação · `DB` banco ·
`STO` armazenamento · `SEC` segurança · `MGM` gestão · `BAD` risco ou ausência ·
`OK` virtude do desenho · `MUT` neutro.

Use `BAD` e `OK` como camada semântica sobre a categoria: vermelho marca risco ou
o que falta, verde marca a decisão que merece crédito. É isso que transforma o
diagrama em argumento em vez de inventário.

## Escopo

Um diagrama por arquivo, feito bem. Se o pedido incluir estados futuros
("escalando", "auge"), valide a linguagem visual no primeiro antes de replicar —
refazer três desenhos errados custa o triplo.

Ao evoluir um diagrama existente, mantenha as mesmas cores, glifos e numeração de
notas; o leitor compara os desenhos lado a lado.

## Checklist antes de entregar

- [ ] Topologia conferida contra a realidade, não contra a documentação
- [ ] Nenhuma caixa contém frase — `svc()` recusa, mas confira os `group()`
- [ ] Toda nota tem badge no desenho e todo badge tem nota
- [ ] Ausências relevantes desenhadas com o custo que teriam
- [ ] `save()` passou sem problemas
- [ ] Canvas mais largo que alto (sinal de que as camadas estão sendo usadas)
