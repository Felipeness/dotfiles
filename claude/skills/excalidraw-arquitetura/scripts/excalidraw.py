"""Biblioteca para gerar diagramas de arquitetura .excalidraw.

Uso mínimo:

    from excalidraw import Diagram, NET, CPU, DB, SEC, MGM, BAD, OK, MUT

    d = Diagram("Arquitetura X", "conta 123 · us-east-1 · 2026-08-26")
    users = d.layer("USUARIOS", "quem consome", 150)
    edge  = d.layer("BORDA", "global", 190)
    app   = d.layer("APLICACAO", "us-east-1", 300)

    d.svc(users, 180, "Usuario RH", "navegador", "user", MUT)
    cf = d.svc(edge, 380, "CloudFront", "api publica", "globe", NET, note=1)
    d.group(app, 20, 1020, "VPC minha-vpc 10.0.0.0/16", "publica + privada", OK)
    ec = d.svc(app, 280, "EC2 t3.micro", "EIP · 1 GB", "compute", CPU)

    d.flow([d.bot(cf), d.top(ec)])
    d.note(1, "CloudFront fala direto com a origem",
              "Nao existe Load Balancer. Com uma instancia so, um ALB\\ncustaria US$ 16,20/mes.")
    d.legend()
    d.save("arquitetura.excalidraw")

`save()` valida colisoes e aborta com erro se o desenho estiver quebrado.
`svc()` recusa rotulo longo — a prosa tem que ir para `note()`.
"""
import json

# ---------------------------------------------------------------- paleta AWS
NET = "#8C4FFF"   # rede e entrega
CPU = "#ED7100"   # computacao
DB  = "#2E27AD"   # banco de dados
STO = "#7AA116"   # armazenamento
SEC = "#DD344C"   # seguranca e identidade
MGM = "#E7157B"   # gestao e governanca
BAD = "#D13212"   # risco ou ausencia
OK  = "#1D8102"   # virtude do desenho
MUT = "#5f6b7a"   # neutro

INK, FAINT, LINE, BANDF = "#16191f", "#aab7b8", "#879596", "#fafbfc"

CATEGORIAS = [("Rede e entrega", NET), ("Computacao", CPU), ("Banco de dados", DB),
              ("Armazenamento", STO), ("Seguranca e identidade", SEC),
              ("Gestao", MGM), ("Risco ou ausencia", BAD), ("Virtude do desenho", OK)]

ICON = 72          # lado do quadrado do icone
CELL = 178         # largura reservada ao rotulo sob o icone
MAX_NAME, MAX_DETAIL = 22, 26

_B = dict(angle=0, fillStyle="solid", strokeStyle="solid", roughness=0, opacity=100,
          groupIds=[], frameId=None, seed=0, version=1, versionNonce=0,
          isDeleted=False, boundElements=[], updated=1, link=None, locked=False)


