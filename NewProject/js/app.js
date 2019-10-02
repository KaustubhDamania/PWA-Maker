if ('serviceWorker' in navigator) { // show other serviceworker in application tabs
    try {
        navigator.serviceWorker.register('../serviceworker.js');
        console.log('SW registered');
    } catch (error) {
        console.log('SW failed');

    }
}

