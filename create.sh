set -e
mkdir "$1"
cd "$1"
mkdir assets css js icons
touch index.html manifest.json serviceworker.js css/app.css js/app.js
cd ..

echo "window.addEventListener(\"\", async e => { // trigger on load
    if ('serviceWorker' in navigator) { // show other serviceworker in application tabs
        try {
            navigator.serviceWorker.register('serviceworker.js');
            console.log('SW registered');
        } catch (error) {
            console.log('SW failed');

        }
    }
});" > ./"$1"/js/app.js

echo '<!DOCTYPE html>
<html lang="en" dir="ltr">
    <head>
        <meta charset="utf-8">
        <!-- Manifest link for PWA -->
        <link rel="manifest" href="./manifest.json">
        <!-- CSS linker -->
        <link rel="stylesheet" href="./css/app.css">
        <title></title>
    </head>
    <body>

    <!-- JS linker -->
    <script src="./js/app.js" charset="utf-8"></script>
    </body>
</html>' > ./"$1"/index.html

echo "HTML file populated"

echo "// collection of all the static files which form the the shell of your app
const staticAssets = [
    './',
    './assets/',
    './icons/'
    './js/',
    './css/'
];

var mode; //used to keep a check whether we are online at this point of time or offline

// install event is called the very first time we register a servic worker
self.addEventListener('install', async event => {
    // #caches are http caches provided by service worker check Application >Cache > Cache Storage
    const cache = await caches.open('static-def'); // stores the shell part
    cache.addAll(staticAssets);
});

// called whenever fetch function is called in the client side
self.addEventListener('fetch', event => {
    console.log(event);
    const {request} = event;
    const url = new URL(request.url);
    if(mode==false) //check if online or offline
    event.respondWith(cacheData(request)); // if offline we have to check cache
    else{
        if(url.origin === location.origin) { // if the url that we are searching for is in the domain check cache first
            event.respondWith(cacheData(request));
        } else {
            event.respondWith(networkFirst(request)); // for outside urls do not check cache
        }
    }

});

self.addEventListener('message', function(event){
    if(event.data==\"offline\")
    mode=false
    else
    mode=true
    console.log(\"message: \"+mode);
});

async function cacheData(request)
{
    const cachedResponse = await caches.match(request); // check for request object for a match else returns nothing
    return cachedResponse || fetch(request);
}

async function networkFirst(request)
{
    const cache = await caches.open('dynamic-def'); // stores the dynamic part of the pwa

    try {
        const response = await fetch(request);
        cache.put(request, response.clone()); // map new request objects to the result object
        return response;
    } catch (error){
        return await cache.match(request); // if theres an error in making network first request it will check the caches
    }

}" > ./"$1"/serviceworker.js

echo "serviceworker.js file populated"

python3 populate_manifest.py "$1"
echo "Manifest file populated"