class Diagram:
    def __init__(self, titulo, subtitulo="", x=80, largura_conteudo=2180,
                 painel_notas=True):
        self.els, self._n = [], 0
        self.leaves = []          # caixas de componente, para validar colisao
        self.notes = []
        self.x = x                # gutter dos rotulos de camada
        self.cx = x + 190         # inicio da area de conteudo
        self.cw = largura_conteudo
        self.nx = self.cx + largura_conteudo + 130   # painel de notas
        self._y = 100             # cursor vertical das camadas
        self._painel = painel_notas
        self._txt(x, 0, titulo, 30, INK, font=1)
        if subtitulo:
            self._txt(x, 44, subtitulo, 12.5, MUT)

    # ---------------------------------------------------------- primitivas
    def _id(self, p="e"):
        self._n += 1
        return f"{p}{self._n:05d}"

    def _seed(self):
        self._n += 1
        return (self._n * 104729) % 2147483647

    def _rect(self, x, y, w, h, stroke, fill, sw=2, dash=False, rad=True):
        e = dict(_B); e.update(
            id=self._id("r"), type="rectangle", x=x, y=y, width=w, height=h,
            strokeColor=stroke, backgroundColor=fill, strokeWidth=sw,
            strokeStyle="dashed" if dash else "solid",
            roundness={"type": 3} if rad else None,
            seed=self._seed(), versionNonce=self._seed())
        self.els.append(e); return e

    def _ell(self, x, y, w, h, stroke, fill, sw=2):
        e = dict(_B); e.update(
            id=self._id("o"), type="ellipse", x=x, y=y, width=w, height=h,
            strokeColor=stroke, backgroundColor=fill, strokeWidth=sw,
            roundness=None, seed=self._seed(), versionNonce=self._seed())
        self.els.append(e); return e

    def _txt(self, x, y, s, size=12, color=INK, align="left", w=None, font=2):
        L = s.split("\n")
        e = dict(_B); e.update(
            id=self._id("t"), type="text", x=x, y=y,
            width=w if w else int(len(max(L, key=len)) * size * 0.56),
            height=int(len(L) * size * 1.25), strokeColor=color,
            backgroundColor="transparent", strokeWidth=1, roundness=None,
            seed=self._seed(), versionNonce=self._seed(), text=s, fontSize=size,
            fontFamily=font, textAlign=align, verticalAlign="top",
            containerId=None, originalText=s, lineHeight=1.25)
        self.els.append(e); return e

    def _line(self, pts, stroke=LINE, sw=2, dash=False, head=None):
        x0, y0 = pts[0]
        rel = [[a - x0, b - y0] for a, b in pts]
        xs = [p[0] for p in rel]; ys = [p[1] for p in rel]
        e = dict(_B); e.update(
            id=self._id("a"), type="arrow", x=x0, y=y0,
            width=max(xs) - min(xs), height=max(ys) - min(ys), strokeColor=stroke,
            backgroundColor="transparent", strokeWidth=sw,
            strokeStyle="dashed" if dash else "solid", roundness={"type": 2},
            seed=self._seed(), versionNonce=self._seed(), points=rel,
            startBinding=None, endBinding=None, startArrowhead=None,
            endArrowhead=head, elbowed=False)
        self.els.append(e)

    # ------------------------------------------------------------- glifos
    def _glyph(self, kind, x, y, s):
        w = "#ffffff"
        if kind == "compute":
            p = s * .22
            self._rect(x + p, y + p, s - 2 * p, s - 2 * p, w, "transparent", 2, rad=False)
            for i in range(3):
                o = p + (s - 2 * p) * (i + 1) / 4
                self._line([(x + p * .45, y + o), (x + p, y + o)], w, 2)
                self._line([(x + s - p, y + o), (x + s - p * .45, y + o)], w, 2)
        elif kind == "db":
            bw, bh = s * .5, s * .56; cx, cy = x + (s - bw) / 2, y + (s - bh) / 2; eh = bh * .3
            self._ell(cx, cy + bh - eh, bw, eh, w, "transparent", 2)
            self._line([(cx, cy + eh / 2), (cx, cy + bh - eh / 2)], w, 2)
            self._line([(cx + bw, cy + eh / 2), (cx + bw, cy + bh - eh / 2)], w, 2)
            self._ell(cx, cy, bw, eh, w, "transparent", 2)
        elif kind == "globe":
            d = s * .54; cx, cy = x + (s - d) / 2, y + (s - d) / 2
            self._ell(cx, cy, d, d, w, "transparent", 2)
            self._ell(cx + d * .28, cy, d * .44, d, w, "transparent", 2)
            self._line([(cx, cy + d / 2), (cx + d, cy + d / 2)], w, 2)
        elif kind == "bucket":
            bw, bh = s * .52, s * .44; cx, cy = x + (s - bw) / 2, y + (s - bh) / 2
            self._line([(cx, cy), (cx + bw, cy), (cx + bw * .84, cy + bh),
                        (cx + bw * .16, cy + bh), (cx, cy)], w, 2)
        elif kind == "box":
            bw = s * .5; cx, cy = x + (s - bw) / 2, y + (s - bw) / 2
            self._rect(cx, cy, bw, bw, w, "transparent", 2, rad=False)
            self._line([(cx, cy + bw * .34), (cx + bw, cy + bw * .34)], w, 2)
        elif kind == "shield":
            bw, bh = s * .46, s * .54; cx, cy = x + (s - bw) / 2, y + (s - bh) / 2
            self._line([(cx + bw / 2, cy), (cx + bw, cy + bh * .24), (cx + bw / 2, cy + bh),
                        (cx, cy + bh * .24), (cx + bw / 2, cy)], w, 2)
        elif kind == "stack":
            bw = s * .5; cx, cy = x + (s - bw) / 2, y + s * .26
            for i in range(3):
                self._rect(cx, cy + i * bw * .26, bw, bw * .2, w, "transparent", 2, rad=False)
        elif kind == "wave":
            bw = s * .52; cx, cy = x + (s - bw) / 2, y + s / 2
            self._line([(cx, cy), (cx + bw * .22, cy - bw * .2), (cx + bw * .45, cy + bw * .16),
                        (cx + bw * .7, cy - bw * .24), (cx + bw, cy)], w, 2)
        elif kind == "key":
            d = s * .22; cx, cy = x + s * .28, y + (s - d) / 2
            self._ell(cx, cy, d, d, w, "transparent", 2)
            self._line([(cx + d, cy + d / 2), (cx + s * .42, cy + d / 2)], w, 2)
            self._line([(cx + s * .32, cy + d / 2), (cx + s * .32, cy + d)], w, 2)
        elif kind == "user":
            d = s * .26; cx, cy = x + (s - d) / 2, y + s * .22
            self._ell(cx, cy, d, d, w, "transparent", 2)
            self._line([(x + s * .28, y + s * .78), (x + s * .34, y + s * .56),
                        (x + s * .66, y + s * .56), (x + s * .72, y + s * .78)], w, 2)
        elif kind == "gear":
            d = s * .4; cx, cy = x + (s - d) / 2, y + (s - d) / 2
            self._ell(cx, cy, d, d, w, "transparent", 2)
            for a in [(0, -1), (0, 1), (-1, 0), (1, 0)]:
                self._line([(cx + d / 2 + a[0] * d * .5, cy + d / 2 + a[1] * d * .5),
                            (cx + d / 2 + a[0] * d * .72, cy + d / 2 + a[1] * d * .72)], w, 2)
        else:
            raise ValueError(f"glifo desconhecido: {kind}. Use um de: {', '.join(GLIFOS)}")

    # -------------------------------------------------------------- API
    def layer(self, label, sub="", height=200):
        """Cria uma faixa horizontal. Ordem de chamada = ordem visual (topo->base).
        Padrao AWS: apresentacao em cima, aplicacao no meio, dados embaixo."""
        y = self._y
        self._rect(self.x, y, self.cx - self.x + self.cw, height, "#e9ecef", BANDF, 1, rad=False)
        self._txt(self.x + 18, y + 16, label, 12, MUT)
        if sub:
            self._txt(self.x + 18, y + 32, sub, 10, FAINT)
        self._y += height + 20
        return (y, height)

    def svc(self, layer, x, name, detail="", glyph="box", color=MUT, note=None, dy=30):
        """Componente: icone + rotulo curto ABAIXO. Recusa prosa de proposito."""
        if len(name) > MAX_NAME:
            raise ValueError(f"nome longo demais ({len(name)}>{MAX_NAME}): {name!r}. "
                             "Rotulo e curto; explicacao vai em note().")
        if detail and len(detail) > MAX_DETAIL:
            raise ValueError(f"detalhe longo demais ({len(detail)}>{MAX_DETAIL}): {detail!r}. "
                             "Isso e prosa — mova para note().")
        cx = self.cx + x
        y = layer[0] + dy
        ix = cx - ICON / 2
        self._rect(ix, y, ICON, ICON, color, color, sw=0)
        self._glyph(glyph, ix, y, ICON)
        self._txt(cx - CELL / 2, y + ICON + 10, name, 12.5, INK, "center", CELL)
        if detail:
            self._txt(cx - CELL / 2, y + ICON + 27, detail, 10.5, MUT, "center", CELL)
        if note is not None:
            self._ell(ix + ICON - 14, y - 10, 26, 26, color, "#ffffff", 2)
            self._txt(ix + ICON - 14, y - 5, str(note), 13, color, "center", 26)
        box = (ix, y, ICON, ICON + (44 if detail else 28))
        self.leaves.append(box + (name,))
        return (ix, y, ICON, ICON)

    def group(self, layer, x, w, titulo, sub="", color=MUT, dy=12, h=None):
        """Agrupamento real: VPC, AZ, subnet, cluster. Tracejado, rotulo no topo."""
        y = layer[0] + dy
        self._rect(self.cx + x, y, w, h or (layer[1] - dy - 12), color, "transparent", 2, dash=True)
        self._txt(self.cx + x + 14, y + 10, titulo, 12, color)
        if sub:
            self._txt(self.cx + x + 14, y + 26, sub, 10, color)

    def flow(self, pts, color=LINE, dash=False, label=None, lsize=10):
        self._line(pts, color, 2, dash, head="arrow")
        if label:
            mx = sum(p[0] for p in pts) / len(pts)
            my = sum(p[1] for p in pts) / len(pts)
            self._txt(mx - len(label) * 3, my - 16, label, lsize, color)

    def note(self, num, titulo, corpo):
        """Toda a prosa vive aqui. `num` casa com o badge do svc()."""
        self.notes.append((num, titulo, corpo))

    def box(self, titulo, linhas, color=BAD):
        """Quadro auxiliar no painel de notas: lista de (rotulo, valor)."""
        self.notes.append(("__box__", titulo, (color, linhas)))

    # âncoras
    def top(self, b):   return (b[0] + b[2] / 2, b[1])
    def bot(self, b):   return (b[0] + b[2] / 2, b[1] + b[3])
    def lft(self, b):   return (b[0], b[1] + b[3] / 2)
    def rgt(self, b):   return (b[0] + b[2], b[1] + b[3] / 2)

    def legend(self, categorias=None, rodape=None):
        cats = categorias or CATEGORIAS
        y = self._y + 10
        w = self.cx - self.x + self.cw
        self._rect(self.x, y, w, 110, "#e9ecef", "#ffffff", 1, rad=False)
        self._txt(self.x + 20, y + 16, "LEGENDA", 12, MUT)
        step = w // max(len(cats), 1)
        for i, (l, c) in enumerate(cats):
            cxx = self.x + 20 + i * step
            self._rect(cxx, y + 46, 26, 26, c, c, sw=0)
            self._txt(cxx + 36, y + 52, l, 11, INK)
        self._txt(self.x + 20, y + 84,
                  rodape or "Numeros remetem as notas ao lado", 10.5, MUT)
        self._y = y + 130

    # ------------------------------------------------------- render + check
    def _render_notes(self):
        if not self._painel or not self.notes:
            return
        top_y = 100
        altura = max(self._y - top_y, 300)
        self._rect(self.nx, top_y, 860, altura, "#e9ecef", "#ffffff", 1, rad=False)
        self._txt(self.nx + 26, top_y + 26, "NOTAS", 13, MUT)
        ny = top_y + 60
        for num, titulo, corpo in self.notes:
            if num == "__box__":
                color, linhas = corpo
                bh = 60 + len(linhas) * 26
                self._rect(self.nx + 26, ny + 8, 808, bh, color, "#fff5f5", 2)
                self._txt(self.nx + 46, ny + 26, titulo, 13, color)
                for i, (a, b) in enumerate(linhas):
                    yy = ny + 56 + i * 26
                    self._txt(self.nx + 46, yy, a, 11, INK)
                    self._txt(self.nx + 560, yy, b, 11, color, "right", 250)
                ny += bh + 30
                continue
            self._ell(self.nx + 26, ny, 24, 24, MUT, "#ffffff", 2)
            self._txt(self.nx + 26, ny + 5, str(num), 12, MUT, "center", 24)
            self._txt(self.nx + 62, ny + 1, titulo, 12.5, INK)
            self._txt(self.nx + 62, ny + 20, corpo, 10.5, MUT)
            ny += 26 + len(corpo.split("\n")) * 13 + 16

    def validate(self):
        """Retorna lista de problemas. Vazia = desenho integro."""
        def ov(a, b):
            return not (a[0] + a[2] <= b[0] or b[0] + b[2] <= a[0] or
                        a[1] + a[3] <= b[1] or b[1] + b[3] <= a[1])
        prob = [f"componentes colidem: {a[4]!r} x {b[4]!r}"
                for i, a in enumerate(self.leaves) for b in self.leaves[i + 1:] if ov(a, b)]

        T = [e for e in self.els if e["type"] == "text"]
        for i, a in enumerate(T):
            for b in T[i + 1:]:
                if ov((a["x"], a["y"], a["width"], a["height"]),
                      (b["x"], b["y"], b["width"], b["height"])):
                    prob.append(f"texto colide: {a['text'][:24]!r} x {b['text'][:24]!r}")

        usados = {n for n, _, _ in self.notes if n != "__box__"}
        badges = {int(e["text"]) for e in T
                  if e["text"].isdigit() and e["fontSize"] == 13 and e["width"] == 26}
        if badges - usados:
            prob.append(f"badge sem note() correspondente: {sorted(badges - usados)}")
        if usados - badges:
            prob.append(f"note() sem badge no desenho: {sorted(usados - badges)}")
        return prob

    def save(self, path, forcar=False):
        self._render_notes()
        prob = self.validate()
        if prob and not forcar:
            raise AssertionError("diagrama invalido:\n  - " + "\n  - ".join(prob[:20]))
        doc = {"type": "excalidraw", "version": 2, "source": "https://excalidraw.com",
               "elements": self.els,
               "appState": {"gridSize": None, "viewBackgroundColor": "#ffffff"},
               "files": {}}
        with open(path, "w", encoding="utf-8") as fh:
            json.dump(doc, fh, ensure_ascii=False, indent=1)
        xs = [e["x"] for e in self.els]; xe = [e["x"] + e["width"] for e in self.els]
        ys = [e["y"] for e in self.els]; ye = [e["y"] + e["height"] for e in self.els]
        print(f"elementos ........ {len(self.els)}")
        print(f"componentes ...... {len(self.leaves)}")
        print(f"notas ............ {len(self.notes)}")
        print(f"problemas ........ {len(prob)}")
        for p in prob[:10]:
            print("   !", p)
        print(f"canvas ........... {max(xe)-min(xs):.0f} x {max(ye)-min(ys):.0f}")
        print(f"arquivo: {path}")
        return path


GLIFOS = ["compute", "db", "globe", "bucket", "box", "shield", "stack", "wave",
          "key", "user", "gear"]
