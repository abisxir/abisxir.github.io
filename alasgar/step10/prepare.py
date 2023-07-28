with open('build/index.html', 'r') as f:
    html = f.read()
with open('main.nim', 'r') as f:
    nim = f.read()
with open('build/index.html', 'w') as f:
    f.write(html.replace('{{{SOURCE}}}', nim))
