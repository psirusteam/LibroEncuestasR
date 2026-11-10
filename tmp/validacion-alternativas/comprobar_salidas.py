from pathlib import Path
import hashlib
import json
from urllib.parse import urlsplit, unquote
from html.parser import HTMLParser

class HTML(HTMLParser):
    def __init__(self, value):
        super().__init__()
        self.ids = set()
        self.links = []
        self.resources = []
        self.words = []
        self.main = False
        self.images = 0
        self.feed(value)

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if 'id' in a:
            self.ids.add(a['id'])
        self.main |= tag == 'main'
        self.images += tag == 'img'
        if tag == 'a' and 'href' in a:
            self.links.append(a['href'])
        if tag in ('a', 'link') and 'href' in a:
            self.resources.append(a['href'])
        if tag in ('img', 'script') and 'src' in a:
            self.resources.append(a['src'])

    def handle_data(self, value):
        self.words.append(value)

root = Path(__file__).resolve().parents[2]
audit = root / 'tmp/validacion-alternativas'
originals = json.loads((audit / 'originales-sha256.json').read_text(encoding='utf-8'))
for name, expected in originals.items():
    assert hashlib.sha256((root / 'chapters' / name).read_bytes()).hexdigest() == expected, name

pages = [root / 'docs' / x for x in (
    'index.html', 'chapters/01-Introduccion-alternativa.html',
    'chapters/03-Categoricas-alternativa.html',
    'chapters/04-Continuas-alternativa.html')]
errors = []
for page in pages:
    soup = HTML(page.read_text(encoding='utf-8'))
    assert soup.main, page
    for raw in soup.resources:
        url = urlsplit(raw)
        if url.scheme or url.netloc or raw.startswith('data:'):
            continue
        target = (page.parent / unquote(url.path)).resolve() if url.path else page
        if target.suffix.lower() == '.pdf':  # se verifica al terminar su render
            continue
        if not target.exists():
            errors.append(f'{page.name}: falta {raw}')
        elif url.fragment and target.suffix == '.html':
            target_soup = soup if target == page else HTML(target.read_text(encoding='utf-8'))
            if unquote(url.fragment) not in target_soup.ids:
                errors.append(f'{page.name}: ancla ausente {raw}')
    if 'quarto-unresolved-ref' in page.read_text(encoding='utf-8'):
        errors.append(f'{page.name}: referencias sin resolver')
    print(page.name, f'({soup.images} imágenes)')

index = HTML(pages[0].read_text(encoding='utf-8'))
links = index.links
cat = next(i for i, x in enumerate(links) if '03-Categoricas-alternativa.html' in x)
cont = next(i for i, x in enumerate(links) if '04-Continuas-alternativa.html' in x)
assert cat < cont
for page in pages[1:]:
    text = ' '.join(HTML(page.read_text(encoding='utf-8')).words)
    assert '@sec-' not in text and '(?@' not in text, page

report = {'originales_intactos': True, 'orden_correcto': True, 'enlaces_rotos': errors}
(audit / 'html-verificacion.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
if errors:
    raise AssertionError('\n'.join(errors))
print('Originales intactos, orden correcto y enlaces/recursos locales verificados.')
