<?php

// Shared-hosting front controller. On the server the whole app sits in a
// web-reachable folder (public_html/gautamgupta.in/gymbrainapi) instead of
// having public/ as the document root, so the root .htaccess routes every
// request here. Booting from this path keeps SCRIPT_NAME at the app root,
// which lets Laravel detect the /gymbrainapi base path correctly.
// Local development is unaffected: `php artisan serve` still uses public/.

require __DIR__.'/public/index.php';
