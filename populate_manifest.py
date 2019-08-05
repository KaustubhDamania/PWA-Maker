import json,sys,os
from shutil import copy,move
# import tkinter as tk
from tkinter import filedialog
from PIL import Image

if len(sys.argv) < 2:
    print('Few arguments provided')
    exit()

manifest = {
  "name": "",
  "short_name": "",
  "lang": "en-US",
  "start_url": "/",
  "display": "standalone",
  "orientation": "portrait",
  "scope": "/",
  "background_color": "",
  "theme_color": "",
  "icons": [],
  "splash_pages": None
}

manifest['name'] = sys.argv[1]
manifest['short_name'] = sys.argv[1]

new_url = input('Enter the start URL for PWA?\nLeave it blank if you want it to be /{}/: '.format(manifest['name']))

if new_url == '':
    new_url = manifest['name']

manifest['start_url'] = '/{}/'.format(new_url)

new_theme = input('Enter the background/theme color for PWA?\nLeave it blank if you want it to be #FFFFFF: ')

if new_theme == '':
    new_theme = '#FFFFFF'

manifest['background_color'] = new_theme
manifest['theme_color'] = new_theme

current_path = os.path.join(os.getcwd(),sys.argv[1])
path = os.path.join(os.getcwd(),sys.argv[1],'manifest.json')

def generate_images(img_path):
    global manifest
    sizes = ((48,48),(72,72),(96,96),(128,128),(144,144),(152,152),(192,192),(384,384),(512,512))
    file_type = img_path.split('.')[-1]
    for size in sizes:
        i = Image.open(img_path)
        i.thumbnail(size)
        file_name = 'icon-{}-{}.{}'.format(size[0],size[1],file_type)
        new_dir = os.path.split(img_path)[:-1][0]
        new_path = os.path.join(new_dir,file_name)
        # print(new_path, size)
        i.save(os.path.join(new_path))
        manifest['icons'].append({
            "src": "icons/{}".format(file_name),
            "sizes": "{}x{}".format(size[0],size[1]),
            "type": "image/{}".format(file_type)
        })

while True:
    is_img = input('Do you want to add icon for your PWA? (y/n): ').lower()

    if is_img=='y':
        file_path = filedialog.askopenfilename(title = "Select file",filetypes = (("image files","*.jpg *.png *.jpeg"),))
        copy(file_path, os.path.join(current_path,'icons'))
        new_path = os.path.join(current_path,'icons')
        file_name = os.path.split(file_path)[-1]
        new_path = os.path.join(new_path,file_name)
        generate_images(new_path)
        # print('Delete',new_path)
        os.remove(new_path)
        break
    elif is_img == 'n':
        break

with open(path,'w') as f:
    json.dump(manifest,f,indent=4)
