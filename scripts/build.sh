mkdir -p bin lib
echo '#!/usr/bin/env node' > bin/pert
coffee -b -c --no-header -p src/pert-cli.coffee >> bin/pert
chmod +x bin/pert
coffee -b -c --no-header -p src/pert.coffee > lib/pert.js
coffee -b -c --no-header -p src/pert-ui.coffee > client/pert-ui.js
